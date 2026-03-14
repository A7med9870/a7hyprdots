#!/bin/bash
mkdir -p ~/.local/share/applicationsD/
for file in ~/Documents/obsi/Liuounx/desktop_shortcuts/*.desktop; do
    ln -sf "$file" ~/.local/share/applicationsD/
done
# mkdir -p ~/.local/share/applications/
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/Obsidian_appimage.desktop    ~/.local/share/applications/Obsidian_appimage.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/GTAIV.desktop                ~/.local/share/applications/GTAIV.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/GTASA.desktop                ~/.local/share/applications/GTASA.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/NFSCO.desktop                ~/.local/share/applications/NFSCO.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/NFSMW.desktop                ~/.local/share/applications/NFSMW.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/Galemm.desktop               ~/.local/share/applications/Galemm.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/ProtonAhmed.desktop          ~/.local/share/applications/ProtonAhmed.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/Minecraft.desktop            ~/.local/share/applications/Minecraft.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/pcsx2.desktop                ~/.local/share/applications/pcsx2.desktop
# ln -sf $HOME/Documents/obsi/Liuounx/desktop_shortcuts/VaccumTube.desktop           ~/.local/share/applications/VaccumTube.desktop
#
