#!/bin/bash

# Directory containing your image files
Backgrounds_location="/home/$USER/.config/My_wallpapers/"

# Get all image files (handle spaces in filenames)
mapfile -d '' BGS < <(find "$Backgrounds_location" -type f -iname "*.jxl" -print0)
# mapfile -d '' BGS < <(find "$Backgrounds_location" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.jxl" \) -print0)

# Check if any images were found
if [ ${#BGS[@]} -eq 0 ]; then
    echo "No image files found in $Backgrounds_location"
    exit 1
fi

# Select a random image file
RANDOM_INDEX=$((RANDOM % ${#BGS[@]}))
FILE_PATH="${BGS[$RANDOM_INDEX]}"
echo "Selected image: $FILE_PATH"

# Copy the image to /tmp/ with a fixed name that matches hyprlock config
TMP_IMAGE="/tmp/hyprlock_background.${FILE_PATH##*.}"
cp "$FILE_PATH" "$TMP_IMAGE"
echo "Copied to: $TMP_IMAGE"

# Give time for the file to be written and hyprlock to detect it
sleep 2

# Run Hyprlock
hyprlock

# Clean up - delete the temporary image
rm -f "$TMP_IMAGE"
echo "Removed temporary image: $TMP_IMAGE"
