#!/bin/bash
screenshot_dir="/home/ahmed/Pictures/Screenshots"
mkdir -p "$screenshot_dir"

geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

filename="$screenshot_dir/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

# Check if geometry is valid (not empty and contains numbers)
if [[ "$geometry" =~ [0-9] ]] && [[ ! -z "$geometry" ]]; then
    grim -g "$geometry" "$filename"
    wl-copy < "$filename"
else
    notify-send "Screenshot Error" "Could not get active window geometry"
    exit 1
fi

if [[ -f "$filename" ]]; then
    notify-send "Screenshot Saved" "Screenshot saved to $filename"
fi
