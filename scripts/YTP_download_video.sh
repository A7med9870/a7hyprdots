download_video() {
    local url=$(wl-paste)
    yt-dlp --cookies ~/Downloads/cookies.txt --embed-thumbnail --add-metadata -o "~/Downloads/%(title)s.%(ext)s" "$url"
    if [ $? -eq 0 ]; then
        # Get the latest downloaded file
        local latest_file=$(ls -t ~/Downloads/*.mkv ~/Downloads/*.webm ~/Downloads/*.mp4 2>/dev/null | head -n1)
        if [ -n "$latest_file" ]; then
            # Get upload date and set file timestamp
            local upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$url")
            if [ -n "$upload_date" ] && [ "$upload_date" != "NA" ]; then
                touch -t "${upload_date}1200" "$latest_file"
                echo "Set file timestamp to: ${upload_date}1200"
            fi
        fi
        notify-send "Download Complete" "Video downloaded successfully!"
    else
        notify-send "Download Failed" "There was an error downloading the video"
    fi
}

download_video
