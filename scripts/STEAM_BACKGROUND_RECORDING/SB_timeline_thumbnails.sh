#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <json_file>"
    echo "Example: $0 /path/to/timeline_145194020251125_195818.json"
    exit 1
fi

json_file="$1"
json_basename=$(basename "$json_file" .json)
videos_dir=$(dirname "$(dirname "$json_file")")/video

# Check if videos directory exists
if [ ! -d "$videos_dir" ]; then
    echo "Error: Video directory not found: $videos_dir"
    exit 1
fi

# Output directory for thumbnails
OUTPUT_DIR="/run/media/ahmed/drivec/Sync_W11/Steam_rec/thumbnails"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Use python to calculate string similarity (Levenshtein distance)
find_closest() {
    python3 <<EOF
import sys
import os
from pathlib import Path

def levenshtein_distance(s1, s2):
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)

    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row

    return previous_row[-1]

def normalized_similarity(s1, s2):
    max_len = max(len(s1), len(s2))
    if max_len == 0:
        return 1.0
    distance = levenshtein_distance(s1, s2)
    return 1.0 - (distance / max_len)

json_name = "$json_basename"
videos_path = "$videos_dir"
best_match = None
best_similarity = 0

for folder in os.listdir(videos_path):
    folder_path = os.path.join(videos_path, folder)
    if os.path.isdir(folder_path):
        similarity = normalized_similarity(json_name, folder)
        if similarity > best_similarity:
            best_similarity = similarity
            best_match = folder

if best_match:
    print(os.path.join(videos_path, best_match))
EOF
}

echo "Looking for closest matching folder..."
closest_folder=$(find_closest)

if [ -z "$closest_folder" ]; then
    echo "Error: No matching folder found in $videos_dir"
    exit 1
fi

echo ""
echo "Found match:"
echo "JSON file:    $json_file"
echo "Video folder: $closest_folder"
echo ""

# Get similarity details
echo "Similarity details:"
python3 <<EOF
import sys
import os
json_name = "$json_basename"
folder_name = "$(basename "$closest_folder")"
def levenshtein_distance(s1, s2):
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)
    if len(s2) == 0:
        return len(s1)
    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row
    return previous_row[-1]

distance = levenshtein_distance(json_name, folder_name)
max_len = max(len(json_name), len(folder_name))
similarity = 1.0 - (distance / max_len)

print(f"JSON:       {json_name}")
print(f"Folder:     {folder_name}")
print(f"Distance:   {distance}")
print(f"Similarity: {similarity:.2%}")
EOF

echo ""
echo "Looking for video files in: $closest_folder"
echo ""

# Find video files in the folder
video_files=$(find "$closest_folder" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.mpd" -o -name "*.webm" \) | head -1)

if [ -z "$video_files" ]; then
    echo "Error: No video files found in $closest_folder"
    echo "Supported formats: mp4, mkv, avi, mov, webm"
    exit 1
fi

# Take the first video file found
bg_file_location=$(echo "$video_files" | head -1)
video_filename=$(basename "$bg_file_location")

echo "Found video file: $video_filename"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Generate thumbnail filename based on JSON name
thumbnail_name="${json_basename}.jpg"
thumbnail_path="$OUTPUT_DIR/$thumbnail_name"

echo "Thumbnail will be saved as: $thumbnail_name"
echo ""

# Ask for confirmation
# read -p "Do you want to generate thumbnail? (y/N): " -n 1 -r
# echo ""
# if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running ffmpeg..."
    echo "Command: ffmpeg -y -i \"$bg_file_location\" -ss 00:00:01 -vframes 1 -q:v 2 \"$thumbnail_path\" 2>/dev/null || touch \"$thumbnail_path\""
    echo ""

    # Run the ffmpeg command
    ffmpeg -y -i "$bg_file_location" -ss 00:00:01 -vframes 1 -q:v 2 "$thumbnail_path" 2>/dev/null || touch "$thumbnail_path"

    if [ -f "$thumbnail_path" ]; then
        echo "Thumbnail generated successfully!"
        echo "Location: $thumbnail_path"

        # Check if file is empty (ffmpeg might have failed)
        if [ ! -s "$thumbnail_path" ]; then
            echo "Warning: Thumbnail file was created but appears to be empty."
            echo "This could mean ffmpeg failed and an empty file was created as fallback."
        fi
    else
        echo "Error: Failed to create thumbnail."
        exit 1
    fi
# else
#     echo "Operation cancelled."
#     exit 0
# fi
