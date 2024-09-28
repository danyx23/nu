export def mount-files [] {
    0..
    | each { char --integer (77 + $in) } | take until {|it| $it > 'Z'}
    | each { |it| mount_smbfs $"//daniel@files/($it)" $"/Users/teresamarenzi/Network/($it)" }
}