#!/bin/bash
# fix_thumbnail_timestamps.sh

THUMBNAIL_DIR="/run/media/ahmed/drivec/Sync_W11/Steam_rec/thumbnails/"

for thumbnail in "$THUMBNAIL_DIR"*.jpg "$THUMBNAIL_DIR"*.png; do
    [ -e "$thumbnail" ] || continue

    filename=$(basename "$thumbnail")

    # Match pattern: timeline_GAMEIDYYYYMMDD_HHMMSS.ext
    if [[ $filename =~ timeline_([0-9]+)([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.(jpg|png) ]]; then
        game_id="${BASH_REMATCH[1]}"
        year="${BASH_REMATCH[2]}"
        month="${BASH_REMATCH[3]}"
        day="${BASH_REMATCH[4]}"
        hour="${BASH_REMATCH[5]}"
        minute="${BASH_REMATCH[6]}"
        second="${BASH_REMATCH[7]}"

        timestamp="${year}${month}${day}${hour}${minute}.${second}"

        echo "Fixing: $filename -> $year-$month-$day $hour:$minute:$second"

        if touch -t "$timestamp" "$thumbnail"; then
            echo "  ✓ Timestamp corrected"
        else
            echo "  ✗ Failed to set timestamp"
        fi
    else
        echo "Skipping (pattern mismatch): $filename"
    fi
done
