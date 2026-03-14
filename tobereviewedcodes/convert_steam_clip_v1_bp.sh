#!/bin/bash

# Convert Steam DASH clip to MP4
# Usage: ./convert_steam_clip.sh /path/to/clip/directory

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/clip/directory"
    exit 1
fi

CLIP_DIR="$1"
OUTPUT_DIR="${2:-./converted}"
mkdir -p "$OUTPUT_DIR"

# Find the video directory with MPD file
MPD_FILE=$(find "$CLIP_DIR" -name "session.mpd" | head -n 1)
if [ -z "$MPD_FILE" ]; then
    echo "Error: session.mpd not found"
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
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        rm "${OUTPUT_FILE}_video.tmp" "${OUTPUT_FILE}_audio.tmp"
    else
        echo "No audio found, creating video only..."
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        rm "${OUTPUT_FILE}_video.tmp"
    fi
fi

echo "Conversion complete: $OUTPUT_FILE"
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
