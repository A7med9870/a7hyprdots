#!/bin/bash

# Source paths
paths=(
  "/run/media/ahmed/drivec/Playstation_2_games/"
  "/run/media/ahmed/drivec/PC_GAMES/"
  "/home/ahmed/Games_non_steam/"
  "/home/ahmed/.local/share/Steam/userdata/418183881/config/grid"
  "/home/ahmed/.local/share/Steam/userdata/418183881/config/localconfig.vdf"
  "/home/ahmed/.local/share/Steam/userdata/418183881/config/shortcuts.vdf"
)

# Get additional paths from syncthing config
while IFS= read -r path; do
    paths+=("$path")
done < <(grep -o 'path="[^"]*"' /home/ahmed/.local/state/syncthing/config.xml | sed 's/path="//g' | sed 's/"//g')

# Destination directory
backup_dir="/home/ahmed/linkstobackup"

# Create destination directory if it doesn't exist
mkdir -p "$backup_dir"

# Create symbolic links only if they don't exist
for path in "${paths[@]}"; do
    # Extract the base name (last component of the path)
    base_name=$(basename "$path")
    link_path="$backup_dir/$base_name"

    # Check if the link already exists
    if [[ ! -e "$link_path" ]]; then
        echo "Creating symlink: $link_path -> $path"
        ln -s "$path" "$link_path"
    else
        echo "Symlink already exists: $link_path"
    fi
done
