use envtools.nu "pathenv add"

# pathenv add "/Users/daniel/Library/Application Support/carapace/bin"

let carapace_completer = {|spans: list<string>|
  # If the current command is an alias, complete against the first word of its expansion.
  let expanded_alias = (
    scope aliases
    | where name == $spans.0
    | get -o 0.expansion
  )

  let spans = if $expanded_alias != null {
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  }

  if (which carapace | is-empty) {
    []
  } else {
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
  }
}

$env.config.completions.external = (
  $env.config.completions.external | merge {
    enable: true
    max_results: 100
    completer: $carapace_completer
  }
)
