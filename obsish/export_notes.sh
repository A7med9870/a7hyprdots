#!/bin/bash

# Define the root directory of your notes
NOTES_DIR="/home/ahmed/Documents/obsi/Daily Notes"

# Define the output directory for PNG files
OUTPUT_DIR="/home/ahmed/Documents/obsi/Exported_PNGs"

# Path to the dark mode CSS file
DARK_CSS="/home/ahmed/Documents/obsi/Liuounx/dark-mode.css"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Find all Markdown files with dates in their names under the NOTES_DIR and process them
find "$NOTES_DIR" -type f -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9].md" | while read -r file; do
    # Get the base name of the file (without extension)
    base_name=$(basename "$file" .md)

    # Define the output PNG file path
    output_png="$OUTPUT_DIR/$base_name.png"

    # Extract the date from the filename (assuming format: YYYY-MM-DD.md)
    note_date=$(echo "$base_name" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")

    # Add a timestamp to the note (11:58 PM on the note's date)
    timestamp="<p style='color: gray; font-size: 0.9em;'>Last exported: $note_date at 11:58 PM</p>"

    # Convert Markdown to HTML using Pandoc
    if ! pandoc --standalone \
    --lua-filter=wikilinks.lua \
    --lua-filter=tags.lua \
    --lua-filter=callouts.lua \
    --resource-path=.:path/to/your/assets \
    --css="$DARK_CSS" \
    "$file" -o "${file%.md}.html"; then
        echo "Error processing $file. Skipping..."
        continue
    fi

    # Prepend the timestamp to the HTML file
    echo "$timestamp" | cat - "${file%.md}.html" > temp.html && mv temp.html "${file%.md}.html"

    # Convert HTML to PNG using wkhtmltopdf
    if ! wkhtmltopdf --enable-local-file-access "${file%.md}.html" "$output_png"; then
        echo "Error converting $file to PNG. Skipping..."
        continue
    fi

    # Crop the PNG to include only the text area
    magick "$output_png" -trim +repage "$output_png"

    # Clean up the intermediate HTML file
    rm "${file%.md}.html"

    echo "Exported: $file -> $output_png"
done

echo "Batch export complete! Check the output directory: $OUTPUT_DIR"
