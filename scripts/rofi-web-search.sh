#!/bin/bash
engine=$(printf "searx
YouTube
GitHub
Wikipedia" | rofi -dmenu -p "Search Engine")
if [ -n "$engine" ]; then
    query=$(echo "" | rofi -dmenu -p "Search $engine")
    if [ -n "$query" ]; then
        case "$engine" in
            "searx") xdg-open "https://searx.garudalinux.org/search?q=$query" ;;
#             "DuckDuckGo") xdg-open "https://duckduckgo.com/?q=$query" ;;
            "YouTube") xdg-open "https://youtube.com/results?search_query=$query" ;;
            "GitHub") xdg-open "https://github.com/search?q=$query" ;;
            "Wikipedia") xdg-open "https://wikipedia.org/wiki/Special:Search/$query" ;;
        esac
    fi
fi
