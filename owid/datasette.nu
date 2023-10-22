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