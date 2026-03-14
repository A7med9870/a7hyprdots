#!/bin/bash

# Directory to search for images
IMAGE_DIR="/home/$USER/.config/My_wallpapers/"

# Find image files (common formats)
IMAGES=$(find "$IMAGE_DIR" -type f -name "*.jxl" 2>/dev/null)
# IMAGES=$(find "$IMAGE_DIR" -type f \( -name "*.jpg" -name "*.jxl" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.jxl" -o -name "*.gif" \) 2>/dev/null)

# Create a temporary file for rofi menu items
TEMP_FILE=$(mktemp)

# Generate menu items with markup for image preview
while IFS= read -r image; do
    if [ -f "$image" ]; then
        echo -e "$(basename "$image")\x00icon\x1f$image"
    fi
done <<< "$IMAGES" > "$TEMP_FILE"

theme_path="$HOME/.config/rofi/themes/fullscreen-preview.rasi"

# Show rofi menu with image previews
SELECTED_LINE=$(cat "$TEMP_FILE" | rofi -theme "$theme_path"    \
    -dmenu -i -p "Select background image" -show-icons)

    # -theme-str 'window {width: 800px;} listview {columns: 5;}'  \
# Clean up temp file
rm -f "$TEMP_FILE"

# Extract just the filename from the selection (before the null character)
if [ -n "$SELECTED_LINE" ]; then
    SELECTED_IMAGE=$(echo "$SELECTED_LINE" | cut -d '' -f 1)
    SELECTED_IMAGE="$IMAGE_DIR/$SELECTED_IMAGE"
fi

# Check if user selected an image
if [ -n "$SELECTED_IMAGE" ] && [ -f "$SELECTED_IMAGE" ]; then
    # Copy image to /tmp
    cp "$SELECTED_IMAGE" /tmp/hyprlock_background.jxl

    # Start hyprlock
    hyprlock

    # Wait for hyprlock to exit, then remove the temp file
    HYPRLOCK_PID=$!
    wait $HYPRLOCK_PID 2>/dev/null

    # Clean up the temporary file
    rm -f /tmp/hyprlock_background.jxl

else
    echo "No image selected or file not found."
    exit 1
fi
