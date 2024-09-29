
# Gets the metadata as an object from a file (i.e. the YAML frontmatter between --- fences)
export def "metadata get" [ ] {
    open $in | lines | skip 1 | take until {|it| $it == "---"} | str join "\n" | from yaml
}

# Modifies the metadata object with a closure and saves the changes back to the file
export def "metadata modify" [
    modifyFn: closure
] {
    let filename = $in
    if ($filename | path exists) {
        let frontmatter = $filename | metadata get
        let content = open $filename | lines | skip 1 | skip until {|it| $it == "---"} | str join "\n"
        let newFrontmatter = $frontmatter | do $modifyFn
        let newFile = $newFrontmatter | to text | ["---" $in $content] | str join "\n"
        $newFile | save $filename --force
        # $newFile
    }
}

# Helper to filter journal entries by start and end date
# Because I use this to make batch updates on usually short
# ranges, the filter will error if the range is longer than
# 10 days. This is to prevent accidental updates on a large
# number of files.
export def "filter journal" [
    startDate: datetime,
    endDate: datetime,
    --allowLongerThan10Days = false
] {
    if ($endDate - $startDate > 10day and not $allowLongerThan10Days) {
        error make {msg: "The date range is longer than 10 days. Use the --allowLongerThan10Days flag to override."}
    }
    $in | where name =~ "\\d{4}-\\d{2}-\\d{2}.md" | where { |it| $it.name | path basename | into datetime | $in >= $startDate and $in <= $endDate }
}
