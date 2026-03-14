#!/bin/bash

# Convert Steam DASH clip to MP4
# Usage: ./convert_steam_clip.sh /path/to/clip/directory

# Exit immediately if any command fails
set -e

# Check if user provided at least one argument (the clip directory)
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/clip/directory"
    exit 1
fi

# Store the first argument as the clip directory path
CLIP_DIR="$1"
# Set the output directory to a fixed location
OUTPUT_DIR="/home/ahmed/Videos/converted"
# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Search for the session.mpd file in the clip directory
MPD_FILE=$(find "$CLIP_DIR" -name "session.mpd" | head -n 1)
# Check if MPD file was found
if [ -z "$MPD_FILE" ]; then
    echo "Error: session.mpd not found"
    exit 1
fi

# Search for timeline JSON file in the timelines subdirectory
TIMELINE_FILE=$(find "$CLIP_DIR" -name "*.json" -path "*/timelines/*" | head -n 1)
# Check if timeline file was found
if [ -z "$TIMELINE_FILE" ]; then
    echo "Error: No timeline JSON file found"
    exit 1
fi

# Extract the timestamp from the JSON file using jq
TIMESTAMP=$(jq -r '.daterecorded' "$TIMELINE_FILE")
# Check if timestamp was successfully extracted
if [ -z "$TIMESTAMP" ] || [ "$TIMESTAMP" = "null" ]; then
    echo "Error: Could not extract timestamp from timeline file"
    exit 1
fi

# Get the directory containing the MPD file (video files location)
VIDEO_DIR=$(dirname "$MPD_FILE")
# Get the base name of the clip directory for the output filename
BASENAME=$(basename "$CLIP_DIR")
# Construct the full output file path
OUTPUT_FILE="$OUTPUT_DIR/${BASENAME}.mp4"

# Display which video directory is being used
echo "Using video directory: $VIDEO_DIR"
    if [ -f "$OUTPUT_FILE" ]; then #remove this if statement, if you want to overide the ending video
        echo "Target already exists; Skiping"
        exit 0
    fi
    echo "Using ffmpeg with initialization segments..."

    # Define paths to video and audio initialization segments
    VIDEO_INIT="$VIDEO_DIR/init-stream0.m4s"
    AUDIO_INIT="$VIDEO_DIR/init-stream1.m4s"

    # Check if video initialization segment exists
    if [ ! -f "$VIDEO_INIT" ]; then
        echo "Error: Video initialization segment not found: $VIDEO_INIT"
        exit 1
    fi

    # Create temporary video file by concatenating initialization + data segments
    echo "Creating temporary video file..."
    # Start with initialization segment
    cat "$VIDEO_INIT" > "${OUTPUT_FILE}_video.tmp"
    # Find all video data chunks, sort them numerically, and append to temp file
    find "$VIDEO_DIR" -name "chunk-stream0-*.m4s" | sort -V | xargs cat >> "${OUTPUT_FILE}_video.tmp"

    # Check if audio initialization segment exists
    if [ -f "$AUDIO_INIT" ]; then
        echo "Creating temporary audio file..."
        # Start with audio initialization segment
        cat "$AUDIO_INIT" > "${OUTPUT_FILE}_audio.tmp"
        # Find all audio data chunks, sort them numerically, and append to temp file
        find "$VIDEO_DIR" -name "chunk-stream1-*.m4s" | sort -V | xargs cat >> "${OUTPUT_FILE}_audio.tmp"

        echo "Merging video and audio..."
        # Use ffmpeg to combine video and audio without re-encoding
        # ffmpeg -n -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        # Clean up temporary files
        rm "${OUTPUT_FILE}_video.tmp" "${OUTPUT_FILE}_audio.tmp"
    else
        echo "No audio found, creating video only..."
        # Convert video only without audio
        # ffmpeg -n -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
        # Clean up temporary video file
        rm "${OUTPUT_FILE}_video.tmp"
    fi
    # if [ -f "$AUDIO_INIT" ]; then
    #     echo "Creating temporary audio file..."
    #     # Start with audio initialization segment
    #     cat "$AUDIO_INIT" > "${OUTPUT_FILE}_audio.tmp"
    #     # Find all audio data chunks, sort them numerically, and append to temp file
    #     find "$VIDEO_DIR" -name "chunk-stream1-*.m4s" | sort -V | xargs cat >> "${OUTPUT_FILE}_audio.tmp"

    #     echo "Merging video and audio..."
    #     # Use ffmpeg to combine video and audio without re-encoding
    #     # ffmpeg -n -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
    #     ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -i "${OUTPUT_FILE}_audio.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
    #     # Clean up temporary files
    #     rm "${OUTPUT_FILE}_video.tmp" "${OUTPUT_FILE}_audio.tmp"
    # else
    #     echo "No audio found, creating video only..."
    #     # Convert video only without audio
    #     # ffmpeg -n -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
    #     ffmpeg -y -i "${OUTPUT_FILE}_video.tmp" -c copy -movflags +faststart "$OUTPUT_FILE"
    #     # Clean up temporary video file
    #     rm "${OUTPUT_FILE}_video.tmp"
    # fi
# fi

# Update the file's modification timestamp to match when the clip was recorded
echo "Setting creation time: $TIMESTAMP"
# Set file modification time using the extracted timestamp
touch -d "@$TIMESTAMP" "$OUTPUT_FILE"

# Display completion message and file information
echo "Conversion complete: $OUTPUT_FILE"
# Show the file size in human-readable format
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
# Show the creation time in readable format
echo "Creation time: $(date -d "@$TIMESTAMP" "+%Y-%m-%d %H:%M:%S")"
