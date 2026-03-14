#!/bin/bash

# Path to the file containing the list of apps
APP_LIST="/home/ahmed/Documents/obsi/Liuounx/installed-packages.md"

# Check if the file exists
if [ ! -f "$APP_LIST" ]; then
  echo "File $APP_LIST not found!"
  exit 1
fi

# Array to store apps to install
apps_to_install=()

# Read the file line by line
while IFS= read -r app; do
  # Skip empty lines
  if [ -z "$app" ]; then
    continue
  fi

  # Check if the app is already installed
  if pacman -Qi "$app" &>/dev/null; then
    echo "$app is already installed. Skipping."
    continue
  fi

  # Ask the user for confirmation
  read -p "Do you want to install $app? (y/n): " choice </dev/tty

  # If the user confirms, add the app to the install list
  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    apps_to_install+=("$app")
  else
    echo "Skipping $app."
  fi
done < "$APP_LIST"

# If there are apps to install, install them one by one
if [ ${#apps_to_install[@]} -gt 0 ]; then
  echo "Starting installation process..."
  for app in "${apps_to_install[@]}"; do
    echo "Installing $app..."
    sudo pacman -S --noconfirm "$app"
    if [ $? -eq 0 ]; then
      echo "$app installed successfully."
    else
      echo "Failed to install $app. Skipping."
    fi
  done
  echo "Installation process completed."
else
  echo "No apps selected for installation."
fi
