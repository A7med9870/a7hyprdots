#!/bin/bash

# Simplified reverse converter - uses existing Steam files as templates
# Usage: ./reverse_convert.sh /path/to/video.mp4 /path/to/existing/steam/clip

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 /path/to/video.mp4 /path/to/existing/steam/clip"
    exit 1
fi

VIDEO_FILE="$1"
EXISTING_CLIP="$2"
OUTPUT_DIR="${3:-$(dirname "$VIDEO_FILE")/converted_clip}"

# Check files
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: Video file not found"
    exit 1
fi

if [ ! -d "$EXISTING_CLIP" ]; then
    echo "Error: Existing clip directory not found"
    exit 1
fi

# Get existing files
EXISTING_MPD=$(find "$EXISTING_CLIP" -name "session.mpd" | head -n1)
EXISTING_PB=$(find "$EXISTING_CLIP" -name "clip.pb" | head -n1)

if [ -z "$EXISTING_MPD" ] || [ -z "$EXISTING_PB" ]; then
    echo "Error: Could not find session.mpd or clip.pb in existing clip"
    exit 1
fi

# Create output directory structure
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/timelines"
mkdir -p "$OUTPUT_DIR/video"

# Find video subdirectory in existing clip
EXISTING_VIDEO_DIR=$(find "$EXISTING_CLIP/video" -type d -name "bg_*" | head -n1)
if [ -z "$EXISTING_VIDEO_DIR" ]; then
    EXISTING_VIDEO_DIR="$EXISTING_CLIP/video/bg_$(basename "$EXISTING_CLIP")_0"
fi

OUTPUT_VIDEO_DIR="$OUTPUT_DIR/video/$(basename "$EXISTING_VIDEO_DIR")"
mkdir -p "$OUTPUT_VIDEO_DIR"

# Copy template files
cp "$EXISTING_PB" "$OUTPUT_DIR/"
cp "$EXISTING_MPD" "$OUTPUT_VIDEO_DIR/"

# Get video duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
TIMESTAMP="${4:-$(date +%s)}"

# Create timeline JSON (simplified)
cat > "$OUTPUT_DIR/timelines/timeline_$(basename "$OUTPUT_DIR").json" << EOF
{
    "daterecorded": "$TIMESTAMP",
    "starttime": "0",
    "entries": [],
    "endtime": "$(echo "$DURATION * 1000" | bc -l | cut -d. -f1)"
}
EOF

# Create thumbnail
ffmpeg -y -i "$VIDEO_FILE" -ss 00:00:01 -vframes 1 -q:v 2 "$OUTPUT_DIR/thumbnail.jpg" 2>/dev/null || touch "$OUTPUT_DIR/thumbnail.jpg"

echo "Creating proper DASH segments..."

# Method 1: Use MP4Box if available (best method)
if command -v MP4Box &> /dev/null; then
    echo "Using MP4Box to create DASH segments..."

    # Create a temporary directory for MP4Box output
    TEMP_DIR=$(mktemp -d)

    # Convert to DASH with proper fragmentation
    MP4Box -dash 3000 -frag 3000 -profile live -bs-switching no -segment-name 'chunk-stream$RepresentationID$-$Number%05d$' -init-segment-name 'init-stream$RepresentationID$' -out "$TEMP_DIR/session.mpd" "$VIDEO_FILE" 2>/dev/null

    # Copy the generated files
    cp "$TEMP_DIR"/init-stream*.m4s "$OUTPUT_VIDEO_DIR/" 2>/dev/null || true
    cp "$TEMP_DIR"/chunk-stream*.m4s "$OUTPUT_VIDEO_DIR/" 2>/dev/null || true

    # Clean up
    rm -rf "$TEMP_DIR"

# Method 2: Use ffmpeg with proper fragmentation
elif command -v ffmpeg &> /dev/null; then
    echo "Using ffmpeg to create DASH segments..."

    # Create initialization segments with proper ISOBMFF structure
    ffmpeg -y -i "$VIDEO_FILE" \
        -map 0:v:0 -c:v copy \
        -f mp4 -movflags +frag_keyframe+separate_moof+omit_tfhd_offset+empty_moov \
        -brand isom -minor_version 1 \
        "$OUTPUT_VIDEO_DIR/init-stream0.m4s" 2>/dev/null

    ffmpeg -y -i "$VIDEO_FILE" \
        -map 0:a:0 -c:a copy \
        -f mp4 -movflags +frag_keyframe+separate_moof+omit_tfhd_offset+empty_moov \
        -brand isom -minor_version 1 \
        "$OUTPUT_VIDEO_DIR/init-stream1.m4s" 2>/dev/null

    # Create segmented files
    SEGMENT_TIME=3
    TOTAL_TIME=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
    NUM_SEGMENTS=$(echo "$TOTAL_TIME / $SEGMENT_TIME" | bc)

    for i in $(seq 1 $NUM_SEGMENTS); do
        START_TIME=$(( (i-1) * SEGMENT_TIME ))

        # Video segment
        ffmpeg -y -ss $START_TIME -i "$VIDEO_FILE" -t $SEGMENT_TIME \
            -map 0:v:0 -c:v copy \
            -f mp4 -movflags +frag_keyframe+separate_moof+omit_tfhd_offset+empty_moov \
            -brand isom -minor_version 1 \
            "$OUTPUT_VIDEO_DIR/chunk-stream0-$(printf "%05d" $i).m4s" 2>/dev/null

        # Audio segment
        ffmpeg -y -ss $START_TIME -i "$VIDEO_FILE" -t $SEGMENT_TIME \
            -map 0:a:0 -c:a copy \
            -f mp4 -movflags +frag_keyframe+separate_moof+omit_tfhd_offset+empty_moov \
            -brand isom -minor_version 1 \
            "$OUTPUT_VIDEO_DIR/chunk-stream1-$(printf "%05d" $i).m4s" 2>/dev/null

        echo -n "."
    done
    echo ""
fi

# Update MPD file with correct duration
if [ -f "$OUTPUT_VIDEO_DIR/session.mpd" ]; then
    # Get actual segment count
    SEG_COUNT=$(ls "$OUTPUT_VIDEO_DIR"/chunk-stream0-*.m4s 2>/dev/null | wc -l || echo 0)
    if [ $SEG_COUNT -gt 0 ]; then
        # Calculate duration in microseconds (3 seconds per segment)
        DURATION_US=$((SEG_COUNT * 3000000))
        ISO_DURATION="PT${SEG_COUNT}.0S"

        # Update MPD with correct duration
        sed -i "s/mediaPresentationDuration=\"PT[0-9]*\.*[0-9]*S\"/mediaPresentationDuration=\"$ISO_DURATION\"/g" "$OUTPUT_VIDEO_DIR/session.mpd"
    fi
fi

echo "Done! Clip created at: $OUTPUT_DIR"
echo "You can test with: mpv \"$OUTPUT_VIDEO_DIR/session.mpd\""
