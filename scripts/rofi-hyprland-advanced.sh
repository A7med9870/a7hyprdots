#!/bin/bash
action=$(printf "Move Window to Workspace\nBring Window to Workspace\nRename Workspace\nToggle Floating\nToggle Pin\nToggle Fullscreen\nCenter Window" | rofi -dmenu -p "Hyprland")

case "$action" in
    "Move Window to Workspace")
        workspace=$(hyprctl workspaces -j | jq -r '.[] | "\(.id): \(.name)"' | rofi -dmenu -p "Move to")
        [ -n "$workspace" ] && hyprctl dispatch movetoworkspace "$(echo $workspace | cut -d: -f1)"
        ;;
    "Bring Window to Workspace")
        workspace=$(hyprctl workspaces -j | jq -r '.[] | "\(.id): \(.name)"' | rofi -dmenu -p "Bring to")
        [ -n "$workspace" ] && hyprctl dispatch bringactivetoworkspace "$(echo $workspace | cut -d: -f1)"
        ;;
    "Rename Workspace")
        new_name=$(echo "" | rofi -dmenu -p "New Workspace Name")
        [ -n "$new_name" ] && hyprctl dispatch renameworkspace "$(hyprctl activeworkspace -j | jq -r .id)" "$new_name"
        ;;
    "Toggle Floating") hyprctl dispatch togglefloating ;;
    "Toggle Pin") hyprctl dispatch pin ;;
    "Toggle Fullscreen") hyprctl dispatch fullscreen ;;
    "Center Window") hyprctl dispatch centerwindow ;;
esac
