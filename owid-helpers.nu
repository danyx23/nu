def tables_by_incoming_foreign_keys [
] {
    owid datasette tables
    | select name foreign_keys.incoming
    | insert incoming_length { |it| $it.foreign_keys_incoming | length }
    | sort-by incoming_length
}