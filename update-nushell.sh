#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n==> %s\n' "$*"
}

run_git_pull() {
  local dir="$1"
  if [[ -d "$dir/.git" ]]; then
    log "Updating $dir"
    git -C "$dir" pull --ff-only
  else
    log "Skipping $dir (not a git checkout)"
  fi
}

nu_config_dir() {
  nu -l -c '$nu.default-config-dir' | tail -n 1 | tr -d '\r'
}

nu_history_format() {
  nu -l -c '$env.config.history.file_format | into string' 2>/dev/null | tail -n 1 | tr -d '\r' || true
}

log "Installing/updating Nushell"
cargo binstall nu

# Capture the pre-update configured history backend before pulling the new config.
# If this is already sqlite, do not run `history import` later because it appends.
pre_update_history_format="$(nu_history_format)"
log "Current Nushell history format: ${pre_update_history_format:-unknown}"

run_git_pull "$HOME/nu"
run_git_pull "$HOME/nu_scripts"

log "Installing/updating Carapace"
cargo binstall carapace

run_git_pull "$HOME/owid-nushell"

post_update_history_format="$(nu_history_format)"
log "Nushell history format after config update: ${post_update_history_format:-unknown}"

if [[ "$pre_update_history_format" == "sqlite" ]]; then
  log "History was already sqlite before this update; skipping migration"
elif [[ "$post_update_history_format" != "sqlite" ]]; then
  log "History is not configured for sqlite after update; skipping migration"
else
  config_dir="$(nu_config_dir)"
  history_txt="$config_dir/history.txt"
  history_backup="$config_dir/history.txt.bak.$(date +%Y%m%d%H%M%S)"

  if [[ -f "$history_txt" ]]; then
    log "Backing up plaintext history to $history_backup"
    cp "$history_txt" "$history_backup"
  else
    log "No plaintext history.txt found at $history_txt; running import anyway in case Nushell can find alternate history"
  fi

  log "Importing plaintext history into sqlite history"
  nu -l -c 'history import'
  log "History migration complete"
fi
