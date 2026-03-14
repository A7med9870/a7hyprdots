#!/bin/bash

# # Source directory with VRChat screenshots
# INSTANCES_DIR="/home/$USER/.local/share/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat"

# # Destination directory for screenshots
# DEST_DIR="/home/$USER/Pictures/Older_laptop_scrns"

# # Create destination directory if it doesn't exist
# mkdir -p "$DEST_DIR"

# # Check if VRChat directory exists
# if [ -d "$INSTANCES_DIR" ]; then
#     echo "Copying screenshots from: VRChat"

#     # Copy all screenshots directly from VRChat directory
#     cp -p --update "$INSTANCES_DIR"/*.png "$DEST_DIR" 2>/dev/null
#     cp -p --update "$INSTANCES_DIR"/*.jpg "$DEST_DIR" 2>/dev/null
#     cp -p --update "$INSTANCES_DIR"/*.jpeg "$DEST_DIR" 2>/dev/null
# fi

# echo "Done! Screenshots copied to: $DEST_DIR"
#!/bin/bash

# Source directory for VRChat screenshots
SOURCE_DIR="/home/$USER/.local/share/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat"

# Destination directory for screenshots
DEST_DIR="/home/$USER/Pictures/Screenshots"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Check if source directory exists
if [ -d "$SOURCE_DIR" ]; then
    echo "Copying screenshots from VRChat..."

    # Use find to recursively locate all image files
    # -type f: only files
    # -name "*.png" -o -name "*.jpg" -o -name "*.jpeg": match image extensions
    # -exec cp -p --update {} "$DEST_DIR" \;: copy with preserved metadata

    find "$SOURCE_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) \
        -exec cp -p --update {} "$DEST_DIR" \;

    echo "Done! Screenshots copied to: $DEST_DIR"
else
    echo "Error: Source directory not found: $SOURCE_DIR"
fi
