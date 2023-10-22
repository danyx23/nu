export def query [
    sql: string # SQL query to run
] {
    let tildeEscaped = { sql: $sql } | url build-query # | str replace --all '%20' '+' | str replace --all '%' '~'
    print $tildeEscaped
    let url = $"http://datasette-private/owid.json?_shape=objects&($tildeEscaped)"
    print $url
    let response = http get -f $url
    if $response.status != 200 {
        error make {msg: $"Communication with datasette failed, status code was ($response.status)"}
    }
    let body = $response.body
    if $body.ok != true {
        error make {msg: "Datasette returned an error", body: $response.body.error}
    }
    return $response.body.rows
}