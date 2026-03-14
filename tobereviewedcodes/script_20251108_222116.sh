#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/video/folder [delay_milliseconds] [video_bitrate]"
    echo "Example: $0 /path/to/folder 1500 5M"
    echo "Example: $0 /path/to/folder -200 2000k"
    echo "Example: $0 /path/to/folder 0 8M"
    echo "Bitrate examples: 5M (5 Mbps), 2000k (2000 kbps), 8M (8 Mbps)"
    exit 1
fi

FOLDER_PATH="$1"
FOLDER_NAME=$(basename "$FOLDER_PATH")
DELAY_MS="${2:-0}"  # Default to 0 if not provided
BITRATE="${3:-0}"   # Default to 0 (copy original) if not provided

# Extract date and time from folder name
if [[ $FOLDER_NAME =~ bg_[0-9]+_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
    YEAR="${BASH_REMATCH[1]}"
    MONTH="${BASH_REMATCH[2]}"
    DAY="${BASH_REMATCH[3]}"
    HOUR="${BASH_REMATCH[4]}"
    MINUTE="${BASH_REMATCH[5]}"
    SECOND="${BASH_REMATCH[6]}"

    # Create proper timestamp string for touch command
    # Format: [[CC]YY]MMDDhhmm[.ss]
    TIMESTAMP="${YEAR}${MONTH}${DAY}${HOUR}${MINUTE}.${SECOND}"

    echo "Detected recording time: $YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND"
    echo "Touch timestamp: $TIMESTAMP"
else
    echo "Error: Could not parse date/time from folder name: $FOLDER_NAME"
    echo "Expected format: bg_GAMEID_YYYYMMDD_HHMMSS"
    exit 1
fi

# Check if session.mpd exists
MPD_FILE="$FOLDER_PATH/session.mpd"
if [ ! -f "$MPD_FILE" ]; then
    echo "Error: session.mpd not found in $FOLDER_PATH"
    exit 1
fi

# Generate output filename - CREATE IN THE SOURCE FOLDER
OUTPUT_FILE="$FOLDER_PATH/recorded_${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}.mp4"

echo "Converting MPD to MP4..."
echo "Output file: $OUTPUT_FILE"
echo "Audio delay: $DELAY_MS milliseconds"
echo "Video bitrate: ${BITRATE:-'copy original'}"

# Build base ffmpeg command
FFMPEG_CMD=(-y -hwaccel cuda -i "$MPD_FILE")

# Add video encoding options
if [ "$BITRATE" != "0" ] && [ -n "$BITRATE" ]; then
    echo "Using custom bitrate: $BITRATE"
    FFMPEG_CMD+=(-c:v h264_nvenc -b:v "$BITRATE")
else
    echo "Copying original video bitrate"
    FFMPEG_CMD+=(-c:v copy)
fi

# Add audio options based on delay
if [ "$DELAY_MS" -eq 0 ]; then
    echo "No audio delay applied"
    FFMPEG_CMD+=(-c:a copy)
elif [ "$DELAY_MS" -gt 0 ]; then
    echo "Applying audio delay of $DELAY_MS ms"
    FFMPEG_CMD+=(-c:a aac -af "adelay=$DELAY_MS|$DELAY_MS")
else
    # Negative delay - audio needs to come earlier
    # We'll delay the video instead using the itsoffset method
    ABS_DELAY_MS=$(( -DELAY_MS ))
    DELAY_SEC=$(awk "BEGIN {printf \"%.3f\", $ABS_DELAY_MS/1000}")
    echo "Applying negative delay: audio earlier by $ABS_DELAY_MS ms (delaying video by $DELAY_SEC seconds)"

    # For negative delays, we need a different approach with two inputs
    ffmpeg -y \
      -hwaccel cuda \
      -itsoffset "$DELAY_SEC" \
      -i "$MPD_FILE" \
      -i "$MPD_FILE" \
      -map 0:v -map 1:a \
      -c:v h264_nvenc \
      -b:v "$BITRATE" \
      -c:a copy \
      "$OUTPUT_FILE"

    # Skip the normal execution for negative delays
    if [ $? -eq 0 ]; then
        echo "Setting file timestamp to recording time..."
        touch -t "$TIMESTAMP" "$OUTPUT_FILE"
        echo "File timestamp set to: $(stat -c %y "$OUTPUT_FILE")"
        echo "Conversion complete: $OUTPUT_FILE"
    else
        echo "Error: FFmpeg conversion failed"
        exit 1
    fi
    exit 0
fi

# Add output file and execute (for non-negative delays)
FFMPEG_CMD+=("$OUTPUT_FILE")

# Execute ffmpeg command
echo "Running: ffmpeg ${FFMPEG_CMD[@]}"
ffmpeg "${FFMPEG_CMD[@]}"

if [ $? -eq 0 ]; then
    echo "Setting file timestamp to recording time..."
    # Set the file's modification and access time to the recording time
    touch -t "$TIMESTAMP" "$OUTPUT_FILE"

    # Verify the timestamp was set
    echo "File timestamp set to: $(stat -c %y "$OUTPUT_FILE")"
    echo "Conversion complete: $OUTPUT_FILE"
else
    echo "Error: FFmpeg conversion failed"
    exit 1
fi
