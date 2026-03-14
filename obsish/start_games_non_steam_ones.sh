#!/bin/bash

# Set paths
GAME_DIR="$HOME/Desktop/Need for Speed - Carbon"
GAME_EXE="NFSC.exe"
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton"  # Path to your GE-Proton
PFX_DIR="$HOME/Games_non_steam/pfx"  # this is where the games pfx at

# Create directories if needed
mkdir -p "$PFX_DIR"

# Set environment variables (matching your working command)
export STEAM_COMPAT_DATA_PATH="$PFX_DIR"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export DXVK_STATE_CACHE_PATH="$HOME/.cache/dxvk-cache-pool"

# Run the game (same as your working command)
cd "$GAME_DIR"
"$PROTON_PATH" run "$GAME_EXE"
