#!/bin/bash
set -e

bootstrap() {
    has_nu_scripts || install_nu_scripts
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