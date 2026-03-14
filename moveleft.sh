#!/bin/bash
OFFSET_X=-50  # Move 50 pixels to the right
OFFSET_Y=00  # Move 30 pixels down

# Get current cursor position and clean any unwanted characters
CURSOR_POS=$(hyprctl cursorpos | sed 's/,//g')
CUR_X=$(echo $CURSOR_POS | awk '{print $1}')
CUR_Y=$(echo $CURSOR_POS | awk '{print $2}')

# Calculate new position
NEW_X=$((CUR_X + OFFSET_X))
NEW_Y=$((CUR_Y + OFFSET_Y))

# Move cursor to the new position
/usr/bin/hyprctl dispatch movecursor $NEW_X $NEW_Y
