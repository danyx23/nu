def-env load-fnm-env [] {
    let nodePath = fnm env --shell bash | lines | take 1 | parse 'export PATH="{p}":$PATH' | get 0 | get p
    $env.PATH = ($env.PATH | append $nodePath)
    fnm env --shell bash | lines | skip 1 | each { parse 'export {var}="{val}"' } | flatten | each { |it| {$it.var: $it.val}} | into record | flatten | into record | load-env
}