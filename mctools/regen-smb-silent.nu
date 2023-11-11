let smb_old_lines = (open -r /etc/samba/smb.conf | lines | take until  { |it| $it == "---REGENERATE---" })
let smb_lines = (
# (ls /media/daniel
#     | where (($it.name | path basename | str length) > 10 )
#     | each { |it| ls $it.name }
#     | flatten
#     | where ($it.name | path basename) =~ "^\\w$"
#     | get name
open /home/daniel/all_drives.yaml
| where {|it| $it.loud? != true }
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