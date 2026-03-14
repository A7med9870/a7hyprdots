#!/bin/bash

CLIPS_DIR="/run/media/ahmed/drived/Steam_rec/clips"
SCRIPT_PATH="/home/ahmed/.config/hypr/scripts/STEAM_BACKGROUND_RECORDING/sb_clip_into_video.sh"

for clip in "$CLIPS_DIR"/*; do
    if [ -e "$clip" ]; then
        echo "Processing: $clip"
        "$SCRIPT_PATH" "$clip"
        if [ $? -eq 0 ]; then
            echo "Successfully processed: $clip"
        else
            echo "Failed to process: $clip"
        fi
    fi
done
