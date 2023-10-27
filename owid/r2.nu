# Run the "aws s3api" command against the Cloudflare S3-compatible API
# Needs the aws cli tool to be installed and the $env.owid.cfUserId environment variable to be set
export def query [
    ...rest: string # a command like listbuckets. Run with a bogus command to see the full list of commands
] {
    let stdin = $in
    if (($env.owid == null) or ($env.owid.cfUserId == null)) {
        print 'Please set the owid environment variable to a record containing the CF customer id
$env.owid = { cfUserId: "..." }
you can find the cf user id in the Cloudflare dashboard under "My Profile"'
    } else {
        if ((which aws | length) < 1) {
            print "Please install the aws cli tool"
        } else {
            $in | aws s3api --endpoint-url $"https://($env.owid.cfUserId).r2.cloudflarestorage.com" $rest
        }
    }
}

# Lists the R2 buckets
export def buckets [] {
    query list-buckets | from json | get Buckets | sort-by Name | get Name
}

# Lists the objects in a bucket with a given prefix. At most 200 results are returned by default
export def objects [
    bucket: string@buckets
    prefix: string
    maxItems: number = 200
] {
    query list-objects-v2 "--bucket" $bucket "--prefix" $prefix "--max-items" $"($maxItems)"
    | from json
    | get Contents
    | update LastModified { into datetime }
    | update Size { into filesize }
}

export def delete-objects [
    bucket: string@buckets
    --force
]: table<Key: string> -> table {
    let keys = $in
    mut proceed = $force
    mut result = [[Key]; [""]]

    if not $force {
        let count = $keys | length
        print $"(ansi red)This will delete ($count) in the bucket $bucket.(ansi reset) Are you sure? \(y/n\)"
        let answer = (input --numchar 1)
        if $answer != "y" {
            print "Aborting"
            $proceed = false
        } else {
            $proceed = true
        }
    }
    if $proceed {
        let deleted = $keys | { Objects: $in Quiet: true } | to json -r | owid r2 query delete-objects "--bucket" $bucket "--delete" $in | from json
        $result = $deleted.Deleted
    }
    $result
}