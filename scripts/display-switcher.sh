#!/bin/bash

# Display Switcher Script for Hyprland with Rofi

# Get monitor names. This assumes your monitors are named like DP-1, HDMI-A-1, etc.
# It filters out the main monitor (which has 'current' mode) to avoid confusion in ordering.
MONITORS=$(hyprctl monitors -j | jq -r '.[] | select(.reserved) | .name' | tr '\n' ' ')
MONITOR_ARRAY=($MONITORS)

# Check if we have at least two monitors
if [ ${#MONITOR_ARRAY[@]} -lt 2 ]; then
    rofi -e "Error: Need at least 2 monitors connected."
    exit 1
fi

# Define the monitors for easier reference
MON1=${MONITOR_ARRAY[0]}
MON2=${MONITOR_ARRAY[1]}

# Menu options presented by Rofi
OPTIONS=(
    "  Mirror Displays ($MON1 = $MON2)"
    "󰍹  Single Monitor ($MON1 only)"
    "󰍺  Single Monitor ($MON2 only)"
    "󰍸  Extend Right ($MON1 -> $MON2)"
    "󰍸  Extend Left ($MON2 -> $MON1)"
    "󰛬  Swap Monitor Order"
)

# Show menu with Rofi
CHOICE=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -p "Display Layout:" -theme-str 'window {width: 30%;}')

# Execute the chosen action
case $CHOICE in
    "  Mirror Displays ($MON1 = $MON2)")
        # Set both monitors to the same position (0x0) with a scale of 1
        hyprctl keyword monitor "$MON1,preferred,0x0,1"
        hyprctl keyword monitor "$MON2,preferred,0x0,1"
        ;;
    "󰍹  Single Monitor ($MON1 only)")
        # Disable MON2, reset MON1 to auto-position
        hyprctl keyword monitor "$MON2,disable"
        hyprctl keyword monitor "$MON1,preferred,auto,1"
        ;;
    "󰍺  Single Monitor ($MON2 only)")
        # Disable MON1, reset MON2 to auto-position
        hyprctl keyword monitor "$MON1,disable"
        hyprctl keyword monitor "$MON2,preferred,auto,1"
        ;;
    "󰍸  Extend Right ($MON1 -> $MON2)")
        # MON1 on the left, MON2 on the right of MON1
        hyprctl keyword monitor "$MON1,preferred,0x0,1"
        hyprctl keyword monitor "$MON2,preferred,auto,1"
        ;;
    "󰍸  Extend Left ($MON2 -> $MON1)")
        # MON2 on the left, MON1 on the right of MON2
        hyprctl keyword monitor "$MON2,preferred,0x0,1"
        hyprctl keyword monitor "$MON1,preferred,auto,1"
        ;;
    "󰛬  Swap Monitor Order")
        # This is a trick: it disables and re-enables the second monitor to make it primary on the left.
        # A more advanced script would track the current resolution to swap them properly.
        hyprctl keyword monitor "$MON2,disable"
        sleep 0.5
        hyprctl keyword monitor "$MON2,preferred,0x0,1"
        ;;
    *)
        # Do nothing if selection is canceled
        exit 0
        ;;
esac
