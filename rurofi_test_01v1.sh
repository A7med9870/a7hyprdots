#!/bin/bash
# ~/.config/hypr/scripts/rofi-function.sh

show_menu() {
    rofi -dmenu -p "$1"
}

get_main_options() {
    echo "System"
    echo "Apps"
    echo "Quick"
}

get_system_options() {
    echo "Lock"
    echo "Reboot"
    echo "Shutdown"
}

get_apps_options() {
    echo "Browser"
    echo "Terminal"
    echo "Files"
}

get_quick_options() {
    echo "Screenshot"
    echo "Audio"
    echo "Toggle Bar"
}

# Main menu
main_choice=$(get_main_options | show_menu "Main Menu")
[[ -z "$main_choice" ]] && exit 0

# Sub-menus
case $main_choice in
    "System")
        action=$(get_system_options | show_menu "System")
        case $action in
            "Lock") hyprlock ;;
            "Reboot") systemctl reboot ;;
            "Shutdown") systemctl poweroff ;;
        esac
        ;;
    "Apps")
        action=$(get_apps_options | show_menu "Apps")
        case $action in
            "Browser") firefox ;;
            "Terminal") kitty ;;
            "Files") thunar ;;
        esac
        ;;
    "Quick")
        action=$(get_quick_options | show_menu "Quick")
        case $action in
            "Screenshot") grim -g "$(slurp)" ~/Pictures/screenshot.png ;;
            "Audio") pavucontrol ;;
            "Toggle Bar") hyprctl dispatch togglebar ;;
        esac
        ;;
esac
