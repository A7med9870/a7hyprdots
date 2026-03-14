#!/bin/bash

# Check if no command line arguments were provided
if [ $# -eq 0 ]; then
    # No input from user - try to use wl-paste
    input_file="$(wl-paste)"

    # Check if wl-paste returned empty content
    if [ -z "$input_file" ]; then
        echo "Error: No command line argument provided and clipboard is empty"
        echo "Usage: $0 /path/to/video.mp4"
        echo "Example: $0 /home/ahmed/Videos/Replay_2026-02-11_19-46-04.mp4"
        exit 1
    else
        echo "Using clipboard content: $input_file"
    fi
else
    # User provided a command line argument - use that instead
    input_file="$1"
    echo "Using provided argument: $input_file"
fi

# Check if the file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' does not exist or is not accessible"
    exit 1
fi

# Check if it's an MP4 file (case insensitive)
if [[ ! "$input_file" =~ \.[Mm][Pp]4$ ]]; then
    echo "Warning: File is not an .mp4 file. Proceeding anyway..."
fi

echo "Processing file: $input_file"

# Create output file name with _com.mp4 suffix
output_file="${input_file%.mp4}_com.mp4"
# Handle case-insensitive extension
if [[ "$output_file" == "$input_file" ]]; then
    # If the extension wasn't .mp4, try removing .MP4
    output_file="${input_file%.MP4}_com.mp4"
fi
# If still no change, just add _com.mp4
if [[ "$output_file" == "$input_file" ]]; then
    output_file="${input_file}_com.mp4"
fi

# Skip if output file already exists
if [ -f "$output_file" ]; then
    echo "Error: Output file '$output_file' already exists."
    echo "Remove it first or choose a different input file."
    exit 1
fi

echo "Output file: $output_file"

# Run ffmpeg command with GPU acceleration (NVIDIA GPU in this example)
# ffmpeg -n -i "$input_file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 32 -map_metadata 0 -c:a aac -b:a 128k "$output_file"
ffmpeg -n -i "$input_file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 40 -b:v 1000k -maxrate 3200k -bufsize 600k -map_metadata 0 -c:a copy "$output_file"
# ffmpeg -n -i "$input_file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 40 -b:v 300k -maxrate 400k -bufsize 600k -map_metadata 0 -c:a copy "$output_file"
# ffmpeg -n -i "$input_file" -vf scale=-1:144 -c:v h264_nvenc -preset fast -crf 40 -map_metadata 0 -c:a aac -b:a 128k "$output_file"
# ffmpeg -n -i "$input_file" -vf scale=-1:360 -c:v h264_nvenc -preset fast -crf 40 -map_metadata 0 -c:a aac -b:a 128k "$output_file"
# ffmpeg -n -i "$input_file" -vf scale=-1:720 -c:v h264_nvenc -preset fast -crf 32 -map_metadata 0 -c:a aac -b:a 128k "$output_file"

if [ -f "$output_file" ]; then
    # Set the output file's timestamp to match the original file
    touch -r "$input_file" "$output_file"

    # Set the creation date of the output file to match the original file
    creation_time=$(stat -c %W "$input_file" 2>/dev/null)
    if [ -n "$creation_time" ] && [ "$creation_time" -gt 0 ] 2>/dev/null; then
        setfattr -n user.creation_time -v "$creation_time" "$output_file" 2>/dev/null
    fi

    echo "Successfully created: $output_file"

    # Send notification
    notify-send "Video Processing Complete" "Converted: $(basename "$input_file")\nOutput: $(basename "$output_file")"
else
    echo "Failed to create: $output_file"
    notify-send -u critical "Video Processing Failed" "Failed to convert: $(basename "$input_file")"
    exit 1
fi

echo "Processing complete!"
