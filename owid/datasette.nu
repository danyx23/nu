# Query the private OWID datasette instance with SQL
export def query [
    sql: string # SQL query to run
    jsonColumn? #
] {
    let args = { sql: $sql }
    let args = if $jsonColumn != null { $args | insert "_json" $jsonColumn } else { $args}
    let escaped = $args | url build-query # | str replace --all '%20' '+' | str replace --all '%' '~'
    let url = $"http://datasette-private/owid.json?_shape=objects&($escaped)"
    let response = http get -e -f $url
    let body = $response.body
    if $response.status != 200 or $body.ok != true {
        let span = (metadata $sql).span;
        error make {msg: $"Datasette returned an error \(status code was ($response.status))", label: {
            text: $response.body.error
            start: $span.start
            end: $span.end
        }}
    }
    return $response.body.rows
}

export def tables [] {
    http get http://datasette-private/owid.json | get tables
}

export def views [] {
    http get http://datasette-private/owid.json | get views
}

export def targets [] {
    (tables | get name) ++ (views | get name)
}

export def columns [
    name: string@targets
] {
    http get http://datasette-private/owid.json | get tables | where name == $name | get columns
}