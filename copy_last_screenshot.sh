#!/bin/bash

# Define the directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots/"

# Get the most recently modified file
latest_file=$(ls -t "$SCREENSHOT_DIR" | head -n 1)

# Full path of the file
file_path="$SCREENSHOT_DIR$latest_file"

# Copy the file to clipboard (using wl-copy for Wayland)
if command -v wl-copy &> /dev/null; then
    # Copy the image content to clipboard as an image (mime type image/png)
    wl-copy --type image/png < "$file_path"
else
    echo "Error: wl-copy not installed."
    exit 1
fi

# Display the notification with the file name
notify-send "File copied to clipboard" "$latest_file"
