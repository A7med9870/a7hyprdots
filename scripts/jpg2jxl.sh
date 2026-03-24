#!/bin/bash

# Check if directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/folder"
    echo "Converts all JPEG, PNG, and WebP files in the folder to JPEG XL with quality 100 while preserving all metadata and timestamps"
    exit 1
fi

target_dir="$1"

# Check if directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

# Check if cjxl is available
if ! command -v cjxl &> /dev/null; then
    echo "Error: cjxl not found. Please install libjxl-tools"
    echo "Ubuntu/Debian: sudo apt install libjxl-tools"
    echo "Fedora: sudo dnf install libjxl-tools"
    echo "Arch: sudo pacman -S libjxl"
    exit 1
fi

# Check if ImageMagick is available for WebP conversion
if ! command -v convert &> /dev/null; then
    echo "Warning: ImageMagick (convert) not found. WebP files will be skipped."
    echo "Install ImageMagick: sudo apt install imagemagick"
fi

# Convert all JPEG, PNG, and WebP files in the directory
find "$target_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r file; do
    if [ -f "$output_file" ]; then
        echo "  Skipping: ${name_no_ext}.jxl already exists"
        continue
    fi
    filename=$(basename "$file")
    name_no_ext="${filename%.*}"
    output_file="$target_dir/${name_no_ext}.jxl"

    echo "Converting: $filename"

    # Store original timestamps
    original_mod_time=$(stat -c %Y "$file")
    original_access_time=$(stat -c %X "$file")

    # Store original file for metadata extraction if exiftool is available
    temp_file=""

    # Handle WebP files specially using ImageMagick
    if [[ "$filename" =~ \.[Ww][Ee][Bb][Pp]$ ]]; then
        if command -v convert &> /dev/null; then
            # Create temporary PNG file using ImageMagick
            temp_file="${target_dir}/${name_no_ext}_temp.png"
            echo "  Converting WebP to PNG using ImageMagick..."
            convert "$file" "$temp_file"

            if [ $? -ne 0 ] || [ ! -f "$temp_file" ]; then
                echo "✗ Failed to convert WebP: $filename"
                continue
            fi

            conversion_file="$temp_file"
        else
            echo "✗ Skipping WebP (ImageMagick not installed): $filename"
            continue
        fi
    else
        conversion_file="$file"
    fi

    # Convert with quality 100
    cjxl --quality 100 "$conversion_file" "$output_file"

    # Check if conversion was successful
    if [ $? -eq 0 ] && [ -f "$output_file" ]; then
        # Copy metadata from original file if exiftool is available
        if command -v exiftool &> /dev/null; then
            echo "  Copying metadata from original..."
            exiftool -overwrite_original -TagsFromFile "$file" "$output_file" > /dev/null 2>&1
        fi

        # Restore original timestamps
        touch -a -d "@$original_access_time" "$output_file"
        touch -m -d "@$original_mod_time" "$output_file"

        echo "✓ Success: ${name_no_ext}.jxl"

        # Clean up temporary file
        if [ -n "$temp_file" ] && [ -f "$temp_file" ]; then
            rm "$temp_file"
        fi
    else
        echo "✗ Failed: $filename"
        # Clean up temporary file if conversion failed
        if [ -n "$temp_file" ] && [ -f "$temp_file" ]; then
            rm "$temp_file"
        fi
    fi
done

echo "Conversion complete!"
