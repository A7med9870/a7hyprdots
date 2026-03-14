#!/bin/bash

#!/bin/bash

# Get current date in YY_MM_DD_HH format
current_date=$(date +"%y_%m_%d_%H")

# Define the output file with dynamic name
output_file="$HOME/Documents/obsi/Hypr/${current_date}.md"

# Define the output file
# output_file="$HOME/Documents/obsi/Hypr/25_12_04.md"
# Clear the output file if it already exists
# > "$output_file"

# Function to append file content in the desired format
append_file_content() {
    local file_path="$1"
    # Expand ~ to the full home directory path
    file_path=$(eval echo "$file_path")
    local file_name=$(basename "$file_path")

    echo "$file_name" >> "$output_file"
    echo "---" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    echo "$file_path" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    cat "$file_path" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    echo "---" >> "$output_file"
}

# Append content of each file
append_file_content "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"
append_file_content "~/.config/dolphinrc"
append_file_content "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"
append_file_content "~/.config/hypr/copy_files.sh"
append_file_content "~/.config/hypr/mounty.sh"
append_file_content "~/.config/hypr/hyprlock.conf"
append_file_content "~/.config/hypr/wallpaper_1.sh"
append_file_content "~/.config/hypr/copy_last_screenshot.sh"
append_file_content "~/.config/hypr/open_daily_note.sh"
append_file_content "~/.config/hypr/s.sh"
# append_file_content "~/.config/hypr/movedown.sh"
# append_file_content "~/.config/hypr/moveright.sh"
# append_file_content "~/.config/hypr/moveleft.sh"
# append_file_content "~/.config/hypr/moveup.sh"
append_file_content "~/.config/hypr/style.css"
append_file_content "~/.config/hypr/config.jsonc"
append_file_content "~/.config/hypr/mocha.css"
append_file_content "~/.config/hypr/hyprpaper.conf"
append_file_content "~/.config/hypr/config.rasi"
append_file_content "~/.config/hypr/toggle_waybar.sh"
append_file_content "~/.config/qt5ct/qt5ct.conf"
append_file_content "~/.config/kdeglobals"
append_file_content "~/.config/plasma-org.kde.plasma.desktop-appletsrc"
append_file_content "~/.config/kwinrc"
append_file_content "~/.local/share/konsole/Garuda.profile"
append_file_content "~/.config/konsolerc"
append_file_content "~/.config/fish/config.fish"
append_file_content "~/.config/fish/fish_variables"
append_file_content "~/.config/autostart/"
append_file_content "~/.config/gtk-3.0/settings.ini"
append_file_content "~/.config/menus/applications.menu"
append_file_content "~/.config/syncthingtray.ini"
append_file_content "~/.config/spectaclerc"
append_file_content "~/.config/ksnip/ksnip.conf"
append_file_content "~/.config/xdg-desktop-portal/hyprland-portals.conf"
append_file_content "~/.bashrc"
append_file_content "/etc/default/grub"
append_file_content "~/.config/mimeapps.list"
append_file_content "/etc/sddm.conf"
append_file_content "~/.local/share/user-places.xbel"
# append_file_content "~/.config/steam-rom-manager/"
append_file_content "~/.config/hypr/hyprland.conf"
# append_file_content "~/.firedragon/u9vyvtik.default-release/prefs.js"
# append_file_content "~/.config/hypr/moveup.sh"  # This will now work!

echo "File content has been copied to $output_file" && notify-send "${current_date}.md updated in obsi"
