#!/bin/bash

# Change to the target directory
cd ~/Documents/obsi/Liuounx/

# Loop through each .png file in the directory
for file in *.png; do
    # Extract the date (assuming the filename format is YYYY-MM-DD.png)
    date=$(echo "$file" | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2})\.png/\1/')
    
    # Convert the date to a timestamp (epoch time)
    timestamp=$(date -d "$date" +%s)
    
    # Set the access and modification times to the extracted date
    touch -t $(date -d @$timestamp "+%Y%m%d%H%M.%S") "$file"
done
