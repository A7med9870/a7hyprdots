#!/bin/bash

# Use current directory
VIDEO_DIR="."

# Find all video files (common extensions included)
mapfile -t VIDEO_FILES < <(find "$VIDEO_DIR" -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.avi" -o \
    -iname "*.mov" -o \
    -iname "*.wmv" -o \
    -iname "*.flv" -o \
    -iname "*.webm" \))

# Check if any videos were found
if [ ${#VIDEO_FILES[@]} -eq 0 ]; then
    echo "No video files found in $PWD or its subdirectories"
    exit 1
fi

# Select a random video
RANDOM_VIDEO="${VIDEO_FILES[RANDOM % ${#VIDEO_FILES[@]}]}"

# Play the video with mpv
echo "Playing: $RANDOM_VIDEO"
mpv "$RANDOM_VIDEO"
