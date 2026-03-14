#!/bin/bash

# Define the file path
FILE="/etc/sddm.conf.d/kde_settings.conf"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 with the desired session
sudo sed -i '2s/^Relogin=.*$/Relogin=false/' "$FILE"  # Change "steam" to desired session
