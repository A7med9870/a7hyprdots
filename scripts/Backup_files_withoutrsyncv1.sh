#!/bin/bash

BACKUP_DIR="$HOME/my-backups"
mkdir -p "$BACKUP_DIR"

CreateBackup() {
    local src="${1/#\~/$HOME}"

    if [ ! -e "$src" ]; then
        echo "Warning: $src doesn't exist"
        return
    fi

    local name=$(basename "$src")

    if [ -f "$src" ]; then
        cp "$src" "$BACKUP_DIR/$name"
        echo "Copied file: $name"
    elif [ -d "$src" ]; then
        cp -r "$src" "$BACKUP_DIR/$name"
        echo "Copied folder: $name"
    fi
}

# Usage
CreateBackup "~/.bashrc"
CreateBackup "~/.config/nvim/"
CreateBackup "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"
CreateBackup "~/.config/dolphinrc"
CreateBackup "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"
CreateBackup "~/.config/hypr/"
CreateBackup "~/.config/qt5ct/qt5ct.conf"
CreateBackup "~/.config/kdeglobals"
CreateBackup "~/.config/plasma-org.kde.plasma.desktop-appletsrc"
CreateBackup "~/.config/kwinrc"
CreateBackup "~/.local/share/konsole/Garuda.profile"
CreateBackup "~/.config/konsolerc"
CreateBackup "~/.config/fish/"
# CreateBackup "~/.config/fish/fish_variables"
CreateBackup "~/.config/autostart/"
CreateBackup "~/.config/gtk-3.0/settings.ini"
CreateBackup "~/.config/menus/applications.menu"
CreateBackup "~/.config/syncthingtray.ini"
CreateBackup "~/.config/spectaclerc"
CreateBackup "~/.config/ksnip/ksnip.conf"
CreateBackup "~/.config/My_wallpapers"
CreateBackup "~/.config/vesktop/"
CreateBackup "~/.config/goverlay/"
CreateBackup "~/.config/gtk-4.0/"
CreateBackup "~/.config/gtk-3.0"
CreateBackup "~/.config/xsettingsd"
CreateBackup "~/.config/blender"
CreateBackup "~/.config/zed"
CreateBackup "~/.config/PCSX2"
CreateBackup "~/.config/VacuumTube"
CreateBackup "~/.config/libreoffice"
CreateBackup "~/.config/micro"
CreateBackup "~/.config/okularrc"
CreateBackup "~/.config/dolphinrc"
CreateBackup "~/.config/kdeglobals"
CreateBackup "/etc/default/grub"
CreateBackup "~/.config/mimeapps.list"
CreateBackup "~/.config/qt6ct"
CreateBackup "~/.config/qt5ct"
CreateBackup "/etc/sddm.conf"
CreateBackup "~/.local/share/user-places.xbel"
# CreateBackup "$HOME/homebrew"

# tar -czf my-backups.tar.gz -C ~/my-backups .
# cp ~/my-backups.tar.gz ~/Documents/BlenderProjects/
