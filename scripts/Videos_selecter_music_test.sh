#!/bin/bash

# Directories to search
DIRS=(
    "/home/ahmed/Music/"
    # "/home/ahmed/Music/"
    # "/home/ahmed/Music/"
    # "/home/ahmed/Music/"
    # "/home/ahmed/Music/"
)

# Thumbnail cache directories (freedesktop standard)
LARGE_THUMB_DIR="$HOME/.cache/thumbnails/large"
NORMAL_THUMB_DIR="$HOME/.cache/thumbnails/normal"

# Function to escape XML special characters for markup
escape_markup() {
    local string="$1"
    # Escape &, <, >, ', " for Pango markup
    string="${string//&/&amp;}"
    string="${string//</&lt;}"
    string="${string//>/&gt;}"
    string="${string//\'/&apos;}"
    string="${string//\"/&quot;}"
    echo -n "$string"
}

# Function to get thumbnail path following freedesktop spec
get_thumbnail_path() {
    local video_file="$1"
    # Create the URI (file:// + full path)
    local file_uri="file://$video_file"
    # Create MD5 hash of the URI
    local hash=$(echo -n "$file_uri" | md5sum | cut -d' ' -f1)

    # Check large thumbnails first, then normal
    if [ -f "$LARGE_THUMB_DIR/$hash.png" ]; then
        echo "$LARGE_THUMB_DIR/$hash.png"
    elif [ -f "$NORMAL_THUMB_DIR/$hash.png" ]; then
        echo "$NORMAL_THUMB_DIR/$hash.png"
    else
        # Also check for fail/missing thumbnails to avoid repeated lookups
        if [ -f "$HOME/.cache/thumbnails/fail/$hash.png" ]; then
            echo "fail"
        else
            echo ""
        fi
    fi
}

# Debug: Count how many videos we find
video_count=0
thumb_count=0

# Find videos and process them
while IFS= read -r file; do
    ((video_count++))

    # Get escaped filename for markup
    basename_file=$(basename "$file")
    escaped_name=$(escape_markup "$basename_file")

    # Try to get existing thumbnail from cache
    thumbnail=$(get_thumbnail_path "$file")

    # Use thumbnail if it exists
    if [ -n "$thumbnail" ] && [ "$thumbnail" != "fail" ] && [ -f "$thumbnail" ]; then
        printf "%s\0icon\x1f%s\n" "$escaped_name" "$thumbnail"
        ((thumb_count++))
    else
        # Fallback to a generic video icon
        printf "%s\0icon\x1fvideo-x-generic\n" "$escaped_name"
    fi
done < <(find "${DIRS[@]}" -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.avi" -o \
    -iname "*.mov" -o \
    -iname "*.mp3" -o \
    -iname "*.webm" \) \
    -printf "%T@ %p\n" 2>/dev/null | sort -nr | cut -d' ' -f2-) | \
rofi -dmenu -i \
  -theme "$HOME/.config/hypr/rofi/themes/fullscreen-preview.rasi" \
  -show-icons \
  -markup-rows \
  -format 's' | \
while read -r selected_name; do
    if [ -n "$selected_name" ]; then
        # Need to unescape the name when searching
        # For now, just find by basename (might need improvement)
        full_path=$(find "${DIRS[@]}" -type f -name "$(echo "$selected_name" | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&apos;/'"'"'/g; s/&quot;/"/g')" | head -n1)
        if [ -n "$full_path" ]; then
            xdg-open "$full_path"
        fi
    fi
done

# Debug output to stderr
echo "Found $video_count videos, $thumb_count with thumbnails" >&2
