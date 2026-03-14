#!/bin/bash

# Convert Steam DASH clip to MP4
# Usage: ./convert_steam_clip.sh /path/to/clip/directory

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/clip/directory"
    exit 1
fi

CLIP_DIR="$1"
# OUTPUT_DIR="${2:-./converted}"
OUTPUT_DIR="/home/ahmed/Videos"
mkdir -p "$OUTPUT_DIR"

# Find the video directory with MPD file
MPD_FILE=$(find "$CLIP_DIR" -name "session.mpd" | head -n 1)
if [ -z "$MPD_FILE" ]; then
    echo "Error: session.mpd not found"
    exit 1
fi

# Find timeline JSON file
TIMELINE_FILE=$(find "$CLIP_DIR" -name "*.json" -path "*/timelines/*" | head -n 1)
if [ -z "$TIMELINE_FILE" ]; then
    echo "Error: No timeline JSON file found"
    exit 1
fi

# Extract timestamp from JSON
TIMESTAMP=$(jq -r '.daterecorded' "$TIMELINE_FILE")
if [ -z "$TIMESTAMP" ] || [ "$TIMESTAMP" = "null" ]; then
    echo "Error: Could not extract timestamp from timeline file"
    exit 1
fi

VIDEO_DIR=$(dirname "$MPD_FILE")
BASENAME=$(basename "$CLIP_DIR")
OUTPUT_FILE="$OUTPUT_DIR/${BASENAME}.mp4"

echo "Using video directory: $VIDEO_DIR"

# Try using mp4box which handles DASH better
if command -v MP4Box &> /dev/null; then
    echo "Using MP4Box to convert DASH to MP4..."
    MP4Box -dash 0 -out "$OUTPUT_FILE" "$MPD_FILE"
else
    # Fallback to ffmpeg with proper initialization
    echo "Using ffmpeg with initialization segments..."

    # Find initialization segments
    VIDEO_INIT="$VIDEO_DIR/init-stream0.m4s"
    AUDIO_INIT="$VIDEO_DIR/init-stream1.m4s"

    if [ ! -f "$VIDEO_INIT" ]; then
        echo "Error: Video initialization segment not found: $VIDEO_INIT"
        exit 1
    fi

    # Create temporary concatenated files
    echo "Creating temporary video file..."
    cat "$VIDEO_INIT" > "${OUTPUT_FILE}_video.tmp"
    find "$VIDEO_DIR" -name "chunk-stream0-*.m4s" | sort -V | xargs cat >> "${OUTPUT_FILE}_video.tmp"

    if [ -f "$AUDIO_INIT" ]; then
        echo "Creating temporary audio file..."
        cat "$AUDIO_INIT" > "${OUTPUT_FILE}_audio.tmp"
        find "$VIDEO_DIR" -name "chunk-stream1-*.m4s" | sort -V | xargs cat >> "${OUTPUT_FILE}_audio.tmp"

        echo "Merging video and audio..."
        #this line, can be changed around; for reduciing the final video's qulity; might be really useful to use for long ones
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
#         ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -c:v libx264 -crf 28 -preset fast -c:a aac -b:a 96k output.mp4
        rm "${OUTPUT_FILE}_video.tmp" "${OUTPUT_FILE}_audio.tmp"
    else
        echo "No audio found, creating video only..."
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        rm "${OUTPUT_FILE}_video.tmp"
    fi
fi


echo "Setting creation time: $TIMESTAMP"
# Set file modification time using the timestamp
touch -d "@$TIMESTAMP" "$OUTPUT_FILE"

echo "Conversion complete: $OUTPUT_FILE"
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "Creation time: $(date -d "@$TIMESTAMP" "+%Y-%m-%d %H:%M:%S")"
