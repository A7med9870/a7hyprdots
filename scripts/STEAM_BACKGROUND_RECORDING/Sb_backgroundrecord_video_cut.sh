#!/bin/bash

START=$1
END=$2
VIDEO=$3

# Get original creation time from video metadata
ORIG_TIME=$(ffprobe -v quiet -show_entries format_tags=creation_time -of default=noprint_wrappers=1:nokey=1 "$VIDEO")

# Check if creation_time exists in metadata
if [ -z "$ORIG_TIME" ] || [ "$ORIG_TIME" == "N/A" ]; then
    echo "Warning: No creation_time metadata found in original video"
    echo "Using file modification time instead..."

    # Use file modification time as fallback
    ORIG_EPOCH=$(stat -c %Y "$VIDEO")
else
    echo "Original creation time from metadata: $ORIG_TIME"
    # Convert original time to epoch seconds
    ORIG_EPOCH=$(date -d "$ORIG_TIME" "+%s" 2>/dev/null)

    # If conversion failed, try cleaning the time string
    if [ -z "$ORIG_EPOCH" ]; then
        CLEAN_TIME=$(echo "$ORIG_TIME" | sed 's/\..*//' | sed 's/T/ /' | sed 's/Z//')
        ORIG_EPOCH=$(date -d "$CLEAN_TIME" "+%s" 2>/dev/null)
    fi
fi

# If still no epoch, use current time as final fallback
if [ -z "$ORIG_EPOCH" ]; then
    echo "Warning: Could not parse time, using current time"
    ORIG_EPOCH=$(date "+%s")
fi

# Convert START time to seconds
START_SECONDS=$(echo "$START" | awk -F: '{print $1*3600 + $2*60 + $3}')

# Calculate new epoch time (original + start offset)
NEW_EPOCH=$((ORIG_EPOCH + START_SECONDS))

# Convert to proper formats
NEW_TIME_ISO=$(date -d "@$NEW_EPOCH" -Iseconds)
NEW_TIME_HUMAN=$(date -d "@$NEW_EPOCH" "+%Y-%m-%d %H:%M:%S")
TOUCH_TIME=$(date -d "@$NEW_EPOCH" "+%Y%m%d%H%M.%S")

echo "New creation time: $NEW_TIME_HUMAN"

# Cut video with proper metadata
ffmpeg -i "$VIDEO" -ss "$START" -to "$END" \
    -metadata creation_time="$NEW_TIME_ISO" \
    -c copy \
    "${VIDEO%.*}_cut.mp4"

# Update filesystem time
touch -t "$TOUCH_TIME" "${VIDEO%.*}_cut.mp4"

echo "Video cut completed: ${VIDEO%.*}_cut.mp4"
echo "New creation time set to: $NEW_TIME_HUMAN"
