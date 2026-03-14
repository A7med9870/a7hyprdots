#!/bin/bash

# Audio delay script with EXIF preservation
# Usage: ./audio_delay.sh /path/to/video "delay_in_ms"

if [ $# -ne 2 ]; then
    echo "Usage: $0 /path/to/video \"delay_in_ms\""
    echo "Example: $0 /path/to/video.mp4 \"-200\""
    echo "Example: $0 /path/to/video.mkv \"+150\""
    exit 1
fi

INPUT_VIDEO="$1"
DELAY_MS="$2"

# Check if input file exists
if [ ! -f "$INPUT_VIDEO" ]; then
    echo "Error: Input file '$INPUT_VIDEO' not found!"
    exit 1
fi

# Extract filename and extension
FILENAME=$(basename -- "$INPUT_VIDEO")
EXTENSION="${FILENAME##*.}"
NAME="${FILENAME%.*}"

# Output filename
OUTPUT_VIDEO="${NAME}_delayed.${EXTENSION}"

# Convert ms to seconds for ffmpeg (using awk instead of bc)
if [[ $DELAY_MS == -* ]]; then
    # Negative delay (audio needs to come earlier)
    DELAY_SEC=$(echo "${DELAY_MS#-}" | awk '{print $1 / 1000}')
    echo "Processing: $INPUT_VIDEO"
    echo "Audio delay: $DELAY_MS ms ($DELAY_SEC seconds)"
    echo "Output: $OUTPUT_VIDEO"

    echo "Step 1: Applying audio delay and copying metadata..."
    ffmpeg -i "$INPUT_VIDEO" \
        -itsoffset "$DELAY_SEC" \
        -i "$INPUT_VIDEO" \
        -map 1:v -map 0:a \
        -c:v copy \
        -c:a copy \
        -movflags use_metadata_tags \
        -map_metadata 0 \
        "$OUTPUT_VIDEO"

else
    # Positive delay (audio needs to come later)
    DELAY_SEC=$(echo "${DELAY_MS#+}" | awk '{print $1 / 1000}')
    echo "Processing: $INPUT_VIDEO"
    echo "Audio delay: $DELAY_MS ms ($DELAY_SEC seconds)"
    echo "Output: $OUTPUT_VIDEO"

    echo "Step 1: Applying audio delay and copying metadata..."
    ffmpeg -i "$INPUT_VIDEO" \
        -itsoffset "$DELAY_SEC" \
        -i "$INPUT_VIDEO" \
        -map 0:v -map 1:a \
        -c:v copy \
        -c:a copy \
        -movflags use_metadata_tags \
        -map_metadata 0 \
        "$OUTPUT_VIDEO"
fi

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Success! Created: $OUTPUT_VIDEO"

    # Verify the output
    echo "Verifying output file..."
    ffprobe -loglevel error -select_streams a -show_entries stream=index,codec_name -i "$OUTPUT_VIDEO" && \
    echo "Output file is valid!"
else
    echo "Error: Processing failed!"
    exit 1
fi
