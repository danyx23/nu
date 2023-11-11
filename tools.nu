export def mount [] {
    ^mount | lines | parse "{device} on {mountpoint} type {fstype} {options}"
}