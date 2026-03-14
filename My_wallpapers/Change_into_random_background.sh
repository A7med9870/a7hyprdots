#!/bin/bash

# Directory containing wallpapers
Backgrounds_location="/home/$USER/.config/My_wallpapers/"

# Find all image and video files
mapfile -t BGS < <(find "$Backgrounds_location" -type f \( \
    -iname "*.png" -o \
    -iname "*.jpeg" -o \
    -iname "*.jxl" -o \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.webm" \))

# Check if any files were found
if [ ${#BGS[@]} -eq 0 ]; then
    echo "No wallpaper files found in $Backgrounds_location"
    exit 1
fi

# Select a random file
RANDOM_BG="${BGS[RANDOM % ${#BGS[@]}]}"

# Get file extension to determine type
EXTENSION="${RANDOM_BG##*.}"
EXTENSION="${EXTENSION,,}" # convert to lowercase

# Kill any existing wallpaper processes
killall swaybg 2>/dev/null
killall mpvpaper 2>/dev/null

# Play the selected file based on its type
if [[ "$EXTENSION" == "png" || "$EXTENSION" == "jpeg" || "$EXTENSION" == "jxl" ]]; then
    # echo "Playing image: $RANDOM_BG"
    swaybg -i "$RANDOM_BG" -m fill &
elif [[ "$EXTENSION" == "mp4" || "$EXTENSION" == "mkv" || "$EXTENSION" == "webm" ]]; then
    # echo "Playing video: $RANDOM_BG"
    mpvpaper -vs -o "no-audio loop" all "$RANDOM_BG" &
else
    echo "Unsupported file type: $RANDOM_BG"
    exit 1
fi
