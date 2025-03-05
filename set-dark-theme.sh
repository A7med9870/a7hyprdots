#!/bin/bash

# Set GTK theme, icon theme, and KDE Plasma theme to dark variants
GTK_THEME="Breeze-Dark"          # Change to "Arc-Dark" if you prefer
ICON_THEME="BeautyLine"         # Change to "arc-icon-theme" if you prefer
PLASMA_THEME="Dr460nized"       # Change to "Arc Dark" if you prefer

# Check if the GTK theme is installed
if [[ -d "/usr/share/themes/$GTK_THEME" || -d "$HOME/.themes/$GTK_THEME" ]]; then
    # Set GTK 3 theme
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.wm.preferences theme "$GTK_THEME"

    # Set GTK 4 theme (if applicable)
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

    echo "GTK theme set to $GTK_THEME successfully!"
else
    echo "Error: $GTK_THEME GTK theme is not installed."
    echo "Please install the theme and try again."
    exit 1
fi

# Check if the icon theme is installed
if [[ -d "/usr/share/icons/$ICON_THEME" || -d "$HOME/.icons/$ICON_THEME" ]]; then
    # Set icon theme
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    echo "Icon theme set to $ICON_THEME successfully!"
else
    echo "Error: $ICON_THEME icon theme is not installed."
    echo "Please install the theme and try again."
    exit 1
fi

# Check if the KDE Plasma theme is installed
if [[ -d "/usr/share/plasma/desktoptheme/$PLASMA_THEME" || -d "$HOME/.local/share/plasma/desktoptheme/$PLASMA_THEME" ]]; then
    # Set KDE Plasma theme
    lookandfeeltool -a "$PLASMA_THEME"
    echo "KDE Plasma theme set to $PLASMA_THEME successfully!"
else
    echo "Error: $PLASMA_THEME KDE Plasma theme is not installed."
    echo "Please install the theme and try again."
    exit 1
fi

echo "All themes set to dark variants successfully!"
