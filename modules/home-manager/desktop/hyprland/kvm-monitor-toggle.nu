#!/usr/bin/env nu

let current_config = (hyprctl monitors all -j | from json | where name == "HDMI-A-1" | get 0 | get mirrorOf | into int)

let monitor = if $current_config == 2 {
  "DP-2"
} else {
  "DP-3"
}

hyprctl keyword monitor $"HDMI-A-1, preferred, auto, 1, mirror, ($monitor)"
