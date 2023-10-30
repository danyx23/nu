# Nushell Environment Config File
#
# version = 0.79.0

def path_append [path] {
    let pathvar = if "PATH" in $env { "PATH" } else { "Path" }
    load-env {
        $pathvar: (
            $env | get $pathvar |
            split row (char esep) |
            append path )
    }
}

def path_prepend [path] {
    let pathvar = if "PATH" in $env { "PATH" } else { "Path" }
    load-env {
        $pathvar: (
            $env | get $pathvar |
            split row (char esep) |
            append path )
    }
}

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

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# if (which zoxide | is-empty) {
#     echo "zoxide not found"
# } else {
#     zoxide init nushell | save -f ~/.zoxide.nu
# }

$env.COLORTERM = truecolor

$env.APP_CONFIG_DIR = (
        if ($nu.os-info.name == 'Darwin')
            { $"($nu.home-path)/Library/Application Support" }
        else if ($nu.os-info.name == 'windows')
            { $"($env.APPDATA)" }
        else
            { $"($nu.home-path)/.local/share" }
    )
$env.APP_EXEC_DIR = (
        if ($nu.os-info.name == 'Darwin')
            { $"/opt/homebrew/bin" }
        else if ($nu.os-info.name == 'windows')
            { $"($nu.home-path)/bin" }
        else
            { $"($nu.home-path)/.local/bin" }
    )

path_prepend $env.APP_EXEC_DIR