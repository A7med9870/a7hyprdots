#!/bin/bash

# Define the target directory
TARGET_DIR="/home/ahmed/Documents/obsi/"

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory $TARGET_DIR does not exist."
  exit 1
fi

# Find and delete files containing "sync-conflict-" in their name
find "$TARGET_DIR" -type f -name '*sync-conflict-*' -exec rm -v {} +

echo "Deletion of files with 'sync-conflict-' in their name is complete."
