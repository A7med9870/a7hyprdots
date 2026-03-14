#!/bin/bash

# Define the output file
output_file="$HOME/Documents/obsi/Hypr/gamenotes.md"

# Clear the output file if it already exists
> "$output_file"

# Function to append file content in the desired format
append_file_content() {
    local file_path="$1"
    file_path=$(eval echo "$file_path")
    local file_name=$(basename "$file_path")

    echo "$file_name" >> "$output_file"
    cat "$file_path" >> "$output_file"
}

# Function to process all files in a directory
process_directory() {
    local dir_path="$1"
    # Expand ~ to the full home directory path
    dir_path=$(eval echo "$dir_path")

    # Find all files in the directory (excluding subdirectories)
    while IFS= read -r -d '' file; do
        # Check if file is a text file (simple check - you might want to enhance this)
        if file "$file" | grep -q "text"; then
            append_file_content "$file"
        fi
    done < <(find "$dir_path" -maxdepth 1 -type f -print0)
}

# Process specific individual files
# append_file_content "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"

# Process all text files in the game notes folder
process_directory "/home/$USER/.steam/steam/userdata/418183881/2371090/remote/"

echo "File content has been copied to $output_file" && notify-send "Config files updated in obsi"
