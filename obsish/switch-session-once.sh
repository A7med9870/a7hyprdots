#!/bin/bash
# Set Plasma for the next boot only
echo "[Desktop]" > ~/.config/sddm.conf
echo "Session=plasma.desktop" >> ~/.config/sddm.conf
# Logout
pkill Hyprland
