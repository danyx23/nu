def parseMillisecondTimestamp [ ] { $in | into int | each { $in * 1000 } | into datetime }

export def "load firefox" [
    places_path: string # e.g C:\Users\danyx\AppData\Roaming\Mozilla\Firefox\Profiles\0ok20www.default\places.sqlite
] {
    open $places_path | query db `
    SELECT
     bm.title AS bookmark_title,
     bm.dateAdded,
     bm.lastModified,
     pl.url AS bookmark_url,
     pl.description,
     parent.title AS folder_name,
     parent.folder_type
 FROM moz_bookmarks AS bm
 JOIN moz_places AS pl ON bm.fk = pl.id
 JOIN moz_bookmarks AS parent ON bm.parent = parent.id
 WHERE bm.type = 1 -- 1 indicates a bookmark
 AND parent.type = 2; -- 2 indicates a folder
 ` | update dateAdded { $in | parseMillisecondTimestamp } | update lastModified { $in | parseMillisecondTimestamp }
}

export def "fetch markdown" [
] : string -> string {
    let url_to_fetch = $in
    $url_to_fetch | url parse | $"https://markdown.download/($in.host)($in.path)" | http get $in
}

export def "into yaml" [
] : record -> string {
    let bookmark = $in
    let content = $bookmark.bookmark_url | fetch markdown
    let front_matter = $bookmark | insert "type" { "bookmark" } | to yaml

    $"---\n($front_matter)\n---\n($content)"
}

