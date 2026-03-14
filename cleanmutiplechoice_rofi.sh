#!/bin/bash
# ~/.config/hypr/scripts/rofi-clean.sh

show_menu() {
    rofi -dmenu -p "$1"
}

# Main menu
main_choice=$(show_menu "Main Menu" << EOF
Copy_Screenshot
Change theme
Apps
EOF
)
[[ -z "$main_choice" ]] && exit 0

# Sub-menus

# Sub-menu 1
case $main_choice in
    "Copy_Screenshot")
        action=$(show_menu "Copy_Screenshot" << EOF
Copy last Screenshot
Reboot
Shutdown
EOF
)
# Sub-menu 1 actions
case $action in
    "Copy last Screenshot") /home/ahmed/.config/hypr/copy_last_screenshot.sh ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac
;;
    "Apps")
        action=$(show_menu "Apps" << EOF
Browser
Terminal
Files
EOF
)
# Sub-menu 3
case $action in
    "Browser") firefox ;;
    "Terminal") kitty ;;
    "Files") thunar ;;
esac
;;
    "Change theme")
        action=$(show_menu "Change theme" << EOF
Screenshot
Audio
Toggle Bar
EOF
)

# Sub-menu 4
case $action in
    "Screenshot") grim -g "$(slurp)" ~/Pictures/screenshot.png ;;
    "Audio") pavucontrol ;;
    "Toggle Bar") hyprctl dispatch togglebar ;;
esac
        ;;
esac
