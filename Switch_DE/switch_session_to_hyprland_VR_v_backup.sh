#!/bin/bash

# Define the file path
FILE="/etc/sddm.conf.d/kde_settings.conf"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 with the desired session
sudo sed -i '3s/^Session=.*$/Session=plasma.desktop/' "$FILE"
echo "Session set to plasma.desktop in $FILE"

sleep 3 && notify-send "KDE CONNECT INT"

sudo systemctl restart sddm
# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Use sed to replace line 3 with the desired session
sudo sleep 5 && sed -i '3s/^Session=.*$/Session=hyprland/' "$FILE"
