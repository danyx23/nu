# Adds a path to the OS specific path variable
export def --env "pathenv add" [
    newpath: string # Path to add
    --prepend # Prepend the path instead of appending at the end
] {
    let path = pathenv load
    let path = if $prepend {
        $path | append $newpath
    } else {
        $path | prepend $newpath
    }
    $path | pathenv save
}

export def "pathenv load" [

] {
    let pathvar: string = if "PATH" in $env { "PATH" } else { "Path" }
    let rawPath = $env | get $pathvar
    let path = if ($rawPath | describe) == "string" {
        $rawPath | split row (char esep)
    } else {
        $rawPath
    }
    $path
}

export def --env "pathenv save" [
] : list<string> -> nothing {
    let newPath = $in
    let pathvar: string = if "PATH" in $env { "PATH" } else { "Path" }
    load-env {
        $pathvar: $newPath
    }
}

export def nudo [func: closure] {
    sudo nu --stdin -c $"do (view source $func)"
}


export def nudf [] {
    const sizes = [Size Used Available]

    ^df -k
    | detect columns --guess
    | rename -c {"1K-blocks": Size}
    | update cells -c $sizes { $in + "KiB" }
    | update cells -c ["Use%"] { str trim -c "%" | into int }
    | into filesize ...$sizes
}
