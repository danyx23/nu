#!/bin/bash
set -e

bootstrap() {
    has_brew_program fzf || install_brew_program fzf
    has_brew_program oh-my-posh || install_brew_program oh-my-posh
    has_brew_program zellij || install_brew_program zellij
    has_brew_program broot || install_brew_program broot
    has_brew_program bat || install_brew_program bat
    has_brew_program nu || install_brew_program nushell
    has_brew_program zoxide || install_brew_program zoxide
    has_brew_program ripgrep || install_brew_program ripgrep
    has_brew_program fd || install_brew_program fd
    has_brew_program helix || install_brew_program helix

    has_nu_scripts || install_nu_scripts
    has_env_file_link || link_env_file
    has_config_file_link || link_config_file

}


function has_brew_program() {
  if which $1 > /dev/null; then
        return 0
    else
        return 1
  fi
}

function install_brew_program() {
  brew install $1
}



has_local-config() {
    if [ -f "$HOME/nu/local-config.nu" ]; then
        return 0
    else
        return 1
    fi
}

create_empty_local_config() {
    touch "$HOME/nu/local-config.nu"
}

has_oh_my_posh() {
    if [ -f "$HOME/.local/bin/oh-my-posh" ]; then
        return 0
    else
        return 1
    fi
}

install_oh_my_posh() {
    echo "==> Installing oh-my-posh"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
}

has_config_file_link() {
    if [ -f "$HOME/Library/Application Support/nushell/config.nu" ]; then
        return 0
    else
        return 1
    fi
}

link_config_file() {
    mkdir -p "$HOME/Library/Application Support/nushell"
    ln -s "$HOME/nu/config.nu" "$HOME/Library/Application Support/nushell/config.nu"
}

has_env_file_link() {
    if [ -f "$HOME/Library/Application Support/nushell/env.nu" ]; then
        return 0
    else
        return 1
    fi
}

link_env_file() {
    mkdir -p "$HOME/Library/Application Support/nushell"
    ln -s "$HOME/nu/env.nu" "$HOME/Library/Application Support/nushell/env.nu"
}


has_nu_scripts() {
    if [ -d "$HOME/nu_scripts" ]; then
        return 0
    else
        return 1
    fi
}

install_nu_scripts() {
    git clone git@github.com:nushell/nu_scripts.git "$HOME/nu_scripts"
}

# Check if any argument was passed
if [ $# -gt 0 ]; then
  # Call function by argument name
  "$@"
else
  bootstrap
fi