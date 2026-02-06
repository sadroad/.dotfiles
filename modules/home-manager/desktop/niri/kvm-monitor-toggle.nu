#!/usr/bin/env nu
# KVM Monitor Toggle for Niri using wl-mirror
# Toggles HDMI-A-1 between mirroring DP-2 and DP-3

# Get current state by checking which output is being mirrored
# We store the state in a file since wl-mirror doesn't expose this easily
let state_file = ($nu.temp-path | path join "niri-kvm-state")

# Default to DP-2 if no state file exists
let current = if ($state_file | path exists) {
    open $state_file | str trim
} else {
    "DP-2"
}

# Toggle between DP-2 and DP-3
let next = if $current == "DP-2" { "DP-3" } else { "DP-2" }

# Kill any existing wl-mirror process
ps | where name =~ "wl-mirror" | each { |p| kill $p.pid }

# Start wl-mirror fullscreen on HDMI-A-1, mirroring the next output
# The --fullscreen-output flag puts it on HDMI-A-1
# The output argument is what we're mirroring
wl-mirror $next --fullscreen-output HDMI-A-1 --fullscreen &

# Save the new state
$next | save -f $state_file
