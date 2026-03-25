#!/bin/bash
set -euo pipefail

wall_dir="${1:-/home/$USER/.config/My_wallpapers/}"
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

# Create thumbnails for all files
create_cache() {
    echo "Creating wallpaper thumbnails..."
    local count=0

    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            get_icon "$file" >/dev/null
            ((count++))
        fi
    done < <(get_file_list)

    echo "Created thumbnails for $count files in $thumbnail_dir"
}

# Check dependencies for thumbnail generation
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Warning: ffmpeg not found. Video thumbnails will use generic icons." >&2
fi

# Main execution
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [wallpaper_directory]"
    echo "Default directory: /home/$USER/.config/My_wallpapers/"
    exit 0
fi

create_cache
