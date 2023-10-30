# List the profiles in the .my.cnf file.
# This runs a python helper script that requires the 'click' package to be installed.
export def "list-profiles" [] {
  # On Windows the mysql cli and mysqlsh are insane and source from the weirdest, most non-standard places
  # mysql at least takes an $APPDATA/MySQL/.my-login.cnf into account but mysqlsh does not so we are left with
  # resorting to the one on C:\
  let myCnfPath = if $nu.os-info.name == "windows" {'C:\my.cnf'} else {'~/.my.cnf'}
  let pythonHelperPath = $env.FILE_PWD | path.join "mysql-profile.py"
  python $pythonHelperPath list
}

# Use a profile from the .my.cnf file.
# This runs a python helper script that requires the 'click' package to be installed.
export def "use-profile" [
    name: string@list-profiles # Name of the profile to switch to
] {
  let myCnfPath = if $nu.os-info.name == "windows" {'C:\my.cnf'} else {'~/.my.cnf'}
  let pythonHelperPath = $env.FILE_PWD | path.join "mysql-profile.py"
  python $pythonHelperPath use $name
}

# Show the tables in the database
export def "tables" [] {
  (mysql -e 'show tables' --batch) | from tsv | rename table
}

# Get the table values for completions
def "tableCompletion" [] {
    tables | get table
}


export def "columns" [
    table: string@tableCompletion # Name of the table to retrieve values for
] {
    # TODO: run an introspection query to get the columns for the table
    # This needs to get teh table schema name out of the .my.cnf profile
    # mysqlsh --sql -e $"SELECT `COLUMN_NAME` FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`='($schema)' AND `TABLE_NAME`='($table)';" --json | from json | get rows
}

# Query rows in the given table. The --limit param returns the first N rows.
# You could also do limiting with nushell "| where" clauses but table is
# eager ATM and so this would fetch all rows only to discard some later on client side.
export def "table" [
    table_name: string@tableCompletion # Name of the table to retrieve values for
    --limit (-l): int # Number of rows to return. Pass 0 to return all.
    --offset (-o): int # Number of rows to skip
] {
    let baseQuery = $"select * from ($table_name)"
    let withOptionalLimit = if $limit > 0 { $"($baseQuery) limit ($limit)" } else { baseQuery }
    let withOptionalOffset = if $offset > 0 { $"($withOptionalLimit) offset ($offset)" } else { withOptionalLimit }
    (mysqlsh --sql -e $"($withOptionalOffset)" --json) | from json | get rows
}

# Run a query against the database
export def "sql" [sql] {
  (mysqlsh --sql -e $sql --json) | from json | get rows
}

export def main [] {

}