#!/usr/bin/env bash

set -euo pipefail
uptime="$(uptime -p | sed -e 's/up //g')"

declare -A actions=(
  [Clear Cipborad]="cliphist wipe"
  [Record_audio]="konsole -e ~/.config/hypr/record_audio.sh"
  [Gamemode]="/home/$USER/.config/hypr/gamemode.sh"
  [Swtich_de]="/home/$USER/.config/hypr/rofi/scripts/Swtich_de.sh"
  # [Gamemode]="/usr/bin/konsole -e /home/$USER/.config/hypr/gamemode.sh"
  [Wallpapers]="/home/$USER/.config/hypr/My_wallpapers/Change_wallpaper.sh"
#   [Wallpapers]="/home/$USER/.config/hypr/My_wallpapers/fs.sh"
  # [Gamemode]="~/.config/hypr/gamemode.sh"
  [Color_picker]="hyprpicker -a -r"
  [Random_Background]="/home/$USER/.config/hypr/random_Bg.sh"
  [Change_audio]="/home/$USER/.config/hypr/rofi/scripts/IN_OR_OUT.sh"
  [Video_clipborad]="/home/$USER/.config/hypr/compress_vidclip.sh"
  # [Gamemode_of]="hyprctl reload"
)

options=(
    "Wallpapers"
    "Color_picker"
    "Random_Background"
    "Change_audio"
    "Record_audio"
    "Video_clipborad"
    "Clear Cipborad"
)

theme_keybinds='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
theme_waybar='configuration {show-icons: false;} window {location: north west; x-offset: 4; y-offset: 2; width: 250px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
    theme="$theme_waybar"
else
    theme="$theme_keybinds"
fi

chosen=$(printf "%s\n" "${options[@]}" | rofi -dmenu \
                                              -i \
                                              -theme-str "$theme")

if [[ -n "$chosen" && "${actions[$chosen]+isset}" ]]; then
  ${actions[$chosen]}
fi
