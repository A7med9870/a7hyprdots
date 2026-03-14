#!/bin/bash

# Directory to save recordings
RECORDINGS_DIR="/home/$USER/recordings"

# Create directory if it doesn't exist
mkdir -p "$RECORDINGS_DIR"

# Generate timestamp (YYYY_MM_DD_HHMM)
TIMESTAMP=$(date +"%Y_%m_%d_%H%M")

# Base filename
FILENAME="audio_${TIMESTAMP}"

# Check if file exists, append _01, _02, etc.
if [[ -e "$RECORDINGS_DIR/$FILENAME.wav" ]]; then
    COUNT=1
    while [[ -e "$RECORDINGS_DIR/$FILENAME_$(printf '%02d' $COUNT).wav" ]]; do
        ((COUNT++))
    done
    FILENAME="${FILENAME}_$(printf '%02d' $COUNT)"
fi

# Full file path
FULL_PATH="$RECORDINGS_DIR/$FILENAME.wav"

# Record with ffmpeg
echo "Recording to: $FULL_PATH"
echo "Press Ctrl+C to stop."
ffmpeg -f alsa -i default "$FULL_PATH"
