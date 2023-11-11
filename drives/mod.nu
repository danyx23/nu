# Connect to the given nas and find all dirs inside /i-data, then find all local disks in /media/daniel and join them up
export def matches [
        nas: string # The name of nas to connect to (nas542 or nas3)
    ] {
  let nas_dirs = (ssh -oHostKeyAlgorithms=+ssh-rsa $"root@($nas)" find /i-data -maxdepth 2 -type d | lines | path parse)
  let mc_dirs = (open ~/all_drives.yaml)
  let joined_dirs = ($mc_dirs| join $nas_dirs drive stem)
  $joined_dirs
}


export def "smb regenerate" [--silent] {
    let smb_old_lines = (open -r /etc/samba/smb.conf | lines | take until  { |it| $it == "---REGENERATE---" })
    let smb_lines = (
    # (ls /media/daniel
    #     | where (($it.name | path basename | str length) > 10 )
    #     | each { |it| ls $it.name }
    #     | flatten
    #     | where ($it.name | path basename) =~ "^\\w$"
    #     | get name
    open ~/all_drives.yaml
    | where {|it| (not $silent) or $it.loud? != true }
    | each {|it| $"[($it.drive)]
    path = ($it.mountpoint | path join $it.drive)
    valid users = daniel
    browsable = yes
    guest_ok = no
    read only = no
    create mask = 0755" }
    | to text
    | lines )
    let all_lines = ($smb_old_lines | append "---REGENERATE---" | append $smb_lines)
    $all_lines | to text | save -f /etc/samba/smb.conf
    systemctl restart samba
    smb_lines
}

export def status [] {
    ls /dev/disk/by-id | where name =~ usb-Terra.*-0:0$ | each { sudo hdparm -C $in.name }
}

export def standby [] {
    ls /dev/disk/by-id | where name =~ usb-Terra.*-0:0$ | each { sudo hdparm -y $in.name }
}

export def mountpoints [] {
    use ../tools.nu mount
    mount | where device =~ "/dev/md" or device =~ "/dev/sdj" | select device mountpoint
}

export def raiddisks [] {
    cat /proc/mdstat | lines | where {|x|  $x =~ "^md\\d{3}+ : active"} | parse "{md} : active {raid} {disk}[0]"
}