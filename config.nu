# Nushell Config File
#
# version = "0.86.1"

# For more information on defining custom themes, see
# https://www.nushell.sh/book/coloring_and_theming.html
# And here is the theme collection
# https://github.com/nushell/nu_scripts/tree/main/themes

use std
use "~/nu/utils/envtools.nu"


# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false # falserue or false to enable or disable the welcome banner at startup

    use_ansi_coloring: true
    edit_mode: vi # emacs, vi

    hooks: {
        pre_prompt: [{ null }] # run before the prompt is shown
        pre_execution: [{ null }] # run before the repl input is run
        env_change: {
            PWD: [
                {
                # if you enter a python project
                condition: {|before, after| ["pyproject.toml" "requirements.txt"] | any {|f| $f | path exists } }
                # drop any prior virtualenv, then use a new one if it exists
                code: "
                    if ('.venv/bin/python' | path exists) {
                       envtools pathenv load | filter {|p| $p !~ '.venv' } | prepend $\"($env.PWD)/.venv/bin\" | envtools pathenv save
                    } else {
                        envtools pathenv load | filter {|p| $p !~ '.venv' } | envtools pathenv save
                    }
                "
                }
            ]
        }


        display_output: {||
        if (term size).columns >= 100 { table -e } else { table }
        }
            command_not_found: {||
        null  # replace with source code to return an error message when a command is not found
        }
    }

}

source ~/nu/utils/.oh-my-posh.nu
source ~/nu_scripts/custom-completions/git/git-completions.nu
source ~/nu_scripts/custom-completions/poetry/poetry-completions.nu
source ~/nu_scripts/custom-completions/make/make-completions.nu
source ~/nu/utils/.zoxide.nu
source ~/nu/utils/broot.nu
use ~/nu_scripts/modules/fnm/fnm.nu
# use ~/nu/utils/fnm.nu setup
# setup
source ~/nu/utils/carapace-init.nu
use ~/owid-nushell/owid
source ~/owid-nushell/aliases.nu
source ~/nu/local-config.nu

source ~/nu_scripts/nu-hooks/nu-hooks/direnv/direnv.nu