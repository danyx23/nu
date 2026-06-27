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
cargo binstall -y nu

# Capture the pre-update configured history backend before pulling the new config.
# If this is already sqlite, do not run `history import` later because it appends.
pre_update_history_format="$(nu_history_format)"
log "Current Nushell history format: ${pre_update_history_format:-unknown}"

run_git_pull "$HOME/nu"
run_git_pull "$HOME/nu_scripts"

install_carapace() {
  local os arch install_dir current_path carapace_version carapace_url tmpdir

  case "$(uname -s)" in
    Linux) os="linux" ;;
    Darwin) os="darwin" ;;
    *)
      log "Unsupported OS for Carapace binary install: $(uname -s)"
      return 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) arch="amd64" ;;
    arm64|aarch64) arch="arm64" ;;
    *)
      log "Unsupported architecture for Carapace binary install: $(uname -m)"
      return 1
      ;;
  esac

  # Prefer replacing an existing carapace on PATH. Otherwise choose a user-writable
  # location that is usually on PATH for the platform/config.
  current_path="$(command -v carapace || true)"
  if [[ -n "$current_path" && -w "$(dirname "$current_path")" ]]; then
    install_dir="$(dirname "$current_path")"
  elif [[ "$os" == "darwin" && -d /opt/homebrew/bin && -w /opt/homebrew/bin ]]; then
    install_dir="/opt/homebrew/bin"
  else
    install_dir="$HOME/.local/bin"
  fi
  mkdir -p "$install_dir"

  carapace_version="$(curl -fsSL https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')"
  carapace_url="https://github.com/carapace-sh/carapace-bin/releases/download/v${carapace_version}/carapace-bin_${carapace_version}_${os}_${arch}.tar.gz"

  log "Downloading Carapace v${carapace_version} for ${os}/${arch} to ${install_dir}"
  tmpdir="$(mktemp -d)"
  curl -fsSL "$carapace_url" | tar -xz -C "$tmpdir" carapace
  install -m 0755 "$tmpdir/carapace" "$install_dir/carapace"
  rm -rf "$tmpdir"
}

log "Installing/updating Carapace"
install_carapace

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
