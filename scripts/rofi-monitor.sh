#!/bin/bash
action=$(printf "Move Window to Monitor\nFocus Monitor\nWorkspace to Monitor\nMonitor Layout" | rofi -dmenu -p "Monitors")

case "$action" in
    "Move Window to Monitor")
        monitor=$(hyprctl monitors -j | jq -r '.[] | "\(.name): \(.description)"' | rofi -dmenu -p "Move to Monitor")
        [ -n "$monitor" ] && hyprctl dispatch movewindow mon:"$(echo $monitor | cut -d: -f1)"
        ;;
    "Focus Monitor")
        monitor=$(hyprctl monitors -j | jq -r '.[] | .name' | rofi -dmenu -p "Focus Monitor")
        [ -n "$monitor" ] && hyprctl dispatch focusmonitor "$monitor"
        ;;
    "Workspace to Monitor")
        monitor=$(hyprctl monitors -j | jq -r '.[] | .name' | rofi -dmenu -p "Move Workspace to Monitor")
        [ -n "$monitor" ] && hyprctl dispatch movecurrentworkspacetomonitor "$monitor"
        ;;
    "Monitor Layout")
        layout=$(printf "Left Focus\nRight Focus\nStacked\nMirrored" | rofi -dmenu -p "Layout")
        # This would require custom hyprland configuration per layout
        notify-send "Monitor Layout" "Configure this in your hyprland.conf"
        ;;
esac
