#!/bin/bash

# List of files to open
files=(
    ~/.local/share/kxmlgui5/dolphin/dolphinui.rc
    ~/.config/dolphinrc
    ~/.local/share/kxmlgui5/dolphin/dolphinui.rc
    ~/.config/hypr/copy_files.sh
    ~/.config/hypr/mounty.sh
    ~/.config/hypr/hyprlock.conf
    ~/.config/hypr/wallpaper_1.sh
    ~/.config/hypr/copy_last_screenshot.sh
    ~/.config/hypr/open_daily_note.sh
    ~/.config/hypr/s.sh
    ~/.config/hypr/movedown.sh
    ~/.config/hypr/moveright.sh
    ~/.config/hypr/moveleft.sh
    ~/.config/hypr/moveup.sh
    ~/.config/hypr/style.css
    ~/.config/hypr/config.jsonc
    ~/.config/hypr/mocha.css
    ~/.config/hypr/hyprpaper.conf
    ~/.config/hypr/config.rasi
    ~/.config/hypr/toggle_waybar.sh
    ~/.config/hypr/hyprland.conf
)

# Open each file in zeditor
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        # zeditor "$file" &
        konsole -e micro "$file" &
    else
        echo "File not found: $file"
    fi
done
