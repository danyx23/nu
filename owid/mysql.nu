export def "list-profiles" [] {
  # On Windows the mysql cli and mysqlsh are insane and source from the weirdest, most non-standard places
  # mysql at least takes an $APPDATA/MySQL/.my-login.cnf into account but mysqlsh does not so we are left with
  # resorting to the one on C:\
  let myCnfPath = if $nu.os-info.name == "windows" {'C:\my.cnf'} else {'~/.my.cnf'}
  let pythonHelperPath = $env.FILE_PWD | path.join "mysql-profile.py"
  python $pythonHelperPath list
}

export def "use-profile" [name] {
  let myCnfPath = if $nu.os-info.name == "windows" {'C:\my.cnf'} else {'~/.my.cnf'}
  let pythonHelperPath = $env.FILE_PWD | path.join "mysql-profile.py"
  python $pythonHelperPath use $name
}

export def "tables" [] {
  (mysql -e 'show tables' --batch) | from tsv | rename table
}

export def "tableCompletion" [] {
    tables | get table
}

export def "columns" [
    table: string@tableCompletion # Name of the table to retrieve values for
] {
    # TODO: run an introspection query to get the columns for the table
    # This needs to get teh table schema name out of the .my.cnf profile
    # mysqlsh --sql -e $"SELECT `COLUMN_NAME` FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`='($schema)' AND `TABLE_NAME`='($table)';" --json | from json | get rows
}

export def "table" [
    table_name: string@tableCompletion # Name of the table to retrieve values for
    --limit (-l): int # Number of rows to return. Pass 0 to return all.
] {
    print ($limit | describe)
    let sql = if $limit > 0 { $"select * from ($table_name) limit ($limit)" } else { $"select * from ($table_name)" }
    (mysqlsh --sql -e $"($sql)" --json) | from json | get rows
}

export def "sql" [sql] {
  (mysqlsh --sql -e $sql --json) | from json | get rows
}