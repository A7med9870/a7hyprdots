#!/bin/bash

# Check if directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/folder"
    echo "Finds duplicate JPEG/PNG files that have JXL equivalents and removes the originals"
    exit 1
fi

target_dir="$1"

# Check if directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

echo "Scanning for duplicates in: $target_dir"
echo "=========================================="

# Use temporary files to store results (avoid subshell array issues)
temp_file=$(mktemp)

# Find all JXL files and check for duplicates
while IFS= read -r jxl_file; do
    jxl_filename=$(basename "$jxl_file")
    name_no_ext="${jxl_filename%.*}"

    # Check for corresponding JPEG files
    for ext in jpg jpeg JPG JPEG; do
        jpeg_file="$target_dir/${name_no_ext}.${ext}"
        if [ -f "$jpeg_file" ]; then
            echo "📸 JXL found: ${name_no_ext}.jxl"
            echo "   JPEG duplicate: ${name_no_ext}.${ext}"
            echo "$jpeg_file" >> "$temp_file"
        fi
    done

    # Check for corresponding WebP files
    for ext in webp WEBP; do
        webp_file="$target_dir/${name_no_ext}.${ext}"
        if [ -f "$webp_file" ]; then
            echo "🖼️  JXL found: ${name_no_ext}.jxl"
            echo "   WebP duplicate: ${name_no_ext}.${ext}"
            echo "$webp_file" >> "$temp_file"
        fi
    done

    # Check for corresponding PNG files
    for ext in png PNG; do
        png_file="$target_dir/${name_no_ext}.${ext}"
        if [ -f "$png_file" ]; then
            echo "🖼️  JXL found: ${name_no_ext}.jxl"
            echo "   PNG duplicate: ${name_no_ext}.${ext}"
            echo "$png_file" >> "$temp_file"
        fi
    done
done < <(find "$target_dir" -maxdepth 1 -type f -iname "*.jxl")

# Read the temporary file into an array
if [ -f "$temp_file" ]; then
    mapfile -t files_to_delete < "$temp_file"
    rm "$temp_file"
else
    files_to_delete=()
fi

if [ ${#files_to_delete[@]} -eq 0 ]; then
    echo "✅ No duplicate files found!"
    exit 0
fi

echo ""
echo "=========================================="
echo "Found ${#files_to_delete[@]} duplicate files:"
printf '%s\n' "${files_to_delete[@]}"
echo ""

# Auto-delete without confirmation
deleted_count=0
for file in "${files_to_delete[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        if [ $? -eq 0 ]; then
            echo "🗑️  Deleted: $(basename "$file")"
            ((deleted_count++))
        else
            echo "❌ Failed to delete: $(basename "$file")"
        fi
    fi
done

echo ""
echo "✅ Deleted $deleted_count duplicate files"
