#!/bin/bash

# Directories to search
DIRS=(
    "/home/ahmed/Pictures/Linuxpc_scrn/"
    "/home/ahmed/Pictures/Laptopscreensshots"
    "/home/ahmed/Pictures/Scrn_Shoots_Phone"
    "/home/ahmed/Pictures/Older_laptop_scrns"
    "/home/ahmed/Pictures/PcScreenShots"
    "/home/ahmed/Pictures/Quest_scrn"
    "/home/ahmed/Cameraxio/Camera/"
)

# Find all image files in the directories, sort by newest first
# Use process substitution to handle spaces in filenames correctly
while IFS= read -r file; do
    # For Rofi to show icons, we need to output with null termination or special format
    # This format tells Rofi this is a file path that should have an icon
    printf "%s\0icon\x1f%s\n" "$(basename "$file")" "$file"
done < <(find "${DIRS[@]}" -type f \( \
    -iname "*.png" -o \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.gif" -o \
    -iname "*.bmp" -o \
    -iname "*.webp" -o \
    -iname "*.jxl" -o \
    -iname "*.svg" \) \
    -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-) | \
rofi -dmenu \
  -theme "$HOME/.config/hypr/rofi/themes/fullscreen-preview.rasi" -i \
  -show-icons \
  -markup-rows \
  -format 's' | \
while read -r selected_name; do
    if [ -n "$selected_name" ]; then
        # Find the full path for the selected filename
        full_path=$(find "${DIRS[@]}" -type f -name "$selected_name" | head -n1)
        if [ -n "$full_path" ]; then
            xdg-open "$full_path"
        fi
    fi
done
