#!/bin/bash

# Check if an argument (image path) is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <image_path>"
    exit 1
fi

IMAGE_PATH="$1"

# Check if swaybg is running
if pgrep -x "swaybg" > /dev/null; then
    # If swaybg is running, kill it
    pkill -x "swaybg"
fi

# Start swaybg with the specified image and mode
swaybg -i "$IMAGE_PATH" -m fill &
