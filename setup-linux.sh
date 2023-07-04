#!/bin/bash
set -e

bootstrap() {
    has_fzf || echo "Please install fzf via apt"
    has_nu_scripts || install_nu_scripts
    has_env_file_link || link_env_file
    has_config_file_link || link_config_file
    has_oh_my_posh || install_oh_my_posh
    has_local-config || create_empty_local_config
    has_zellij || install_zellij
    has_broot || install_broot
    has_bat || install_bat
    has_nu || install_nu
    has_zoxide || install_zoxide
    has_ripgrep || install_ripgrep
}

setup_apt_packages() {
    sudo apt-get update
    has_fzf || install_fzf
    has_helix || install_helix
}

install_helix() {
    sudo add-apt-repository ppa:maveonair/helix-editor
    sudo apt update
    sudo apt install helix
    mkdir "$HOME/.config/helix"
    ln -s "$HOME/nu/helix.toml" "$HOME/.config/helix/config.toml"
}

has_helix() {
    if test -x "$(which hx)"
    then
        return 0
    else
        return 1
    fi
}

install_fzf() {
    sudo apt-get install fzf
}

has_fzf() {
    if test -x "$(which fzf)"
    then
        return 0
    else
        return 1
    fi
}

has_ripgrep() {
    if [ -f "$HOME/.local/bin/rg" ]; then
        return 0
    else
        return 1
    fi
}

install_ripgrep() {
    echo "==> Installing ripgrep"
    version="13.0.0"
    wget "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep-$version-x86_64-unknown-linux-musl.tar.gz"
    tar -xvf ripgrep-$version-x86_64-unknown-linux-musl.tar.gz
    mv ripgrep-$version-x86_64-unknown-linux-musl/rg ~/.local/bin
    rm -rf ripgrep-$version-x86_64-unknown-linux-musl
    rm ripgrep-$version-x86_64-unknown-linux-musl.tar.gz
}

has_zoxide() {
    if [ -f "$HOME/.local/bin/zoxide" ]; then
        return 0
    else
        return 1
    fi
}

install_zoxide() {
    echo "==> Installing zoxide"
    version="0.9.1"
    wget https://github.com/ajeetdsouza/zoxide/releases/download/v$version/zoxide-$version-x86_64-unknown-linux-musl.tar.gz
    tar -xvf zoxide-$version-x86_64-unknown-linux-musl.tar.gz
    mv zoxide ~/.local/bin
    rm zoxide-$version-x86_64-unknown-linux-musl.tar.gz
}

has_nu() {
    if [ -f "$HOME/.local/bin/nu" ]; then
        return 0
    else
        return 1
    fi
}

install_nu() {
    echo "==> Installing nu"
    version="0.81.0"
    wget https://github.com/nushell/nushell/releases/download/$version/nu-$version-x86_64-unknown-linux-musl.tar.gz
    tar -xvf nu-$version-x86_64-unknown-linux-musl.tar.gz
    mv nu-$version-x86_64-unknown-linux-musl/nu ~/.local/bin
    rm -rf nu-$version-x86_64-unknown-linux-musl
    rm nu-$version-x86_64-unknown-linux-musl.tar.gz
}

has_bat() {
    if [ -f "$HOME/.local/bin/bat" ]; then
        return 0
    else
        return 1
    fi
}

install_bat() {
    echo "==> Installing bat"
    version="v0.23.0"
    wget https://github.com/sharkdp/bat/releases/download/$version/bat-$version-x86_64-unknown-linux-musl.tar.gz
    tar -xvf bat-$version-x86_64-unknown-linux-musl.tar.gz
    mv bat-$version-x86_64-unknown-linux-musl/bat ~/.local/bin
    rm -rf bat-$version-x86_64-unknown-linux-musl
    rm bat-$version-x86_64-unknown-linux-musl.tar.gz
}

has_broot() {
    if [ -f "$HOME/.local/bin/broot" ]; then
        return 0
    else
        return 1
    fi
}

install_broot() {
    echo "==> Installing broot"
    wget https://dystroy.org/broot/download/x86_64-linux/broot
    chmod +x broot
    mv broot ~/.local/bin
}

has_zellij() {
    if [ -f "$HOME/.local/bin/zellij" ]; then
        return 0
    else
        return 1
    fi
}

install_zellij() {
    echo "==> Installing zellij"
    wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
    tar -xvf zellij-x86_64-unknown-linux-musl.tar.gz
    mv zellij ~/.local/bin
    rm zellij-x86_64-unknown-linux-musl.tar.gz
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

# Check if any argument was passed
if [ $# -gt 0 ]; then
  # Call function by argument name
  "$@"
else
  bootstrap
fi