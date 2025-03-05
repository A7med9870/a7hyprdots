#!/bin/bash

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Get the current month (short format) and year
MONTH=$(date +%b | tr '[:upper:]' '[:lower:]')  # e.g., nov
YEAR=$(date +%Y)                               # e.g., 2024

# Define the directory path dynamically
DIR="/home/ahmed/Documents/obsi/Daily Notes/${YEAR}/${MONTH}/"
echo "Directory: $DIR"

# Ensure the directory exists
mkdir -p "$DIR"

# Construct the full file path
FILE="${DIR}${TODAY}.md"
echo "File to open: $FILE"

# Check if the file exists, and create it if it doesn't
if [ ! -f "$FILE" ]; then
    echo "File does not exist. Creating the file..."
    touch "$FILE"
fi

# Open the file with micro editor
micro "$FILE"
