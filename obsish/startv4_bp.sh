#!/bin/bash
# Universal Proton Launcher Script
# Save as: ~/bin/proton-launcher.sh

# Configuration
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton"
PFX_DIR="$HOME/Games_non_steam"  # Central prefix or game-specific
LOG_DIR="$HOME/.cache/proton_logs"

# Get game executable from command line argument
if [[ $# -eq 0 ]]; then
    echo "ERROR: No game executable specified!"
    echo "Usage: $0 /path/to/game.exe"
    exit 1
fi

GAME_EXE="$1"
GAME_DIR="$(dirname "$GAME_EXE")"
GAME_NAME="$(basename "$GAME_EXE" .exe)"
LOG_FILE="$LOG_DIR/${GAME_NAME}.log"

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
mkdir -p "$LOG_DIR"

# Set Proton environment variables
export STEAM_COMPAT_DATA_PATH="$PFX_DIR"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"

# Optional: Enable Proton logging (comment out if not needed)
export PROTON_LOG=1
export PROTON_LOG_DIR="$LOG_DIR"

# Game-specific environment variables
export DXVK_ASYNC=1       # Async shader compilation
export PULSE_LATENCY_MSEC=60  # Audio latency adjustment
# export DXVK_HUD=compiler  # Uncomment for debugging

# Debug information
echo "Launching game with Proton..."
echo "Game: $GAME_EXE"
echo "Game Directory: $GAME_DIR"
echo "Proton: $PROTON_PATH"
echo "Prefix: $PFX_DIR"
echo "Log: $LOG_FILE"

# Run the game with Proton
cd "$GAME_DIR"
"$PROTON_PATH" run "$(basename "$GAME_EXE")" 2>&1 | tee "$LOG_FILE"

# Check exit status
exit_code=${PIPESTATUS[0]}
echo "Game exited with status: $exit_code"
exit $exit_code
