#!/bin/bash
SCREENSHOT_PATH="$HOME/Pictures/Screenshots/screenshot-$(date +'%Y%m%d-%H%M%S').png"

# Take a screenshot with slurp (to select an area)
grim -g "$(slurp)" "$SCREENSHOT_PATH"
# grim -g "$(slurp)" $HOME/Pictures/Screenshots/screenshot-$(date +'%Y%m%d-%H%M%S').png -QT_QPA_PLATFORM=wayland ksnip $HOME/Pictures/Screenshots/screenshot-$(date +'%Y%m%d-%H%M%S').png

# set screenshot_path "$HOME/Pictures/Screenshots/screenshot-(date +'%Y%m%d-%H%M%S').png"
# grim -g (slurp) $screenshot_path; QT_QPA_PLATFORM=wayland ksnip $screenshot_path

# Set the platform for Ksnip to Wayland and open the screenshot
QT_QPA_PLATFORM=wayland ksnip "$SCREENSHOT_PATH" & notify-send "Scrn shoot been taken"
