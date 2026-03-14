##!/bin/bash
#
## Set the root directory
#root_folder="/run/media/hamada/drivec/Videos/Hot Dogs Horseshoes & Hand Grenades/"
#
## Loop through all .mp4 files in the root folder and its subfolders
#find "$root_folder" -type f -name "*.mp4" | while IFS= read -r file; do
#    # Create output file name with .mkv extension
#    output="${file%.mp4}.mkv"
#
#    # Run ffmpeg command
#    ffmpeg -i "$file" -vf scale=-1:720 -c:v libx264 -preset veryslow -crf 32 -map_metadata 0 -c:a copy "$output"
#
#    # Set the output file's timestamp to match the original file
#    touch -r "$file" "$output"
#
#    # Set the creation date of the output file to match the original file
#    creation_time=$(stat -c %W "$file")
#    if [ "$creation_time" -gt 0 ]; then
#        setfattr -n user.creation_time -v "$creation_time" "$output"
#    fi
#done
#
#!/bin/bash

# Set the root directory
#root_folder="/run/media/hamada/drivec/Videos/Hot Dogs Horseshoes & Hand Grenades/"
#
## Loop through all .mp4 files in the root folder and its subfolders
#find "$root_folder" -type f -name "*.mp4" | while IFS= read -r file; do
#    # Create output file name with .mkv extension
#    output="${file%.mp4}.mkv"
#
#    # Run ffmpeg command (overwrite any existing .mkv file)
#    ffmpeg -n -i "$file" -vf scale=-1:720 -c:v libx264 -preset veryslow -crf 32 -map_metadata 0 -c:a copy "$output"
#
#    # Set the output file's timestamp to match the original file
#    touch -r "$file" "$output"
#
#    # Set the creation date of the output file to match the original file
#    creation_time=$(stat -c %W "$file")
#    if [ "$creation_time" -gt 0 ]; then
#        setfattr -n user.creation_time -v "$creation_time" "$output"
#    fi
#done
#!/bin/bash

# Set the root directory
root_folder="/run/media/drivec/Sync_W11/Phone_movies/"

# Find all .mp4 files in the folder and its subfolders
files=$(find "$root_folder" -type f -name "*.mp4")
total_files=$(echo "$files" | wc -l)
processed_count=0

# Loop through each file
echo "$files" | while IFS= read -r file; do
    processed_count=$((processed_count + 1))
    # Create output file name with .mkv extension
    output="${file%.mp4}.mkv"

    # Run ffmpeg command with GPU acceleration (NVIDIA GPU in this example)
    ffmpeg -n -i "$file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 40 -map_metadata 0 -c:a copy "$output"

    if [ -f "$output" ]; then
        # Set the output file's timestamp to match the original file
        touch -r "$file" "$output"

        # Set the creation date of the output file to match the original file
        creation_time=$(stat -c %W "$file")
        if [ "$creation_time" -gt 0 ]; then
            setfattr -n user.creation_time -v "$creation_time" "$output"
        fi
    else
        echo "Skipped: $output already exists."
    fi

    # Send notification with progress
    notify-send "Processing Complete" "$processed_count/$total_files videos processed"
done
