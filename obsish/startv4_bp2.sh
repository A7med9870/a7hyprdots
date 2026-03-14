#!/bin/bash
# Universal Proton Launcher Script
# Save as: ~/bin/proton-launcher.sh

# Configuration
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton"
PFX_DIR="$HOME/Games_non_steam"  # Central prefix or game-specific
LOG_DIR="$HOME/Games_non_steam/logsP"

# Parse command line arguments
ENV_VARS=()
GAME_ARGS=()
GAME_EXE=""

# Parse all arguments
for arg in "$@"; do
    # Check if argument contains = (likely an environment variable)
    if [[ "$arg" == *"="* ]]; then
        ENV_VARS+=("$arg")
    else
        # First non-env-var argument is the game executable
        if [[ -z "$GAME_EXE" ]]; then
            GAME_EXE="$arg"
        else
            # Subsequent non-env-var arguments are game arguments
            GAME_ARGS+=("$arg")
        fi
    fi
done

# Validate we have a game executable
if [[ -z "$GAME_EXE" ]]; then
    echo "ERROR: No game executable specified!"
    echo "Usage: $0 [ENV_VAR=value ...] /path/to/game.exe [game_args ...]"
    echo "Example: $0 WINEDLLOVERRIDE=\"dinput8=n,b\" /path/to/game.exe -arg1 -arg2"
    exit 1
fi

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

# Apply custom environment variables from command line
for env_var in "${ENV_VARS[@]}"; do
    echo "Setting environment variable: $env_var"
    export "$env_var"
done

# Debug information
echo "Launching game with Proton..."
echo "Game: $GAME_EXE"
echo "Game Directory: $GAME_DIR"
echo "Proton: $PROTON_PATH"
echo "Prefix: $PFX_DIR"
echo "Log: $LOG_FILE"
echo "Environment variables: ${ENV_VARS[*]}"
echo "Game arguments: ${GAME_ARGS[*]}"

# Run the game with Proton
cd "$GAME_DIR"
"$PROTON_PATH" run "$(basename "$GAME_EXE")" "${GAME_ARGS[@]}" 2>&1 | tee "$LOG_FILE"

# Check exit status
exit_code=${PIPESTATUS[0]}
echo "Game exited with status: $exit_code"
exit $exit_code
