#!/bin/bash

# Directory containing the screenshots
DIR="/home/ahmed/Pictures/Screenshots/"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory $DIR does not exist!"
    exit 1
fi

# Check if ksnip is installed
if ! command -v ksnip &> /dev/null; then
    echo "Error: ksnip is not installed or not in PATH!"
    exit 1
fi

# Find image files and open the 5 most recent ones in ksnip
find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.webp" \) -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2- | head -n 5 | while read -r image; do
    echo "Opening: $image"
    ksnip "$image" &
    sleep 1  # Small delay to prevent overwhelming the system
done

echo "Opened 5 most recent images in ksnip"
