#!/bin/bash

# Loop through all files in the current directory
for file in *; do
    # Check if the file is an image or video
    if [[ "$file" =~ ^(IMG-|.*_)[0-9]{8}[-_][0-9]{6}.*\.(jpg|mp4)$ ]]; then
        # Extract date and time from the filename
        if [[ "$file" =~ ^IMG-([0-9]{4})([0-9]{2})([0-9]{2})-WA[0-9]{4}\.jpg$ ]]; then
            # For IMG-YYYYMMDD-WAXXXX.jpg format
            year=${BASH_REMATCH[1]}
            month=${BASH_REMATCH[2]}
            day=${BASH_REMATCH[3]}
            time="120000" # Default time if not available
        elif [[ "$file" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.mp4$ ]]; then
            # For YYYYMMDD_HHMMSS.mp4 format
            year=${BASH_REMATCH[1]}
            month=${BASH_REMATCH[2]}
            day=${BASH_REMATCH[3]}
            hour=${BASH_REMATCH[4]}
            minute=${BASH_REMATCH[5]}
            second=${BASH_REMATCH[6]}
            time="${hour}${minute}${second}"
        fi

        # Format the date and time for the touch command
        touch -t "${year}${month}${day}${time}" "$file"
        echo "Updated timestamp for $file to ${year}-${month}-${day} ${hour}:${minute}:${second}"
    fi
done
