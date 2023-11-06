use mysql.nu
use api.nu

# Fetch a chart from mysql via the slug
export def "by slug" [
    slug: string
]  {
    let chart = mysql query $"select * from charts where slug = '($slug)'"
    $chart
}

# Fetch the metadata of all indicators used in a chart
export def "indicator metadata by slug" [
    slug: string
] {
    let chart = by slug $slug
    let indicatorIds = $chart | get config.dimensions | each {$in.variableId} | flatten
    $indicatorIds | par-each {|it| api metadata ($it)}
}


export def main [] {

}