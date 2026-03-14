#!/bin/bash

# Directory containing the grid files
GRID_DIR="$HOME/.local/share/Steam/userdata/418183881/config/grid/"

# Source JSON file
SOURCE_JSON="$GRID_DIR/1229490.json"

# Check if source JSON exists
if [[ ! -f "$SOURCE_JSON" ]]; then
    echo "Error: Source JSON file not found: $SOURCE_JSON"
    exit 1
fi

# Change to the grid directory
cd "$GRID_DIR" || exit 1

# Find all .png files with purely numeric names (no p.png or _icon.png)
# Pattern: one or more digits, then .png at the end
find . -maxdepth 1 -type f -name "*.png" | while read -r png_file; do
    # Remove the leading ./
    png_file="${png_file#./}"

    # Extract filename without extension
    filename="${png_file%.png}"

    # Check if filename consists only of digits
    if [[ "$filename" =~ ^[0-9]+$ ]]; then
        # This is a purely numeric PNG file
        json_file="${filename}.json"

        # Check if JSON file doesn't already exist
        if [[ ! -f "$json_file" ]]; then
            echo "Creating $json_file from template"
            cp "$SOURCE_JSON" "$json_file"
        else
            echo "Skipping $json_file - already exists"
        fi
    fi
done

echo "Done!"
