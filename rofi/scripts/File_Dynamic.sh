#!/usr/bin/env bash

set -euo pipefail

# Extract bookmarked locations from user-places.xbel
# Remove 'file://' prefix and filter out non-file URLs
bookmarks=$(grep -o 'href="[^"]*"' /home/$USER/.local/share/user-places.xbel | \
            cut -d'"' -f2 | \
            grep '^file://' | \
            sed 's#^file://##' | \
            sort -u)

# Convert bookmarks into arrays for options and actions
declare -A actions=()
options=()

while IFS= read -r path; do
    if [[ -n "$path" && -e "$path" ]]; then
        # Use basename as the display name
        name="$(basename "$path")"

        # Make name unique if duplicates exist
        counter=1
        original_name="$name"
        while [[ -n "${actions[$name]+isset}" ]]; do
            name="${original_name}_${counter}"
            ((counter++))
        done

        # Add to arrays
        options+=("$name")
        actions["$name"]="dolphin \"$path\""
    fi
done <<< "$bookmarks"

# Fallback to default locations if no bookmarks found
if [[ ${#options[@]} -eq 0 ]]; then
    declare -A actions=(
        [Home]="dolphin /home/$USER/"
        [Downloads]="dolphin /home/$USER/Downloads/"
        [Documents]="dolphin /home/$USER/Documents/"
        [Desktop]="dolphin /home/$USER/Desktop/"
        [Videos]="dolphin /home/$USER/Videos/"
        [recordings]="dolphin /home/$USER/recordings/"
        [Pictures]="dolphin /home/$USER/Pictures/"
        [Music]="dolphin /home/$USER/Music/Amuso/"
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
fi

# Rofi themes - ENABLED inputbar for search
theme_keybinds='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: true;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
theme_waybar='configuration {show-icons: false;} window {location: north west; x-offset: 4; y-offset: 2; width: 250px;} inputbar {enabled: true;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
    theme="$theme_waybar"
else
    theme="$theme_keybinds"
fi

# Show rofi menu with search enabled - ADDED -i flag for case-insensitive search
chosen=$(printf "%s\n" "${options[@]}" | rofi -dmenu \
                                              -i \
                                              -p "Search bookmarks:" \
                                              -theme-str "$theme")

# Execute the chosen action
if [[ -n "$chosen" && "${actions[$chosen]+isset}" ]]; then
    eval "${actions[$chosen]}"
fi
