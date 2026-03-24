#!/bin/bash

# Source directory with Minecraft instances
# INSTANCES_DIR="/run/media/$USER/kabash/SteamLibrary/steamapps/workshop/content"
# INSTANCES_DIR="/home/$USER/.local/share/PrismLauncher/instances"
INSTANCES_DIR="/home/$USER/.local/share/Steam/userdata/418183881/760/remote"

# Destination directory for screenshots
# DEST_DIR="/home/$USER/Pictures/steamscrn_test" #this was for testing out the script
DEST_DIR="/home/$USER/Pictures/Screenshots"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Find and copy all screenshots
for instance_dir in "$INSTANCES_DIR"/*/; do
    # Check if this is a directory
    if [ -d "$instance_dir" ]; then
        screenshots_dir="$instance_dir/screenshots/"
        # screenshots_dir="$instance_dir/minecraft/screenshots/"

        # Check if screenshots directory exists
        if [ -d "$screenshots_dir" ]; then
            echo "Copying screenshots from: $(basename "$instance_dir")"

            # Copy all screenshots to destination
            # Using -u flag to only copy newer files (update)
            cp -p --update "$screenshots_dir"*.png "$DEST_DIR" 2>/dev/null
            cp -p --update "$screenshots_dir"*.jpg "$DEST_DIR" 2>/dev/null
            cp -p --update "$screenshots_dir"*.jpeg "$DEST_DIR" 2>/dev/null
        fi
    fi
done

echo "Done! Screenshots copied to: $DEST_DIR"
