#!/bin/bash

# Check if a directory was provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/target/directory/"
    echo "Example: $0 /run/media/hamada/drivec/Videos/"
    exit 1
fi

# Use the first argument as the root directory
root_folder="$1"

# Remove trailing slash if present for consistency
root_folder="${root_folder%/}"

# Check if the directory exists
if [ ! -d "$root_folder" ]; then
    echo "Error: Directory '$root_folder' does not exist or is not accessible"
    exit 1
fi

echo "Processing directory: $root_folder"

# Find all .mp4 files in the folder and its subfolders
files=$(find "$root_folder" -type f -name "*.mp4")
total_files=$(echo "$files" | wc -l)

if [ "$total_files" -eq 0 ]; then
    echo "No .mp4 files found in '$root_folder'"
    exit 0
fi

echo "Found $total_files .mp4 files to process"

processed_count=0

# Loop through each file
echo "$files" | while IFS= read -r file; do
    processed_count=$((processed_count + 1))
    echo "Processing [$processed_count/$total_files]: $(basename "$file")"

    # Create output file name with .mkv extension
    output="${file%.mp4}.mkv"

    # Skip if output file already exists
    if [ -f "$output" ]; then
        echo "Skipped: $output already exists."
        continue
    fi

    # Run ffmpeg command with GPU acceleration (NVIDIA GPU in this example)
    ffmpeg -n -i "$file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 32 -map_metadata 0 -c:a copy "$output"

    if [ -f "$output" ]; then
        # Set the output file's timestamp to match the original file
        touch -r "$file" "$output"

        # Set the creation date of the output file to match the original file
        creation_time=$(stat -c %W "$file" 2>/dev/null)
        if [ -n "$creation_time" ] && [ "$creation_time" -gt 0 ] 2>/dev/null; then
            setfattr -n user.creation_time -v "$creation_time" "$output" 2>/dev/null
        fi
        echo "Created: $output"
    else
        echo "Failed to create: $output"
    fi

    # Send notification with progress
    notify-send "Video Processing" "Completed: $processed_count/$total_files\nCurrent: $(basename "$file")"
done

echo "Processing complete!"
