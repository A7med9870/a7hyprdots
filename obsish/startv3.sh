#!/bin/bash

# Configuration
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton"
GAME_EXE="/media/sdc1/PC_GAMES/NfSCarbon/NFSC.exe"
GAME_DIR="$(dirname "$GAME_EXE")"
PFX_DIR="$HOME/Games_non_steam/pfx"  # Specific prefix for this game
LOG_FILE="$HOME/.cache/nfsc_log.txt"

# Validate paths
if [[ ! -f "$PROTON_PATH" ]]; then
    echo "ERROR: Proton not found at $PROTON_PATH"
    exit 1
fi

if [[ ! -f "$GAME_EXE" ]]; then
    echo "ERROR: Game executable not found: $GAME_EXE"
    exit 1
fi

# Create directories
mkdir -p "$PFX_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Set Proton environment variables
export STEAM_COMPAT_DATA_PATH="$PFX_DIR"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export PROTON_LOG=1  # Enable Proton logging
export PROTON_LOG_DIR="$HOME/ProtonLogs"

# Game-specific environment variables for NFS Carbon
export DXVK_HUD=compiler  # Show shader compilation info
export DXVK_ASYNC=1       # Async shader compilation (reduces stuttering)
export PULSE_LATENCY_MSEC=60  # Audio latency adjustment

# Debug information
echo "Launching Game Proton..."
echo "Game: $GAME_EXE"
echo "Proton: $PROTON_PATH"
echo "Prefix: $PFX_DIR"
echo "Log: $LOG_FILE"

# Run the game with Proton
cd "$GAME_DIR"
"$PROTON_PATH" run "$GAME_EXE" 2>&1 | tee "$LOG_FILE"

# Check exit status
exit_code=${PIPESTATUS[0]}
echo "Game exited with status: $exit_code"
exit $exit_code
