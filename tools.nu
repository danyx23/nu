export def mount [] {
    ^mount | lines | parse "{device} on {mountpoint} type {fstype} {options}"
}

# Enriches the output of ls with path fragments (parent, stem, extension) and an md5 hash
export def lspp [] {
    upsert path {|it| $it.name | path parse}
    | select path.parent path.stem path.extension type size modified name
    | upsert md5 {|it| open --raw $it.name | hash md5}
}

# Compare the files in two directories by md5 hash and output all files joined with an outer join
export def compare_dirs [
    dir1,
    dir2
] {
    let d1 = ls $dir1 | lspp
    let d2 = ls $dir2 | lspp
    $d1
    | join --outer $d2 path_stem
    | select path_parent path_stem path_extension md5 md5_
    | upsert same {|it| $it.md5 == $it.md5_}
}

export def "movie length" [ filename ] {
    ffprobe -i $filename -show_entries format=duration -v quiet -of csv="p=0"
    | into int
    | into duration --unit sec
}
