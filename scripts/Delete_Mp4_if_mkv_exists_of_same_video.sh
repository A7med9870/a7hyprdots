#!/bin/bash

# Check if a directory was provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/target/directory"
    echo "Example: $0 /run/media/hamada/drivec/Videos/"
    echo "If no directory is provided, the current directory will be used"
    target_dir="."
else
    target_dir="$1"
    # Remove trailing slash if present for consistency
    target_dir="${target_dir%/}"
    
    # Check if the directory exists
    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory '$target_dir' does not exist or is not accessible"
        exit 1
    fi
fi

echo "Processing directory: $target_dir"

# Change to the target directory
cd "$target_dir" || exit 1

# Counter for tracking
deleted_count=0
checked_count=0

# Loop through all .mkv files in the directory
for mkv_file in *.mkv; do
    # Skip if no .mkv files found (globbing returns literal "*.mkv" when no matches)
    if [ ! -e "$mkv_file" ]; then
        echo "No .mkv files found in '$target_dir'"
        break
    fi
    
    # Skip if it's the glob pattern itself
    if [ "$mkv_file" = "*.mkv" ]; then
        echo "No .mkv files found in '$target_dir'"
        break
    fi
    
    checked_count=$((checked_count + 1))
    
    # Check if there is a corresponding .mp4 file with the same name
    mp4_file="${mkv_file%.mkv}.mp4"
    
    if [[ -f "$mp4_file" ]]; then
        # If the .mp4 file exists, delete it
        echo "Deleting: $mp4_file"
        rm "$mp4_file"
        if [ $? -eq 0 ]; then
            deleted_count=$((deleted_count + 1))
        else
            echo "  Warning: Failed to delete $mp4_file"
        fi
    else
        echo "No match: $mkv_file (no corresponding .mp4 file found)"
    fi
done

echo ""
echo "Summary:"
echo "Checked $checked_count .mkv files"
echo "Deleted $deleted_count .mp4 files"
echo "Done!"
