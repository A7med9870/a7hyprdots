#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <video_file_path>"
    echo "Example: $0 /home/ahmed/Videos/Video_2025-10-25_21-37-35.mp4"
    exit 1
fi

# Get the input file path
original_file="$1"

# Check if file exists
if [ ! -f "$original_file" ]; then
    echo "Error: File '$original_file' does not exist!"
    exit 1
fi

# Extract directory, filename without extension, and extension
file_dir=$(dirname "$original_file")
file_name=$(basename "$original_file")
file_base="${file_name%.*}"
file_ext="${file_name##*.}"

# Generate output filename
output_file="${file_dir}/${file_base}_compressed.${file_ext}"

# Get the original modification time
original_mtime=$(stat -c %y "$original_file")

echo "Compressing: $original_file"
echo "Output file: $output_file"

# Compress with GPU and EXIF data
ffmpeg -hwaccel cuda -i "$original_file" \
-c:v h264_nvenc -preset fast -rc vbr -b:v 400k -maxrate 600k \
-bufsize 800k -c:a aac -b:a 96k \
-movflags use_metadata_tags -map_metadata 0 \
"$output_file"

# Check if compression was successful
if [ $? -eq 0 ]; then
    # Copy over the original modification and creation timestamps
    touch -d "$original_mtime" "$output_file"
    echo "Compression completed successfully!"
else
    echo "Error: Compression failed!"
    exit 1
fi
