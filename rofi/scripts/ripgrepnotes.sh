#!/bin/bash

# Directory containing your markdown files
NOTES_DIR="/home/ahmed/Documents/obsi/Daily Notes/"

# Get search term from Rofi
search_term=$(rofi -dmenu -p "Search notes:")

if [ -n "$search_term" ]; then
    # Search with ripgrep and show results in Rofi
    selected_file=$(rg --color=never --files-with-matches -l "$search_term" "$NOTES_DIR" | rofi -dmenu -p "Matching files:")
    
    if [ -n "$selected_file" ]; then
        # Open the selected file with your preferred editor
        xdg-open "$selected_file"
    fi
fi
