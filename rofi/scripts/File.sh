#!/usr/bin/env bash

set -euo pipefail
uptime="$(uptime -p | sed -e 's/up //g')"

declare -A actions=(
  [Home]="dolphin /home/$USER/"
  [Downloads]="dolphin /home/$USER/Downloads/"
  [Documents]="dolphin /home/$USER/Documents/"
  [Desktop]="dolphin /home/$USER/Desktop/"
  [Videos]="dolphin /home/$USER/Videos/"
  [recordings]="dolphin /home/$USER/recordings/"
  [Pictures]="dolphin /home/$USER/Pictures/"
  [Music]="dolphin /home/$USER/Music/"
  [Hypr]="dolphin /home/$USER/.config/hypr/"
  [Cameraxio]="dolphin /home/$USER/Cameraxio/"
)

options=(
    "home"
    "Downloads"
    "Documents"
    "Desktop"
    "Videos"
    "recordings"
    "Pictures"
    "Music"
    "Cameraxio"
    "Hypr"
)
# options=("Shutdown" "Reboot" "Gamemode" "Gamemode_of" "Clear Cipborad" "Record_audio")
# options=("Shutdown" "Reboot" "Suspend" "Log Out")

# Rofi themes - ENABLED inputbar for search
theme_keybinds='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: true;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
theme_waybar='configuration {show-icons: false;} window {location: north west; x-offset: 4; y-offset: 2; width: 250px;} inputbar {enabled: true;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
    theme="$theme_waybar"
else
    theme="$theme_keybinds"
fi

chosen=$(printf "%s\n" "${options[@]}" | rofi -dmenu \
                                              -i \
                                              -p "Search bookmarks:" \
                                              -theme-str "$theme")

if [[ -n "$chosen" && "${actions[$chosen]+isset}" ]]; then
  ${actions[$chosen]}
fi
