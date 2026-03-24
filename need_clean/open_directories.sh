#!/bin/bash

# List of directories to open in Dolphin
directories=(
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/.config/dolphin"
    "$HOME/.config/plasma-workspace"
    "/etc"
)

# Open each directory in Dolphin
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        dolphin "$dir" &
    else
        echo "Directory $dir does not exist."
    fi
done
