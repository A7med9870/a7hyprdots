#!/bin/bash

# Recursively find all .mp4 files in the current directory and subdirectories
find . -type f -iname "*.mp4" | while read FILENAME; do
  # Extract the date and time portion from the filename using regular expressions
  TIMESTAMP=$(echo "$FILENAME" | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{1,2}-[0-9]{1,2}-[0-9]{1,2} [APM]+).*\.mp4/\1/')

  # If a valid timestamp was found
  if [ ! -z "$TIMESTAMP" ]; then
    # Clean the timestamp to replace spaces and dashes with underscores
    TIMESTAMP=$(echo "$TIMESTAMP" | sed -E 's/ /_/g' | sed -E 's/-/_/g' | sed -E 's/([APM]+)//g')

    # Rename the file using the timestamp
    DIRNAME=$(dirname "$FILENAME")
    BASENAME=$(basename "$FILENAME")
    NEWFILENAME="$DIRNAME/Ready_or_Not_$TIMESTAMP.mp4"

    # Rename the file
    mv "$FILENAME" "$NEWFILENAME"
    echo "Renamed '$FILENAME' to '$NEWFILENAME'"
  else
    echo "No timestamp found in filename: $FILENAME"
  fi
done
