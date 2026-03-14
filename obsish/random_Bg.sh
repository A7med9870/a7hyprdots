#!/bin/bash

# Directory containing images
Backgrounds_location="/home/ahmed/.config/hypr/My_wallpapers/"

# Find all image files
mapfile -t BGS < <(find "$Backgrounds_location" -type f \( \
    -iname "*.png" -o \
    -iname "*.jpeg" \))

# Check if any images were found
if [ ${#BGS[@]} -eq 0 ]; then
    echo "No image files found in $Backgrounds_location"
    exit 1
fi

# Select a random image
RANDOM_BG="${BGS[RANDOM % ${#BGS[@]}]}"

# Play the image with swaybg
echo "Playing: $RANDOM_BG"
killall swaybg 2>/dev/null
swaybg -i "$RANDOM_BG" -m fill &
