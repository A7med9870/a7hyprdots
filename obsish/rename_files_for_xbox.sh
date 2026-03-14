#!/bin/bash

# Specify the folder to search in
FOLDER="/run/media/ahmed/6330-6161/kabashtest/"
# FOLDER="/mnt/external_drive/kabashtest/"

# Find files matching the pattern and process them
find "$FOLDER" -type f -name "*-*-*-*-*.png" | while read -r file; do
    # Get the file modification time (since creation time is not always available)
    modification_time=$(stat -c %y "$file" | cut -d '.' -f1 | tr ' ' '_' | tr ':' '-')

    # Generate the new file name with the modification timestamp
    new_name="xbox_Record_${modification_time}.mkv"

    # Rename the file (mv preserves the original timestamps)
    mv "$file" "$(dirname "$file")/$new_name"

    echo "Renamed '$file' to '$new_name' (original timestamps preserved)"
done

# FOLDER="/mnt/external_drive/kabashtest/"
