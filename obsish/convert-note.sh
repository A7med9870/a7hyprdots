#!/bin/bash

src_dir="/home/ahmed/Documents/obsi/Daily Notes"
target_dir="/home/ahmed/Documents/Extracted"

find "$src_dir" -name "*.md" | while read -r md_file; do
    # Create PNG path matching source structure
    png_file="${md_file#$src_dir/}"
    png_file="$target_dir/${png_file%.md}.png"

    # Create HTML path (same location as PNG)
    html_file="${png_file%.png}.html"

    # Ensure target directory exists
    mkdir -p "$(dirname "$png_file")"

    # Convert using simple single-file converter
    pandoc -f markdown -t html -o "$html_file" "$md_file"
    wkhtmltoimage --quality 100 --width 1000 "$html_file" "$png_file"
done
