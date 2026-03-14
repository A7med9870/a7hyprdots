#!/bin/bash

# Define the file path
# FILE="/etc/sddm.conf.d/kde_settings.conf"
FILE="/etc/sddm.conf"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 with the desired session
sudo sed -i '3s/^Session=.*$/Session=steam/' "$FILE"  # Change "steam" to desired session
echo "Session set to steam in $FILE"

sudo systemctl restart sddm
