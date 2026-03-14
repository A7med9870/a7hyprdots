#!/bin/bash

# Source and destination directories
SOURCE_DIR="/run/media/ahmed/drivec/Sync_W11/"
DEST_DIR="/run/media/ahmed/6F7B-2DA0/W11Sync/"
# DEST_DIR="/media/sdd1/Sync_W11/"

# Use rsync to copy only new or updated files
rsync -av --update --progress "$SOURCE_DIR" "$DEST_DIR"

# Ensure data is flushed to disk
sync

# Optional: Use fsync on the destination directory to ensure data is written
# This step is more advanced and typically not necessary for most users
# fsync is not a standard command, but you can use a tool like `python` or `dd` to call fsync
# Example using Python:
python3 -c 'import os; os.fsync(os.open("'"$DEST_DIR"'", os.O_RDONLY))'

echo "Backup completed and data synced to disk." && notify-send "Finished"
