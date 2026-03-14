#!/usr/bin/env bash

set -euo pipefail
uptime="$(uptime -p | sed -e 's/up //g')"

declare -A actions=(
  [Plasma]="konsole -e ~/.config/hypr/Switch_DE/switch_session_toplasma.sh"
  [Steam]="konsole -e ~/.config/hypr/Switch_DE/switch_session_to_steam.sh"
  [Hyprland]="konsole -e ~/.config/hypr/Switch_DE/switch_session_to_hyprland.sh"
)

options=("Plasma" "Steam" "Hyprland")
# options=("Shutdown" "Reboot" "Gamemode" "Gamemode_of" "Clear Cipborad" "Record_audio")
# options=("Shutdown" "Reboot" "Suspend" "Log Out")

theme_keybinds='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

theme_waybar='configuration {show-icons: false;} window {location: north west; x-offset: 4; y-offset: 2; width: 250px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
    theme="$theme_waybar"
else
    theme="$theme_keybinds"
fi

chosen=$(printf "%s\n" "${options[@]}" | rofi -dmenu \
                                              -mesg "Uptime: $uptime" \
                                              -theme-str "$theme")

if [[ -n "$chosen" && "${actions[$chosen]+isset}" ]]; then
  ${actions[$chosen]}
fi
