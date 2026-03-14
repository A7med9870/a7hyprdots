#!/bin/bash

# Make sure the directory exists
mkdir -p ~/Downloads

# Rofi menu options
OPTIONS="Video\nAudio"

# Show rofi menu and get selection
CHOICE=$(echo -e $OPTIONS | rofi -dmenu -p "Download type:" -theme-str 'window {width: 20%;} listview {lines: 2;}')

# Execute based on selection
case $CHOICE in
    "Video")
        # Video download command
        yt-dlp --embed-thumbnail --add-metadata -o "~/Downloads/%(title)s.%(ext)s" "$(wl-paste)" && notify-send "Download Complete" "Video downloaded successfully!" || notify-send "Download Failed" "There was an error downloading the video"        ;;
    "Audio")
        # Audio download command
        yt-dlp -x --audio-format mp3 --audio-quality 320K --embed-thumbnail --add-metadata -o "~/Downloads/%(title)s.%(ext)s" "$(wl-paste)" && notify-send "Download Complete" "MP3 downloaded successfully!" || notify-send "Download Failed" "There was an error downloading the MP3"
        ;;
    *)
        # Do nothing if cancelled
        exit 0
        ;;
esac
