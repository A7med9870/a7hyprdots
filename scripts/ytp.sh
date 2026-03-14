#!/bin/bash

# Make sure the directory exists
mkdir -p ~/Downloads

# Rofi menu options - using array and printf
options=("Video"
    "Audio"
    "Thumbnail"
)
# yt-dlp --cookies ~/Downloads/cookies.txt --embed-thumbnail --add-metadata --write-sub --sub-langs "en,original" --mtime --write-thumbnail --write-info-json --embed-subs -o "~/Downloads/%(title)s.%(ext)s" $(wl-paste)
# Show rofi menu and get selection
CHOICE=$(printf "%s\n" "${options[@]}" | rofi -dmenu -p "Download type:" -theme-str 'window {width: 20%;} listview {lines: 7;}')

# Execute based on selection
case $CHOICE in
    "Video")
    download_video() {
        local url=$(wl-paste)
        yt-dlp --cookies ~/Downloads/cookies.txt --embed-thumbnail --add-metadata --write-sub --sub-langs "en,original" --embed-subs -o "~/Downloads/%(title)s.%(ext)s" "$url"

        if [ $? -eq 0 ]; then
            # Get the latest downloaded file
            local latest_file=$(ls -t ~/Downloads/*.mkv ~/Downloads/*.webm ~/Downloads/*.mp4 2>/dev/null | head -n1)

            if [ -n "$latest_file" ]; then
                # Get upload date and set file timestamp
                local upload_date=$(yt-dlp --cookies ~/Downloads/cookies.txt --print "%(upload_date)s" --no-download "$url")
                if [ -n "$upload_date" ] && [ "$upload_date" != "NA" ]; then
                    touch -t "${upload_date}1200" "$latest_file"
                    echo "Set file timestamp to: ${upload_date}1200"
                fi

                # Apply renaming logic
                if [[ "$latest_file" == *.mp4 ]]; then
                    local file="$latest_file"
                    local basename=$(basename "$file" .mp4)
                    local username="${basename#'Video by '}"
                    local date=$(stat -c %y "$file" | cut -d" " -f1)
                    local new_name="${username}_${date}.mp4"
                    local target_dir="$HOME/Videos/ins_videos/"

                    if [[ "$(basename "$file")" =~ ^[^_]+_[0-9]{4}-[0-9]{2}-[0-9]{2}\.mp4$ ]]; then
                        echo "Already correct format: $file"
                    elif [ "$(basename "$file")" = "$new_name" ]; then
                        echo "Already named correctly: $file"
                    else
                        echo "Renaming to: $new_name"
                        mv "$file" "$(dirname "$file")/$new_name"
                        # Update latest_file variable to point to renamed file
                        latest_file="$(dirname "$file")/$new_name"
                        # Move to target directory
                        mkdir -p "$target_dir"
                        mv "$latest_file" "$target_dir$new_name"
                        latest_file="$target_dir$new_name"

                        # latest_file="$(dirname "$file")/$new_name"
                        # # mv "$file" "$target_dir$(basename "$file")"
                        # mv "$file" "$target_dir$new_name"
                    fi
                fi
            fi
            notify-send "Download Complete" "Video downloaded successfully: $(basename "$latest_file")"
        else
            notify-send "Download Failed" "There was an error downloading the video"
        fi
    }
    download_video
    # download_video() {
    #     local url=$(wl-paste)
    #     yt-dlp --cookies ~/Downloads/cookies.txt --embed-thumbnail --add-metadata --write-sub --sub-langs "en,original" --embed-subs -o "~/Downloads/%(title)s.%(ext)s" "$url"
    #     if [ $? -eq 0 ]; then
    #         # Get the latest downloaded file
    #         local latest_file=$(ls -t ~/Downloads/*.mkv ~/Downloads/*.webm ~/Downloads/*.mp4 2>/dev/null | head -n1)
    #         if [ -n "$latest_file" ]; then
    #             # Get upload date and set file timestamp
    #             local upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$url")
    #             if [ -n "$upload_date" ] && [ "$upload_date" != "NA" ]; then
    #                 touch -t "${upload_date}1200" "$latest_file"
    #                 echo "Set file timestamp to: ${upload_date}1200"
    #             fi
    #         fi
    #         notify-send "Download Complete" "Video downloaded successfully!"
    #     else
    #         notify-send "Download Failed" "There was an error downloading the video"
    #     fi
    # }
    # download_video
        ;;
    "Thumbnail")
        # Video download command with cookies
        # yt-dlp --cookies ~/Downloads/cookies.txt \
        #        --embed-thumbnail \
        #        --add-metadata \
        #        --yes-playlist \
        #        --ignore-errors \
        #        --mtime \
        #        --write-thumbnail \
        #        --extractor-args "youtube:player_client=android,web" \
        #        --throttled-rate 100K \
        #        --output "~/Downloads/%(playlist_title)s/%(title).200s.%(ext)s" \
        #        "$(wl-paste)" && notify-send "Download Complete" "Video downloaded successfully!" || notify-send "Download Failed" "There was an error downloading the video"
        yt-dlp --skip-download --write-thumbnail --throttled-rate 100M -o "~/Downloads/%(title)s.%(ext)s" "$(wl-paste)"
        notify-send "Download Complete" "Thumbnail downloaded successfully!"
        ;;
    "Audio")
    download_audio() {
        local url=$(wl-paste)
        yt-dlp --cookies ~/Downloads/cookies.txt --embed-thumbnail --add-metadata --write-sub --sub-langs "en,original" --embed-subs --extract-audio --audio-format mp3 -o "~/Downloads/%(title)s.%(ext)s" "$url"
        if [ $? -eq 0 ]; then
            # Get the latest downloaded file
            local latest_file=$(ls -t ~/Downloads/*.mp3 2>/dev/null | head -n1)
            if [ -n "$latest_file" ]; then
                # Get upload date and set file timestamp
                local upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$url")
                if [ -n "$upload_date" ] && [ "$upload_date" != "NA" ]; then
                    touch -t "${upload_date}1200" "$latest_file"
                    echo "Set file timestamp to: ${upload_date}1200"
                fi
            fi
            notify-send "Download Complete" "Audio downloaded successfully!"
        else
            notify-send "Download Failed" "There was an error downloading the video"
        fi
    }

    download_audio
        ;;
    *)
        # Do nothing if cancelled
        exit 0
        ;;
esac

        # # Audio download command with cookies
        # yt-dlp --cookies ~/Downloads/cookies.txt \
        #        --embed-thumbnail \
        #        --add-metadata \
        #        --yes-playlist \
        #        --ignore-errors \
        #        --extractor-args "youtube:player_client=android,web" \
        #        --throttled-rate 100K \
        #        --extract-audio \
        #        --audio-format mp3 \
        #        --output "~/Downloads/%(playlist_title)s/%(title).200s.%(ext)s" \
        #        "$(wl-paste)" && notify-send "Download Complete" "Audio downloaded successfully!" || notify-send "Download Failed" "There was an error downloading the audio"
