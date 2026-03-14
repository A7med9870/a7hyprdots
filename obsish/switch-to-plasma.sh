#!/bin/bash

# Ensure the script is run as user (not root)
if [ "$(id -u)" -eq 0 ]; then
    echo "This script should NOT be run as root. Run it as your normal user." >&2
    exit 1
fi

# Set Plasma as the default session for SDDM
echo "[Desktop]
Session=plasma.desktop" | sudo tee /etc/sddm.conf.d/10-plasma.conf > /dev/null

# Alternatively, modify the user-specific SDDM config (if needed)
mkdir -p ~/.config/sddm
echo "[Desktop]
Session=plasma.desktop" > ~/.config/sddm.conf

# Restart SDDM to apply changes immediately
sudo systemctl restart sddm

# Log out from Hyprland (if still running)
if pgrep -x "Hyprland" > /dev/null; then
    pkill Hyprland
fi
