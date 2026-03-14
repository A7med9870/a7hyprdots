#!/bin/bash

# Define the file path
FILE="/etc/sddm.conf.d/kde_settings.conf"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 if it matches "Session=hyprland"
sudo sed -i '3s/^Session=plasma.desktop$/Session=hyprland/' "$FILE"

echo "Session switched from plasma.desktop to hyprland in $FILE"
