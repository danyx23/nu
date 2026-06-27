# Nushell Environment Config File
#
# version = 0.79.0

use ~/nu/utils/envtools.nu

def create_left_prompt [] {
    mut home = ""
    try {
        if $nu.os-info.name == "windows" {
            $home = $env.USERPROFILE
        } else {
            $home = $env.HOME
        }
    }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_segment = if (is-admin) {
        $"(ansi red_bold)($dir)"
    } else {
        $"(ansi green_bold)($dir)"
    }

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%m/%d/%Y %r')
    ] | str join)

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# PATH/Path are converted to Nushell lists automatically by current Nushell.
# Keep ENV_CONVERSIONS for non-standard colon-separated variables only.

# Directories to search for scripts/modules and plugin binaries.
# Constants are preferred for parse-time keywords such as `source` and `use`.
const NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

const NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# if (which zoxide | is-empty) {
#     echo "zoxide not found"
# } else {
#     zoxide init nushell | save -f ~/.zoxide.nu
# }

$env.COLORTERM = "truecolor"

$env.APP_CONFIG_DIR = (
        if ($nu.os-info.name == 'macos')
            { $"($nu.home-dir)/Library/Application Support" }
        else if ($nu.os-info.name == 'windows')
            { $"($env.APPDATA)" }
        else
            { $"($nu.home-dir)/.local/share" }
    )
$env.APP_EXEC_DIR = (
        if ($nu.os-info.name == 'macos')
            {[  $"/opt/homebrew/bin"  ]}
        else if ($nu.os-info.name == 'windows')
            {[  $"($nu.home-dir)/bin"  $"($nu.home-dir)/.local/bin"]}
        else
            {[  $"($nu.home-dir)/.local/bin"  ]}
    )
$env.PIPENV_VENV_IN_PROJECT = true

for $it in $env.APP_EXEC_DIR {envtools pathenv add $it}

$env.POETRY_VIRTUALENVS_IN_PROJECT = "true"

envtools pathenv add $"($nu.home-dir)/.rye/shims/"

$env.SCRIPT_SHELL = "/bin/zsh"
$env.TERM = "xterm-256color"