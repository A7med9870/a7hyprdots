#!/bin/bash

# Video Cut Script with Filesystem Timestamp Adjustment
# Usage: ./video_cut.sh input_video start_time end_time [output_name]

if [ $# -lt 3 ]; then
    echo "Usage: $0 input_video start_time end_time [output_name]"
    echo "Example: $0 video.mp4 00:01:00 00:02:00"
    echo "Example: $0 video.mp4 00:01:00 00:02:00 my_cut_video"
    exit 1
fi

INPUT_FILE="$1"
START_TIME="$2"
END_TIME="$3"
OUTPUT_NAME="${4:-${INPUT_FILE%.*}_cut}"

# Add .mp4 extension if not provided
if [[ ! "$OUTPUT_NAME" =~ \.[a-zA-Z0-9]+$ ]]; then
    OUTPUT_NAME="${OUTPUT_NAME}.mp4"
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Function to generate unique filename
generate_unique_filename() {
    local filename="$1"
    local counter=1
    local name="${filename%.*}"
    local extension="${filename##*.}"
    local new_filename="$filename"

    while [ -f "$new_filename" ]; do
        new_filename="${name}_${counter}.${extension}"
        counter=$((counter + 1))
    done

    echo "$new_filename"
}

# Generate unique output filename if file already exists
FINAL_OUTPUT_NAME=$(generate_unique_filename "$OUTPUT_NAME")

if [ "$FINAL_OUTPUT_NAME" != "$OUTPUT_NAME" ]; then
    echo "Note: '$OUTPUT_NAME' already exists, using '$FINAL_OUTPUT_NAME' instead"
fi

echo "Cutting video: $INPUT_FILE"
echo "From: $START_TIME to: $END_TIME"
echo "Output: $FINAL_OUTPUT_NAME"

# Get original file's modification time (creation time)
ORIGINAL_TIMESTAMP=$(stat -c %y "$INPUT_FILE")
echo "Original file timestamp: $ORIGINAL_TIMESTAMP"

# Convert start time to seconds for timestamp calculation
START_SECONDS=$(echo "$START_TIME" | awk -F: '{ if (NF == 3) print ($1 * 3600) + ($2 * 60) + $3; else if (NF == 2) print ($1 * 60) + $2; else print $1 }')

# Perform the cut
ffmpeg -i "$INPUT_FILE" \
-ss "$START_TIME" \
-to "$END_TIME" \
-c copy \
-map_metadata 0 \
-movflags use_metadata_tags \
"$FINAL_OUTPUT_NAME"

# Check if successful
if [ $? -eq 0 ]; then
    echo "✓ Successfully created: $FINAL_OUTPUT_NAME"

    # Adjust the filesystem timestamp using touch -d
    # Add the start time offset to the original timestamp
    if command -v date >/dev/null 2>&1; then
        # Calculate new timestamp (original + start time offset)
        NEW_TIMESTAMP=$(date -d "$ORIGINAL_TIMESTAMP + $START_SECONDS seconds" "+%Y-%m-%d %H:%M:%S.%N" 2>/dev/null || date -d "$ORIGINAL_TIMESTAMP + $START_SECONDS seconds" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

        if [ -n "$NEW_TIMESTAMP" ]; then
            echo "Adjusting filesystem timestamp to: $NEW_TIMESTAMP"
            touch -d "$NEW_TIMESTAMP" "$FINAL_OUTPUT_NAME"
        else
            echo "Warning: Could not calculate new timestamp, using original"
            touch -d "$ORIGINAL_TIMESTAMP" "$FINAL_OUTPUT_NAME"
        fi
    else
        echo "Warning: date command not available, using original timestamp"
        touch -d "$ORIGINAL_TIMESTAMP" "$FINAL_OUTPUT_NAME"
    fi

    # Display results
    echo -e "\nFinal file information:"
    echo "Filesystem timestamp: $(stat -c %y "$FINAL_OUTPUT_NAME")"
    echo "File duration:"
    ffmpeg -i "$FINAL_OUTPUT_NAME" 2>&1 | grep "Duration"

else
    echo "✗ Error occurred during processing"
    exit 1
fi
