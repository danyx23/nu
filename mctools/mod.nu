export def "reports show" [] {
    ls /srv/reports/ | upsert status {|it| $it.name | open | lines | last }
}

export def main [] {

}