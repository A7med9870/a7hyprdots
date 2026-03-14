#!/bin/bash

# Configuration - Edit these paths as needed
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  # Get script directory
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton"  # Your working Proton
PFX_DIR="$HOME/Games_non_steam/pfx"                             # Central prefix location

# Parse command line arguments
if [[ $# -eq 1 ]]; then
    # If one argument is provided, assume it's the game executable
    GAME_EXE="$(basename "$1")"
    GAME_DIR="$(dirname "$1")"
elif [[ $# -eq 2 ]]; then
    # If two arguments are provided, assume first is script, second is executable
    # (This handles cases like your example: start.sh /path/to/game.exe)
    GAME_EXE="$(basename "$2")"
    GAME_DIR="$(dirname "$2")"
else
    # No arguments provided, use script directory
    GAME_DIR="$SCRIPT_DIR"
    GAME_EXE=""
fi

# Auto-detect game executable if GAME_EXE is not set
if [[ -z "$GAME_EXE" ]]; then
    echo "Searching for game executable in $GAME_DIR..."
    # Look for common Windows executables (case-insensitive)
    possible_exes=($(find "$GAME_DIR" -maxdepth 1 -type f -iname "*.exe" -exec basename {} \;))

    if [[ ${#possible_exes[@]} -eq 0 ]]; then
        echo "ERROR: No .exe file found in $GAME_DIR"
        exit 1
    elif [[ ${#possible_exes[@]} -eq 1 ]]; then
        GAME_EXE="${possible_exes[0]}"
        echo "Auto-selected executable: $GAME_EXE"
    else
        echo "Multiple executables found:"
        for i in "${!possible_exes[@]}"; do
            echo "$((i+1)). ${possible_exes[$i]}"
        done
        read -p "Select executable (1-${#possible_exes[@]}): " choice
        if [[ $choice -ge 1 && $choice -le ${#possible_exes[@]} ]]; then
            GAME_EXE="${possible_exes[$((choice-1))]}"
        else
            echo "Invalid selection. Exiting."
            exit 1
        fi
    fi
fi

# Set log file name based on game executable
LOG_FILE="${GAME_EXE%.*}_log.txt"  # Removes .exe and appends _log.txt

# Create directories
mkdir -p "$PFX_DIR"
mkdir -p "$(dirname "$LOG_FILE")"  # For logs if enabled

# Environment setup
export STEAM_COMPAT_DATA_PATH="$PFX_DIR"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export DXVK_STATE_CACHE_PATH="$HOME/.cache/dxvk-cache-pool"

# Uncomment for debugging if needed:
# export PROTON_LOG=1
# export WINEDEBUG="-all"

# Run the game
cd "$GAME_DIR"
echo "Launching $GAME_EXE with GE-Proton from $GAME_DIR..."
"$PROTON_PATH" run "$GAME_EXE" 2>&1 | tee "$LOG_FILE"
