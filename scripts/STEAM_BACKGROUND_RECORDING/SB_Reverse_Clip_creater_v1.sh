#!/bin/bash

# Configuration
INPUT_VIDEO="$1"
if [ -z "$INPUT_VIDEO" ]; then
    echo "Usage: $0 <input_video_file>"
    exit 1
fi

if [ ! -f "$INPUT_VIDEO" ]; then
    echo "Error: Input video file not found: $INPUT_VIDEO"
    exit 1
fi

STEAM_USERDATA="$HOME/.local/share/Steam/userdata/418183881/gamerecordings/clips"
VIDEO_ID="674941"  # Change this
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create directory
CLIP_DIR="$STEAM_USERDATA/clip_${VIDEO_ID}_${TIMESTAMP}"
mkdir -p "$CLIP_DIR/timelines"
VIDEO_SUBDIR="bg_${VIDEO_ID}_${TIMESTAMP}"
mkdir -p "$CLIP_DIR/video/$VIDEO_SUBDIR"

cd "$CLIP_DIR"

# Get video info
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_VIDEO")
# Use awk instead of bc for duration calculation
DURATION_MS=$(echo "$DURATION" | awk '{print int($1 * 1000)}')
WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=nw=1:nk=1 "$INPUT_VIDEO")
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$INPUT_VIDEO")

echo "Video Info:"
echo "  Duration: ${DURATION_MS}ms"
echo "  Resolution: ${WIDTH}x${HEIGHT}"

# Convert to DASH
echo "Converting video to DASH format..."
ffmpeg -i "$INPUT_VIDEO" \
  -map 0:v -map 0:a? \
  -c:v libx264 -b:v:0 4000k -b:v:1 2000k \
  -s:v:0 ${WIDTH}x${HEIGHT} \
  -s:v:1 $((WIDTH/2))x$((HEIGHT/2)) \
  -c:a aac -b:a 128k \
  -f dash \
  -seg_duration 2 \
  -init_seg_name "init-stream\$RepresentationID\$.m4s" \
  -media_seg_name "chunk-stream\$RepresentationID\$-\$Number%05d\$.m4s" \
  -adaptation_sets "id=0,streams=v id=1,streams=a" \
  "video/$VIDEO_SUBDIR/session.mpd"

# Create thumbnail
echo "Creating thumbnail..."
ffmpeg -i "$INPUT_VIDEO" -ss 00:00:01 -vframes 1 -q:v 2 "thumbnail.jpg" 2>/dev/null

# Create timeline JSON
CURRENT_TIMESTAMP=$(date +%s)
cat > "timelines/timeline_${VIDEO_ID}${TIMESTAMP}.json" << EOF
{
  "daterecorded": "${CURRENT_TIMESTAMP}",
  "starttime": "0",
  "endtime": "${DURATION_MS}",
  "entries": []
}
EOF

echo ""
echo "Created clip structure in: $CLIP_DIR"
echo "Directory contents:"
ls -la "$CLIP_DIR"
echo ""
echo "Video directory contents:"
ls -la "$CLIP_DIR/video/$VIDEO_SUBDIR"
echo ""
echo "Note: You'll need to create/modify clip.pb separately"
