#!/bin/bash

# Directories to search
DIRS=(
    "/home/ahmed/Videos/phone_recoreded_scrn/"
    "/home/ahmed/Videos/Questvids/"
    "/home/ahmed/Videos/LinuxPC_Videos/"
    # "/home/ahmed/Videos/converted/"
    "/home/ahmed/Videos/dasd/"
)

# Create thumbnail cache directory
CACHE_DIR="/tmp/rofi-video-thumbnails"
mkdir -p "$CACHE_DIR"

# Function to generate thumbnail for a video
generate_thumbnail() {
    local video_file="$1"
    local video_hash=$(echo -n "$video_file" | md5sum | cut -d' ' -f1)
    local thumbnail="$CACHE_DIR/${video_hash}.jpg"

    # Generate thumbnail if it doesn't exist or if video is newer
    if [ ! -f "$thumbnail" ] || [ "$video_file" -nt "$thumbnail" ]; then
        # Extract frame at 1 second, resize to 160x120
        ffmpeg -i "$video_file" -ss 00:00:01 -vframes 1 -vf "scale=160:120" "$thumbnail" -y 2>/dev/null
    fi

    echo "$thumbnail"
}

# Find videos and process them
while IFS= read -r file; do
    # Generate thumbnail
    thumbnail=$(generate_thumbnail "$file")

    # Use thumbnail as icon if generation succeeded, otherwise fallback to video file
    if [ -f "$thumbnail" ]; then
        printf "%s\0icon\x1f%s\n" "$(basename "$file")" "$thumbnail"
    else
        # Fallback to a generic video icon
        printf "%s\0icon\x1fvideo-x-generic\n" "$(basename "$file")"
    fi
done < <(find "${DIRS[@]}" -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.avi" -o \
    -iname "*.mov" -o \
    -iname "*.webm" \) \
    -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-) | \
rofi -dmenu \
  -theme "$HOME/.config/hypr/rofi/themes/fullscreen-preview.rasi" -i \
  -show-icons \
  -markup-rows \
  -format 's' | \
while read -r selected_name; do
    if [ -n "$selected_name" ]; then
        full_path=$(find "${DIRS[@]}" -type f -name "$selected_name" | head -n1)
        if [ -n "$full_path" ]; then
            xdg-open "$full_path"
        fi
    fi
done
