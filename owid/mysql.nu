use configuration.nu

# List the profiles in the .my.cnf file.
# This runs a python helper script that requires the 'click' package to be installed.
export def "list-profiles" [] {
  # On Windows the mysql cli and mysqlsh are insane and source from the weirdest, most non-standard places
  # mysql at least takes an $APPDATA/MySQL/.my-login.cnf into account but mysqlsh does not so we are left with
  # resorting to the one on C:\

  let conf = configuration get
  python $conf.mysqlProfileHelper list --config-path $conf.mysqlProfile
}

# Use a profile from the .my.cnf file.
# This runs a python helper script that requires the 'click' package to be installed.
export def "use-profile" [
    name: string@list-profiles # Name of the profile to switch to
] {
  let conf = configuration get
  python $conf.mysqlProfileHelper use $name --config-path $conf.mysqlProfile
}

# Show the tables in the database
export def "tables" [] {
  query 'show tables'
}

# Get the table values for completions
def "tableCompletion" [] {
    tables | get table
}


export def "columns" [
    table: string@tableCompletion # Name of the table to retrieve values for
] {
    query $"describe ($table)"
}

export def "views" [] {
    let database = mysqlsh --sql -e 'select database() as db' --json | from json | get rows | get 0.db
    let sql = $"select col.table_schema as database_name,
       col.table_name as view_name,
       col.ordinal_position,
       col.column_name,
       col.data_type,
       case when col.character_maximum_length is not null
            then col.character_maximum_length
            else col.numeric_precision end as max_length,
       col.is_nullable
from information_schema.columns col
join information_schema.views vie on vie.table_schema = col.table_schema
                                  and vie.table_name = col.table_name
where col.table_schema not in \('sys','information_schema',
                               'mysql', 'performance_schema'\)
    -- and vie.table_schema = (select ($database))
order by col.table_schema,
         col.table_name,
         col.ordinal_position;"
    query $sql
}

# Query rows in the given table. The --limit param returns the first N rows.
# You could also do limiting with nushell "| where" clauses but table is
# eager ATM and so this would fetch all rows only to discard some later on the client side.
export def "table" [
    table_name: string@tableCompletion # Name of the table to retrieve values for
    --limit (-l): int # Number of rows to return. Pass 0 to return all.
    --offset (-o): int # Number of rows to skip
    --where (-w): string # Where clause to filter rows
] {
    let baseQuery = $"select * from ($table_name)"
    let withOptionalWhere = if $where != "" { $"($baseQuery) where ($where)" } else { $baseQuery }
    let withOptionalLimit = if $limit > 0 { $"($baseQuery) limit ($limit)" } else { $withOptionalWhere }
    let withOptionalOffset = if $offset > 0 { $"($withOptionalLimit) offset ($offset)" } else { $withOptionalLimit }
    query $withOptionalOffset
}

# Run a query against the database
export def "query" [sql] {
    # TODO: handle errors which is when a json object with key error is returned
  let result = (mysqlsh --sql -e $sql --json) | from json
  if ("error" in $result) {
    $result.error
  } else {
    $result.rows
  }
}

export def "chart by-slug" [
    slug: string # Slug of the chart to retrieve
] {
    let slug = if $slug starts-with 'http' { $slug | split row "/" | last} else { $slug }
    let sql = $"select * from charts where slug = '($slug)'"
    query $sql
}

export def main [] {

}