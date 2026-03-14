#!/bin/bash

directory="/run/media/ahmed/drivec/Sync_W11/Steam_rec/timelines/"

for json_file in "$directory"*.json; do
    # Check if any .json files exist (to avoid processing the literal "*.json")
    [ -e "$json_file" ] || continue

    echo "Processing: $json_file"
    /home/ahmed/.config/hypr/scripts/STEAM_BACKGROUND_RECORDING/SB_timeline_thumbnails.sh "$json_file"
done
