#!/bin/bash
set -euo pipefail

wall_dir="${1:-/home/$USER/.config/My_wallpapers/}"
mode="${2:-}"
thumbnail_dir="$HOME/.cache/wallpaper-thumbnails"

# Create thumbnail directory if it doesn't exist
mkdir -p "$thumbnail_dir"

# Simple icon function with thumbnail generation
get_icon() {
    local file="$1"
    local extension="${file##*.}"
    local video_exts=("mp4" "mkv" "avi" "mov" "webm")
    local image_exts=("jxl" "jpg" "jpeg" "png" "webp" "bmp")

    # Check if file is video
    if [[ " ${video_exts[*],,} " =~ " ${extension,,} " ]]; then
        # Generate thumbnail for video
        local thumbnail_hash=$(echo -n "$file" | md5sum | cut -d' ' -f1)
        local thumbnail_file="$thumbnail_dir/$thumbnail_hash.png"

        # Check if thumbnail exists and is recent (within 7 days)
        if [[ ! -f "$thumbnail_file" ]] || [[ $(find "$thumbnail_file" -mtime +7 -print) ]]; then
            # Generate thumbnail using ffmpeg
            if command -v ffmpeg >/dev/null 2>&1; then
                # Create a small thumbnail (200x150)
                ffmpeg -i "$file" -vf "thumbnail=300,scale=w=200:h=-1:force_original_aspect_ratio=decrease" \
                       -frames:v 1 -f image2pipe -vcodec png - 2>/dev/null \
                       | convert - -background black -gravity center -extent 200x150 \
                                 -quality 90 "$thumbnail_file" 2>/dev/null || true

                # If convert fails, try just ffmpeg
                if [[ ! -f "$thumbnail_file" ]]; then
                    ffmpeg -i "$file" -ss 00:00:01 -vframes 1 \
                           -vf "scale=w=200:h=-1:force_original_aspect_ratio=decrease" \
                           "$thumbnail_file" 2>/dev/null || true
                fi
            fi
        fi

        # If thumbnail exists, use it
        if [[ -f "$thumbnail_file" ]]; then
            printf '%s\n' "$thumbnail_file"
        else
            # Fallback to video icon
            printf '%s\n' "video-x-generic"
        fi
    else
        # For images, check if we should create a preview
        if [[ " ${image_exts[*],,} " =~ " ${extension,,} " ]]; then
            # For JXL and other images, you might want to create a smaller preview
            # This is optional but can help with large files
            local thumbnail_hash=$(echo -n "$file" | md5sum | cut -d' ' -f1)
            local thumbnail_file="$thumbnail_dir/$thumbnail_hash.png"

            # Only create thumbnail for large files to speed up rofi
            local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")

            if [[ $file_size -gt 10485760 ]] && [[ ! -f "$thumbnail_file" ]]; then
                if command -v convert >/dev/null 2>&1; then
                    convert "$file" -thumbnail 200x150 -background black \
                            -gravity center -extent 200x150 \
                            -quality 90 "$thumbnail_file" 2>/dev/null || true
                fi
            fi

            # Use thumbnail if created, otherwise use original
            if [[ -f "$thumbnail_file" ]]; then
                printf '%s\n' "$thumbnail_file"
            else
                printf '%s\n' "$file"
            fi
        else
            printf '%s\n' "image-x-generic"
        fi
    fi
}

get_file_list() {
    find "$wall_dir" -maxdepth 1 -type f \
        \( -iname "*.jxl" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) 2>/dev/null \
        | sort -r
}

# Create menu
create_menu() {
    local temp_file=$(mktemp)
    local count=0

    # Read and process files
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local icon=$(get_icon "$file")
            local filename=$(basename "$file")
            printf '%s\x00icon\x1f%s\n' "$filename" "$icon"
            ((count++))
        fi
    done < <(get_file_list) > "$temp_file"

    if [[ $count -eq 0 ]]; then
        echo "No wallpapers found in $wall_dir" >&2
        rm -f "$temp_file"
        exit 1
    fi

    printf '%s\n' "$temp_file"
}

# Set wallpaper function
set_wallpaper() {
    local filename="$1"
    local file="$wall_dir/$filename"
    local extension="${filename##*.}"
    local video_exts=("mp4" "mkv" "avi" "mov" "webm")
    local image_exts=("jxl" "jpg" "jpeg" "png" "webp" "bmp")

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file" >&2
        return 1
    fi

    # Kill wallpaper processes
    pkill -f "swaybg" 2>/dev/null || true
    pkill -f "mpvpaper" 2>/dev/null || true

    # Small delay
    sleep 0.1

    # Check if file is video
    if [[ " ${video_exts[*],,} " =~ " ${extension,,} " ]]; then
        echo "Setting video wallpaper: $filename"
        local display="eDP-1"
        if command -v hyprctl >/dev/null 2>&1; then
            display=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' 2>/dev/null || echo "$display")
        fi
        # Force kill any mpv instances that might be lingering
        pkill -f "mpv.*$(basename "$file")" 2>/dev/null || true
        mpvpaper -o "no-audio loop-file" "$display" "$file" &
    elif [[ " ${image_exts[*],,} " =~ " ${extension,,} " ]]; then
        echo "Setting image wallpaper: $filename"
        swaybg -i "$file" -m fill &
    else
        echo "Unsupported file format: $filename"
        return 1
    fi
}

# Debug function
debug_file_list() {
    echo "Debug: Checking files in $wall_dir"
    find "$wall_dir" -maxdepth 1 -type f | head -20
    echo "---"
    echo "Supported files:"
    get_file_list | head -20
}

# Check dependencies for thumbnail generation
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Warning: ffmpeg not found. Video thumbnails will use generic icons." >&2
fi

# Uncomment to debug if needed
# debug_file_list

# Create menu
temp_file=$(create_menu)

# Show rofi menu
if command -v rofi >/dev/null 2>&1; then
    # First, check if the theme file exists
    theme_path="$HOME/.config/rofi/themes/fullscreen-preview.rasi"
    if [[ -f "$theme_path" ]]; then
        selected_line=$(cat "$temp_file" | rofi \
            -theme "$theme_path" \
            -theme-str 'listview {columns: 7;}' \
            -dmenu -i -p "Select wallpaper" \
            -show-icons)
    else
        # Fallback to default theme
        echo "Warning: Theme file not found, using default rofi theme" >&2
        selected_line=$(cat "$temp_file" | rofi \
            -dmenu -i -p "Select wallpaper" \
            -show-icons)
    fi
else
    echo "Error: rofi is not installed" >&2
    exit 1
fi

rm -f "$temp_file"

# Process selection
if [ -n "$selected_line" ]; then
    # Extract just the filename (before the null character)
    selected_filename=$(echo "$selected_line" | awk -F '\x00' '{print $1}')

    if [ -n "$selected_filename" ]; then
        set_wallpaper "$selected_filename"
    else
        echo "No filename extracted from selection" >&2
        exit 1
    fi
else
    echo "No file selected" >&2
    exit 1
fi
