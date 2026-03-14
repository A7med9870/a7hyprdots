#!/bin/bash

# Check if the first argument (folder path) is not provided or is empty
if [ -z "$1" ]; then
    # Display usage instructions if no folder path provided
    echo "Usage: $0 /path/to/video/folder [delay_milliseconds] [video_bitrate]"
    echo "Example: $0 /path/to/folder 1500 5M"
    echo "Example: $0 /path/to/folder -200 2000k"
    echo "Example: $0 /path/to/folder 0 8M"
    echo "Bitrate examples: 5M (5 Mbps), 2000k (2000 kbps), 8M (8 Mbps)"
    exit 1  # Exit script with error code 1
fi

# Store the first argument as the folder path
FOLDER_PATH="$1"
# Extract just the folder name from the full path
FOLDER_NAME=$(basename "$FOLDER_PATH")
# Store second argument (audio delay) or default to 0 if not provided
DELAY_MS="${2:-0}"  # Default to 0 if not provided
# Store third argument (bitrate) or default to 0 if not provided
BITRATE="${3:-0}"   # Default to 0 (copy original) if not provided

# Extract date and time from folder name using regex pattern matching
# Pattern looks for: bg_ followed by numbers, then YYYYMMDD_HHMMSS format
if [[ $FOLDER_NAME =~ bg_[0-9]+_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
    # Extract year from regex match group 1
    YEAR="${BASH_REMATCH[1]}"
    # Extract month from regex match group 2
    MONTH="${BASH_REMATCH[2]}"
    # Extract day from regex match group 3
    DAY="${BASH_REMATCH[3]}"
    # Extract hour from regex match group 4
    HOUR="${BASH_REMATCH[4]}"
    # Extract minute from regex match group 5
    MINUTE="${BASH_REMATCH[5]}"
    # Extract second from regex match group 6
    SECOND="${BASH_REMATCH[6]}"

    # Create proper timestamp string for touch command
    # Format: [[CC]YY]MMDDhhmm[.ss] - used by the touch command
    TIMESTAMP="${YEAR}${MONTH}${DAY}${HOUR}${MINUTE}.${SECOND}"

    # Display detected time information
    echo "Detected recording time: $YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND"
    echo "Touch timestamp: $TIMESTAMP"
else
    # Error handling if folder name doesn't match expected pattern
    echo "Error: Could not parse date/time from folder name: $FOLDER_NAME"
    echo "Expected format: bg_GAMEID_YYYYMMDD_HHMMSS"
    exit 1  # Exit script with error code 1
fi

# Check if session.mpd file exists in the specified folder
MPD_FILE="$FOLDER_PATH/session.mpd"
if [ ! -f "$MPD_FILE" ]; then
    # Error if the required input file is missing
    echo "Error: session.mpd not found in $FOLDER_PATH"
    exit 1  # Exit script with error code 1
fi

# Generate output filename - CREATE IN THE SOURCE FOLDER
# Format: recorded_YYYYMMDD_HHMMSS.mp4
OUTPUT_FILE="$FOLDER_PATH/recorded_${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}.mp4"

# Display conversion information
echo "Converting MPD to MP4..."
echo "Output file: $OUTPUT_FILE"
echo "Audio delay: $DELAY_MS milliseconds"
echo "Video bitrate: ${BITRATE:-'copy original'}"

# Build base ffmpeg command as an array for proper argument handling
# -y: overwrite output file without asking
# -hwaccel cuda: use NVIDIA GPU acceleration
# -i: input file
FFMPEG_CMD=(-y -hwaccel cuda -i "$MPD_FILE")

# Add video encoding options based on bitrate setting
if [ "$BITRATE" != "0" ] && [ -n "$BITRATE" ]; then
    # If custom bitrate is specified, use NVIDIA h264 encoder with that bitrate
    echo "Using custom bitrate: $BITRATE"
    FFMPEG_CMD+=(-c:v h264_nvenc -b:v "$BITRATE")
else
    # If no bitrate specified, copy the original video stream without re-encoding
    echo "Copying original video bitrate"
    FFMPEG_CMD+=(-c:v copy)
fi

# Add audio options based on delay value
if [ "$DELAY_MS" -eq 0 ]; then
    # No delay needed - copy original audio stream
    echo "No audio delay applied"
    FFMPEG_CMD+=(-c:a copy)
elif [ "$DELAY_MS" -gt 0 ]; then
    # Positive delay - audio needs to be delayed
    echo "Applying audio delay of $DELAY_MS ms"
    # Convert to AAC and apply delay filter (both channels delayed equally)
    FFMPEG_CMD+=(-c:a aac -af "adelay=$DELAY_MS|$DELAY_MS")
else
    # Negative delay - audio needs to come earlier (video is delayed instead)
    # Calculate absolute value of the negative delay
    ABS_DELAY_MS=$(( -DELAY_MS ))
    # Convert milliseconds to seconds with 3 decimal places
    DELAY_SEC=$(awk "BEGIN {printf \"%.3f\", $ABS_DELAY_MS/1000}")
    echo "Applying negative delay: audio earlier by $ABS_DELAY_MS ms (delaying video by $DELAY_SEC seconds)"

    # For negative delays, use different approach with two inputs:
    # - First input: video stream with time offset (delayed)
    # - Second input: audio stream without delay
    ffmpeg -y \                    # Overwrite output file
      -hwaccel cuda \             # Use GPU acceleration
      -itsoffset "$DELAY_SEC" \   # Delay the first input stream by specified seconds
      -i "$MPD_FILE" \            # First input (video, delayed)
      -i "$MPD_FILE" \            # Second input (audio, not delayed)
      -map 0:v -map 1:a \         # Use video from first input, audio from second input
      -c:v h264_nvenc \           # Encode video with NVIDIA encoder
      -b:v "$BITRATE" \           # Use specified bitrate
      -c:a copy \                 # Copy audio without re-encoding
      "$OUTPUT_FILE"              # Output file

    # Check if the previous ffmpeg command succeeded ($? contains exit code)
    if [ $? -eq 0 ]; then
        # Set file's modification timestamp to the original recording time
        echo "Setting file timestamp to recording time..."
        touch -t "$TIMESTAMP" "$OUTPUT_FILE"
        # Verify and display the new timestamp
        echo "File timestamp set to: $(stat -c %y "$OUTPUT_FILE")"
        echo "Conversion complete: $OUTPUT_FILE"
    else
        # Error handling if ffmpeg failed
        echo "Error: FFmpeg conversion failed"
        exit 1  # Exit script with error code 1
    fi
    exit 0  # Exit script successfully (only for negative delay case)
fi

# Add output file to the ffmpeg command array (for non-negative delays)
FFMPEG_CMD+=("$OUTPUT_FILE")

# Execute ffmpeg command with all accumulated arguments
echo "Running: ffmpeg ${FFMPEG_CMD[@]}"
ffmpeg "${FFMPEG_CMD[@]}"

# Check if ffmpeg command succeeded
if [ $? -eq 0 ]; then
    # Set file's modification timestamp to the original recording time
    echo "Setting file timestamp to recording time..."
    # Set the file's modification and access time to the recording time
    touch -t "$TIMESTAMP" "$OUTPUT_FILE"

    # Verify the timestamp was set by displaying it
    echo "File timestamp set to: $(stat -c %y "$OUTPUT_FILE")"
    echo "Conversion complete: $OUTPUT_FILE"
else
    # Error handling if ffmpeg failed
    echo "Error: FFmpeg conversion failed"
    exit 1  # Exit script with error code 1
fi
