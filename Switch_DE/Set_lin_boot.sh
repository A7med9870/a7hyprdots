#!/bin/bash

# Define the file path
FILE="/etc/default/grub"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 with the desired session
sudo sed -i '3s/^GRUB_DEFAULT=.*$/GRUB_DEFAULT="0"/' "$FILE"  # Change "steam" to desired session

sudo update-grub
# echo "Session set to hyprland in $FILE"
notify-send "Set linux as default boot OS"
# sudo systemctl restart sddm
