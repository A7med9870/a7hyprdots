#!/bin/bash

# Source and target directories
src_dir="/home/ahmed/Documents/obsi/Daily Notes"
target_dir="/home/ahmed/Documents/obsi/Extracted"
obsidian_css="/home/ahmed/Documents/obsi/.obsidian/themes/80s Neon/theme.css"

# Create target directory if it doesn't exist
mkdir -p "$target_dir"

# Check dependencies
if ! command -v wkhtmltoimage &> /dev/null; then
    echo "Error: wkhtmltoimage is not installed. Please install it first."
    echo "On Ubuntu/Debian: sudo apt-get install wkhtmltopdf"
    exit 1
fi

# Find all markdown files and process them
find "$src_dir" -type f -name "*.md" | while read -r filepath; do
    # Extract year and month from path
    year=$(echo "$filepath" | grep -oP '(?<=/)[0-9]{4}(?=/)' | head -1)
    month=$(echo "$filepath" | grep -oP '(?<=/)[a-z]{3}(?=/)' | head -1)
    filename=$(basename "$filepath" .md)
    
    # Create target directory structure
    mkdir -p "$target_dir/$year/$month"
    
    # Create a temporary HTML file with proper structure
    html_file="$target_dir/$year/$month/$filename.html"
    
    # Generate HTML with Pandoc including proper metadata and CSS
    pandoc -f markdown -t html "$filepath" \
        -H <(echo "<meta name='viewport' content='width=device-width, initial-scale=1.0'>") \
        --css="$obsidian_css" \
        -o "$html_file"
    
    # Convert HTML to PNG with proper width and zoom
    png_file="$target_dir/$year/$month/$filename.png"
    wkhtmltoimage --quality 100 \
                  --enable-local-file-access \
                  --width 1200 \
                  --zoom 1.5 \
                  --disable-smart-width \
                  "$html_file" "$png_file"
    
    # Preserve original file's modification time
    touch -d "$(date -r "$filepath" '+%Y-%m-%d %H:%M:%S')" "$png_file"
    
    # Clean up
    rm "$html_file"
    
    echo "Processed: $filepath -> $png_file"
done

echo "Conversion complete!"
