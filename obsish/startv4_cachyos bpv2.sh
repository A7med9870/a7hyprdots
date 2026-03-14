#!/bin/bash
# Universal Proton Launcher Script
# Save as: ~/bin/proton-launcher.sh

# Configuration
PROTON_PATH="/usr/share/steam/compatibilitytools.d/proton-cachyos-slr/proton"
PFX_DIR="$HOME/Games_non_steam"  # Central prefix or game-specific
LOG_DIR="$HOME/Games_non_steam/logsP"

# Parse command line arguments
ENV_VARS=()
GAME_ARGS=()
EXTRA_COMMANDS=()
GAME_EXE=""
IN_EXTRA_COMMANDS=false

# Parse all arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            echo "Usage: $0 [ENV_VAR=value ...] /path/to/game.exe [game_args ...] { extra command; another command; }"
            echo "Example: $0 WINEDLLOVERRIDE=\"dinput8=n,b\" /path/to/game.exe -arg1 -arg2 { echo \"Game starting\"; sleep 2; }"
            exit 0
            ;;
        {)
            # Start of extra commands section
            IN_EXTRA_COMMANDS=true
            shift
            ;;
        })
            # End of extra commands section
            IN_EXTRA_COMMANDS=false
            shift
            ;;
        *=*)
            if [[ "$IN_EXTRA_COMMANDS" == true ]]; then
                # If we're inside extra commands, treat as part of the command
                EXTRA_COMMANDS+=("$1")
            else
                # Arguments with = are environment variables
                ENV_VARS+=("$1")
            fi
            shift
            ;;
        *)
            if [[ "$IN_EXTRA_COMMANDS" == true ]]; then
                # Inside extra commands section
                EXTRA_COMMANDS+=("$1")
            elif [[ -z "$GAME_EXE" ]]; then
                # First non-env-var argument is the game executable
                GAME_EXE="$1"
            else
                # Subsequent arguments are game arguments
                GAME_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# Validate we have a game executable
if [[ -z "$GAME_EXE" ]]; then
    echo "ERROR: No game executable specified!"
    echo "Usage: $0 [ENV_VAR=value ...] /path/to/game.exe [game_args ...] { extra command; another command; }"
    echo "Example: $0 WINEDLLOVERRIDE=\"dinput8=n,b\" /path/to/game.exe -arg1 -arg2 { echo \"Game starting\"; sleep 2; }"
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
if [[ ${#EXTRA_COMMANDS[@]} -gt 0 ]]; then
    echo "Extra commands: ${EXTRA_COMMANDS[*]}"
fi

# Function to execute extra commands
execute_extra_commands() {
    if [[ ${#EXTRA_COMMANDS[@]} -gt 0 ]]; then
        echo "Executing extra commands..."
        # Join the commands array into a string and execute
        local cmd_string="${EXTRA_COMMANDS[*]}"
        # Use eval to properly handle the command string
        eval "$cmd_string"
        local cmd_exit=$?
        if [[ $cmd_exit -ne 0 ]]; then
            echo "Warning: Extra commands exited with status: $cmd_exit"
        fi
    fi
}

# Execute extra commands before launching the game
execute_extra_commands

# Run the game with Proton
cd "$GAME_DIR"
"$PROTON_PATH" run "$(basename "$GAME_EXE")" "${GAME_ARGS[@]}" 2>&1 | tee "$LOG_FILE"

# Check exit status
exit_code=${PIPESTATUS[0]}
echo "Game exited with status: $exit_code"
exit $exit_code
