#!/bin/bash

wlp=$(wl-paste) # make clipboard into a variable

# Use command substitution to capture ffprobe output
videolink=$(ffprobe -v quiet -show_entries format_tags=comment -of default=noprint_wrappers=1:nokey=1 "$wlp")

# Only run yt-dlp if we have a valid URL from ffprobe

if [[ -n "$videolink" && "$videolink" =~ ^https?:// ]]; then
    # Get upload date from YouTube
    upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$videolink" 2>/dev/null)

    if [[ -n "$upload_date" && "$upload_date" =~ ^[0-9]{8}$ ]]; then
        # Format: YYYYMMDDHHMM (adding 12:00 as default time)
        touch -t "${upload_date}1200" "$wlp"
        echo "Set file timestamp to: ${upload_date}1200 for file: $(basename "$wlp")"
    else
        echo "Could not retrieve valid upload date for: $videolink"
    fi
else
    echo "No YouTube URL found in file metadata"
    echo "Comment tag contains: $videolink"
fi

# if [[ -n "$videolink" && "$videolink" =~ ^https?:// ]]; then
#     upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$videolink" 2>/dev/null)
# else
#     upload_date=""
#     echo "No valid URL found in comment tag"
# fi

# Debug output
echo "wlp: $wlp"
echo "video link: $videolink"
echo "upload time: ${upload_date}1200"


# #!/bin/bash

# # download_video() {
# wlp=$(wl-paste) #make clipborad into a varible
# videolink=ffprobe -v quiet -show_entries format_tags=comment -of default=noprint_wrappers=1:nokey=1 "$wlp" # get the link from file, and paste it into a varible
# # local videolink=ffprobe -v quiet -show_entries format_tags=comment -of default=noprint_wrappers=1:nokey=1 "$(wl-paste)"
# # yt-dlp --print "%(upload_date)s" --no-download $(wl-paste)
# upload_date=$(yt-dlp --print "%(upload_date)s" --no-download "$wlp") #call ytp to paste the time of file creation
# # touch -d "$wlp"
# # touch -t "${upload_date}1200" "$wlp"
# # echo "Set file timestamp to: ${upload_date}1200"
# echo "wlp ${wlp}"
# echo "upload time ${upload_date}1200"
# echo "video link ${videolink}"
# # }
# # download_video
