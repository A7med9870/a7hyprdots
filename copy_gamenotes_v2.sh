#!/bin/bash

# Define the output file
output_file="$HOME/Documents/obsi/Hypr/gamenotes.md"

# Clear the output file if it already exists
> "$output_file"

# Function to process JSON notes and format them
process_notes() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    local game_name=""

    # Extract game name from filename (notes_XXXXX)
    if [[ $file_name =~ notes_([0-9]+) ]]; then
        game_id=${BASH_REMATCH[1]}
        # You could add a lookup table here to map game IDs to names if desired
        game_name="Game ID: $game_id"
    elif [[ $file_name =~ notes_shortcut_(.+) ]]; then
        game_name=${BASH_REMATCH[1]//_/ }
    fi

    echo "## $game_name" >> "$output_file"

    # Use jq to parse JSON if available
    if command -v jq &> /dev/null; then
        jq -r '.notes[] | "### \(.title // "Untitled")\n\(.content)"' "$file_path" | \
        sed 's/\[p\]/\n/g; s/\[\/p\]//g' >> "$output_file"
    else
        # Fallback basic processing without jq
        grep -E '"title":|"content":' "$file_path" | \
        sed 's/^.*"title": "\([^"]*\)".*$/### \1/;
             s/^.*"content": "\([^"]*\)".*$/\1/;
             s/\[p\]/\n/g; s/\[\/p\]//g' >> "$output_file"
    fi

    echo "" >> "$output_file"
}

# Function to process all files in a directory
process_directory() {
    local dir_path="$1"
    dir_path=$(eval echo "$dir_path")

    while IFS= read -r -d '' file; do
        if file "$file" | grep -q "JSON"; then
            process_notes "$file"
        fi
    done < <(find "$dir_path" -maxdepth 1 -type f -name 'notes_*' -print0)
}

# Process all text files in the game notes folder
process_directory "/home/$USER/.steam/steam/userdata/418183881/2371090/remote/"

echo "File content has been copied to $output_file" && notify-send "Config files updated in obsi"
