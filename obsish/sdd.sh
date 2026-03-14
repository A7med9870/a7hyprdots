#!/bin/bash

# Ensure not running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user, not root!" >&2
    exit 1
fi

# Set Plasma as the default session
echo "[Desktop]
Session=plasma.desktop" | sudo tee /etc/sddm.conf.d/10-plasma.conf > /dev/null

# Delete SDDM's cached session to force a fresh start
sudo rm -f /var/lib/sddm/.cache/sddm-state.conf

# Restart SDDM (this will log you out)
sudo systemctl restart sddm

# Kill Hyprland if still running
if pgrep -x "Hyprland" > /dev/null; then
    pkill Hyprland
fi
