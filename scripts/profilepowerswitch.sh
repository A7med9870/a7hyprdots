#!/bin/bash

# Get current profile
current=$(powerprofilesctl get)

# Create menu options array
options=(
    "Performance$([ "$current" = "performance" ] && echo " ✓")"
    "Balanced$([ "$current" = "balanced" ] && echo " ✓")"
    "Power Saver$([ "$current" = "power-saver" ] && echo " ✓")"
)

# Show rofi menu
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "󰚥 Power Profile")

# Set the selected profile
case "$choice" in
    *"Performance"*)
        powerprofilesctl set performance
        notify-send "Performance Mode" "Maximum performance enabled"
        ;;
    *"Balanced"*)
        powerprofilesctl set balanced
        notify-send "Balanced Mode" "Balanced power profile enabled"
        ;;
    *"Power Saver"*)
        powerprofilesctl set power-saver
        notify-send "Power Saver Mode" "Power saving mode enabled"
        ;;
esac
