#!/bin/bash
# Universal Proton Launcher Script
# Save as: ~/bin/proton-launcher.sh

# Configuration - Try multiple possible Proton locations
PROTON_PATHS=(
    "/usr/share/steam/compatibilitytools.d/proton-cachyos-slr/proton"
    "$HOME/.steam/root/compatibilitytools.d/proton-cachyos-slr/proton"
    "$HOME/.local/share/Steam/compatibilitytools.d/proton-cachyos-slr/proton"
    "$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/proton"
    "$HOME/.local/share/Steam/steamapps/common/Proton 8.0/proton"
    "$HOME/.local/share/Steam/steamapps/common/Proton 7.0/proton"
)

PFX_DIR="$HOME/Games_non_steam"
LOG_DIR="$HOME/Games_non_steam/logsP"

# Find working Proton
PROTON_PATH=""
for path in "${PROTON_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
        PROTON_PATH="$path"
        echo "Found Proton at: $PROTON_PATH"
        break
    fi
done

if [[ -z "$PROTON_PATH" ]]; then
    echo "ERROR: No Proton installation found!"
    echo "Searched in:"
    for path in "${PROTON_PATHS[@]}"; do
        echo "  $path"
    done
    exit 2
fi

# Parse command line arguments
ENV_VARS=()
GAME_ARGS=()
GAME_EXE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            echo "Usage: $0 [ENV_VAR=value ...] /path/to/game.exe [game_args ...]"
            echo "Example: $0 WINEDLLOVERRIDE=\"dinput8=n,b\" /path/to/game.exe -arg1 -arg2"
            exit 0
            ;;
        *=*)
            ENV_VARS+=("$1")
            shift
            ;;
        *)
            if [[ -z "$GAME_EXE" ]]; then
                GAME_EXE="$1"
            else
                GAME_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# Validate we have a game executable
if [[ -z "$GAME_EXE" ]]; then
    echo "ERROR: No game executable specified!"
    echo "Usage: $0 [ENV_VAR=value ...] /path/to/game.exe [game_args ...]"
    exit 4
fi

GAME_DIR="$(dirname "$GAME_EXE")"
GAME_NAME="$(basename "$GAME_EXE" .exe)"
LOG_FILE="$LOG_DIR/${GAME_NAME}.log"

# Validate game executable
if [[ ! -f "$GAME_EXE" ]]; then
    echo "ERROR: Game executable not found: $GAME_EXE"
    exit 3
fi

# Create directories
mkdir -p "$PFX_DIR"
mkdir -p "$LOG_DIR"

# Set Proton environment variables
export STEAM_COMPAT_DATA_PATH="$PFX_DIR"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"

# Optional: Enable Proton logging
export PROTON_LOG=1
export PROTON_LOG_DIR="$LOG_DIR"

# Game-specific environment variables
export DXVK_ASYNC=1
export PULSE_LATENCY_MSEC=60

# Apply custom environment variables from command line
for env_var in "${ENV_VARS[@]}"; do
    echo "Setting environment variable: $env_var"
    export "$env_var"
done

# Debug information
echo "=== Proton Launcher Debug Info ==="
echo "Game: $GAME_EXE"
echo "Game Directory: $GAME_DIR"
echo "Proton: $PROTON_PATH"
echo "Prefix: $PFX_DIR"
echo "Log: $LOG_FILE"
echo "Environment variables: ${ENV_VARS[*]}"
echo "Game arguments: ${GAME_ARGS[*]}"
echo "=================================="

# Run the game with Proton
cd "$GAME_DIR"
echo "Running: \"$PROTON_PATH\" run \"$(basename "$GAME_EXE")\" ${GAME_ARGS[@]}"
"$PROTON_PATH" run "$(basename "$GAME_EXE")" "${GAME_ARGS[@]}" 2>&1 | tee "$LOG_FILE"

# Check exit status
exit_code=${PIPESTATUS[0]}
echo "Game exited with status: $exit_code"

# Check log for errors if failed
if [[ $exit_code -ne 0 ]]; then
    echo "Check the log file for details: $LOG_FILE"
    echo "Last 10 lines of log:"
    tail -10 "$LOG_FILE"
fi

exit $exit_code
