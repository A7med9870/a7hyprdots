#!/bin/bash

# Set the root directory
root_folder="/run/media/hamada/drivec/Xia_hold_here_downloads/"

# Find all .mp4 files in the folder and its subfolders
find "$root_folder" -type f -name "*.mp4" | while IFS= read -r mp4_file; do
    # Find the corresponding .mkv file
    mkv_file="${mp4_file%.mp4}.mkv"

    # Check if the .mkv file exists
    if [ -f "$mkv_file" ]; then
        # If both .mp4 and .mkv files exist, delete the .mp4 file
        echo "Deleting: $mp4_file"
        rm "$mp4_file"
    else
        echo "No match found for: $mp4_file"
    fi
done
