#!/bin/bash
set -e

bootstrap() {
    has_nu_scripts || install_nu_scripts
    has_env_file_link || link_env_file
    has_config_file_link || link_config_file
    has_oh_my_posh || install_oh_my_posh
    has_local-config || create_empty_local_config
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

bootstrap