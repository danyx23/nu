#!/bin/bash
set -e

bootstrap() {
    has_cargo || install_cargo
    has_build_essential || install_build_essential
    cargo install cargo-binstall
    cargo binstall nushell
    cargo binstall zellij
    cargo binstall broot
    cargo binstall bat
    cargo binstall zoxide
    cargo binstall ripgrep
    has_nu_scripts || install_nu_scripts
    has_env_file_link || link_env_file
    has_config_file_link || link_config_file
    has_oh_my_posh || install_oh_my_posh
    has_local-config || create_empty_local_config
}

has_build_essential () {
    if test -x "$(which cc)"
    then
        return 0
    else
        return 1
    fi
}

install_build_essential() {
    echo "==> Installing build-essential"
    sudo apt-get install -y build-essential
}

has_cargo() {
    if test -x "$(which cargo)"
    then
        return 0
    else
        return 1
    fi
}

install_cargo() {
    echo "==> Installing cargo"
    sudo apt-get install -y curl
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
}

has_local-config() {
    if [ -f "$HOME/nu/local-config.nu" ]; then
        return 0
    else
        return 1
    fi
}

link_local_file() {
    touch "$HOME/nu/local-config.nu"
}

has_env_file_link() {
    if [ -f "$HOME/.config/nushell/env.nu" ]; then
        return 0
    else
        return 1
    fi
}

link_env_file() {
    ln -s "$HOME/nu/env.nu" "$HOME/.config/nushell/env.nu"
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
    if [ -f "$HOME/.config/nushell/config.nu" ]; then
        return 0
    else
        return 1
    fi
}

link_config_file() {
    ln -s "$HOME/nu/config.nu" "$HOME/.config/nushell/config.nu"
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