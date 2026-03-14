#!/bin/bash

# Loop through all .mkv files in the current directory
for mkv_file in *.mkv; do
  # Check if there is a corresponding .mp4 file with the same name
  mp4_file="${mkv_file%.mkv}.mp4"

  if [[ -f "$mp4_file" ]]; then
    # If the .mp4 file exists, delete it
    echo "Deleting $mp4_file"
    rm "$mp4_file"
  fi
done
