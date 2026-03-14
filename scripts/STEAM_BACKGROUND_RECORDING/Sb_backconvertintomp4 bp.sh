#!/bin/bash

# Check if the first argument (folder path) is not provided or is empty
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/video/folder [delay_milliseconds] [video_bitrate] [/path/to/timeline/]"
    echo "Example: $0 /path/to/folder 1500 5M /path/to/timeline/"
    echo "Example: $0 /path/to/folder -200 2000k"
    echo "Example: $0 /path/to/folder 0 8M /path/to/timeline/"
    echo "Bitrate examples: 5M (5 Mbps), 2000k (2000 kbps), 8M (8 Mbps)"
    exit 1
fi

# Store the first argument as the folder path
FOLDER_PATH="$1"
FOLDER_NAME=$(basename "$FOLDER_PATH")

# Parse arguments
DELAY_MS="0"
BITRATE="0"
TIMELINE_PATH=""

shift
while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 /path/to/video/folder [delay_milliseconds] [video_bitrate] [/path/to/timeline/]"
            exit 0
            ;;
        *)
            if [[ $1 =~ ^-?[0-9]+$ ]]; then
                DELAY_MS="$1"
            elif [[ $1 =~ ^[0-9]+[kM]?$ ]]; then
                BITRATE="$1"
            elif [ -d "$1" ] || [ -f "$1" ]; then
                TIMELINE_PATH="$1"
            else
                echo "Warning: Unknown argument '$1'"
            fi
            ;;
    esac
    shift
done

OUTPUT_DIR="/home/ahmed/Videos/converted"

# Extract date and time from folder name
if [[ $FOLDER_NAME =~ bg_([0-9]+)_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
    GAME_ID="${BASH_REMATCH[1]}"
    YEAR="${BASH_REMATCH[2]}"
    MONTH="${BASH_REMATCH[3]}"
    DAY="${BASH_REMATCH[4]}"
    HOUR="${BASH_REMATCH[5]}"
    MINUTE="${BASH_REMATCH[6]}"
    SECOND="${BASH_REMATCH[7]}"
    TIMESTAMP="${YEAR}${MONTH}${DAY}${HOUR}${MINUTE}.${SECOND}"

    echo "Detected recording time: $YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND"
    echo "Game ID: $GAME_ID"
else
    echo "Error: Could not parse date/time from folder name: $FOLDER_NAME"
    exit 1
fi

# Check if session.mpd file exists
MPD_FILE="$FOLDER_PATH/session.mpd"
if [ ! -f "$MPD_FILE" ]; then
    echo "Error: session.mpd not found in $FOLDER_PATH"
    exit 1
fi

# Generate output filename
OUTPUT_FILE="$OUTPUT_DIR/recorded_${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}.mp4"

# Simple timeline file finder
find_timeline_file() {
    local game_id="$1"
    local date_part="${YEAR}${MONTH}${DAY}"

    # Common timeline directories
    local search_dirs=(
        "/run/media/ahmed/drivec/Sync_W11/Steam_rec/timelines"
        "/home/ahmed/Steam_rec/timelines"
        "$(dirname "$FOLDER_PATH")/../timelines"
    )

    # Search patterns in order of preference
    local patterns=(
        "timeline_${game_id}${date_part}*.json"
        "timeline_${game_id}*.json"
        "timeline_*${date_part}*.json"
    )

    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for pattern in "${patterns[@]}"; do
                local found_files=($(find "$dir" -name "$pattern" -type f 2>/dev/null | head -5))
                if [ ${#found_files[@]} -gt 0 ]; then
                    echo "${found_files[0]}"
                    return 0
                fi
            done
        fi
    done

    return 1
}

# Function to create chapters metadata
create_chapters_metadata() {
    local timeline_file="$1"
    local output_meta_file="$2"

    if ! command -v jq &> /dev/null; then
        echo "Warning: jq not found. Cannot create chapters."
        return 1
    fi

    if [ ! -f "$timeline_file" ]; then
        echo "Warning: Timeline file not found: $timeline_file"
        return 1
    fi

    echo "Creating chapters from: $timeline_file"

    # Get video duration and markers
    local end_time=$(jq -r '.endtime' "$timeline_file" 2>/dev/null)
    if [ -z "$end_time" ] || [ "$end_time" = "null" ]; then
        echo "Warning: Could not get video duration from timeline"
        return 1
    fi

    # Extract ALL marker types
    mapfile -t markers < <(jq -r '.entries[] | select(.type == "usermarker" or .type == "screenshot" or .type == "achievement") | .time' "$timeline_file" 2>/dev/null)

    if [ ${#markers[@]} -eq 0 ]; then
        echo "No markers found in timeline"
        return 1
    fi

    echo "Found ${#markers[@]} markers, video duration: $end_time ms"

    # Create metadata file
    cat > "$output_meta_file" << 'EOF'
;FFMETADATA1
EOF

    local chapter_num=0

    # Add initial chapter from 0 to first marker
    if [ "${markers[0]}" -gt 0 ]; then
        cat >> "$output_meta_file" << EOF

[CHAPTER]
TIMEBASE=1/1000
START=0
END=${markers[0]}
title=Start
EOF
        chapter_num=1
    fi

    # Add chapters for each marker
    for ((i=0; i<${#markers[@]}; i++)); do
        local start_time="${markers[i]}"
        local end_time="$end_time"

        # Use next marker as end time, or video end for last marker
        if [ $((i + 1)) -lt ${#markers[@]} ]; then
            end_time="${markers[$((i + 1))]}"
        fi

        cat >> "$output_meta_file" << EOF

[CHAPTER]
TIMEBASE=1/1000
START=$start_time
END=$end_time
title=Marker $chapter_num
EOF
        chapter_num=$((chapter_num + 1))
    done

    echo "Created chapters metadata with $chapter_num chapters"
    return 0
}

# Timeline processing
TIMELINE_FILE=""
CHAPTERS_META_FILE=""

# Find timeline file
if [ -n "$TIMELINE_PATH" ]; then
    if [ -f "$TIMELINE_PATH" ]; then
        TIMELINE_FILE="$TIMELINE_PATH"
        echo "Using specified timeline file: $TIMELINE_FILE"
    elif [ -d "$TIMELINE_PATH" ]; then
        TIMELINE_FILE=$(find_timeline_file "$GAME_ID")
        if [ -n "$TIMELINE_FILE" ]; then
            echo "Found timeline in directory: $TIMELINE_FILE"
        fi
    fi
else
    TIMELINE_FILE=$(find_timeline_file "$GAME_ID")
    if [ -n "$TIMELINE_FILE" ]; then
        echo "Auto-found timeline: $TIMELINE_FILE"
    fi
fi

# Create chapters if timeline found
if [ -n "$TIMELINE_FILE" ] && [ -f "$TIMELINE_FILE" ]; then
    CHAPTERS_META_FILE="/tmp/chapters_${GAME_ID}_$$.txt"
    if ! create_chapters_metadata "$TIMELINE_FILE" "$CHAPTERS_META_FILE"; then
        rm -f "$CHAPTERS_META_FILE"
        CHAPTERS_META_FILE=""
    fi
fi

# Display conversion info
echo "Converting MPD to MP4..."
echo "Output: $OUTPUT_FILE"
echo "Audio delay: $DELAY_MS ms"
echo "Video bitrate: ${BITRATE:-'copy'}"
echo "Timeline: ${TIMELINE_FILE:-'none'}"
echo "Chapters: ${CHAPTERS_META_FILE:-'none'}"

# Handle negative delay (audio earlier - delay video)
if [ "$DELAY_MS" -lt 0 ]; then
    ABS_DELAY_MS=$(( -DELAY_MS ))
    DELAY_SEC=$(awk "BEGIN {printf \"%.3f\", $ABS_DELAY_MS/1000}")
    echo "Applying negative delay: audio earlier by $ABS_DELAY_MS ms (delaying video by $DELAY_SEC seconds)"

    # Build command for negative delay
    FFMPEG_CMD=(-y -hwaccel cuda)

    # Add chapters metadata if available (MUST come before the delayed video input)
    if [ -n "$CHAPTERS_META_FILE" ] && [ -f "$CHAPTERS_META_FILE" ]; then
        FFMPEG_CMD+=(-i "$CHAPTERS_META_FILE")
        CHAPTERS_INDEX=0
        VIDEO_INDEX=1
        AUDIO_INDEX=2
    else
        CHAPTERS_INDEX=-1
        VIDEO_INDEX=0
        AUDIO_INDEX=1
    fi

    # Add inputs: delayed video first, then original audio
    FFMPEG_CMD+=(-itsoffset "$DELAY_SEC" -i "$MPD_FILE" -i "$MPD_FILE")

    # Map streams
    if [ $CHAPTERS_INDEX -ge 0 ]; then
        FFMPEG_CMD+=(-map $VIDEO_INDEX:v -map $AUDIO_INDEX:a -map_metadata $CHAPTERS_INDEX)
    else
        FFMPEG_CMD+=(-map $VIDEO_INDEX:v -map $AUDIO_INDEX:a)
    fi

    # Video encoding
    if [ "$BITRATE" != "0" ] && [ -n "$BITRATE" ]; then
        FFMPEG_CMD+=(-c:v h264_nvenc -b:v "$BITRATE")
    else
        FFMPEG_CMD+=(-c:v copy)
    fi

    FFMPEG_CMD+=(-c:a copy "$OUTPUT_FILE")

    echo "Running: ffmpeg ${FFMPEG_CMD[@]}"
    ffmpeg "${FFMPEG_CMD[@]}"
    FFMPEG_EXIT=$?

# Handle positive delay or no delay
else
    # Build base ffmpeg command
    FFMPEG_CMD=(-y -hwaccel cuda -i "$MPD_FILE")

    # Add chapters metadata if available
    if [ -n "$CHAPTERS_META_FILE" ] && [ -f "$CHAPTERS_META_FILE" ]; then
        FFMPEG_CMD+=(-i "$CHAPTERS_META_FILE" -map_metadata 1)
    fi

    # Video encoding
    if [ "$BITRATE" != "0" ] && [ -n "$BITRATE" ]; then
        FFMPEG_CMD+=(-c:v h264_nvenc -b:v "$BITRATE")
    else
        FFMPEG_CMD+=(-c:v copy)
    fi

    # Audio delay
    if [ "$DELAY_MS" -eq 0 ]; then
        FFMPEG_CMD+=(-c:a copy)
    else
        FFMPEG_CMD+=(-c:a aac -af "adelay=$DELAY_MS|$DELAY_MS")
    fi

    FFMPEG_CMD+=("$OUTPUT_FILE")

    echo "Running: ffmpeg ${FFMPEG_CMD[@]}"
    ffmpeg "${FFMPEG_CMD[@]}"
    FFMPEG_EXIT=$?
fi

# Final steps
if [ $FFMPEG_EXIT -eq 0 ]; then
    echo "Setting file timestamp..."
    touch -t "$TIMESTAMP" "$OUTPUT_FILE"
    echo "Conversion complete: $OUTPUT_FILE"
else
    echo "Error: FFmpeg conversion failed"
fi

# Cleanup
if [ -n "$CHAPTERS_META_FILE" ] && [ -f "$CHAPTERS_META_FILE" ]; then
    rm -f "$CHAPTERS_META_FILE"
fi
