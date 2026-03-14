#!/usr/bin/env python3
"""
Steam Non-Steam Shortcuts Sync Script
Usage: python3 sync_steam_shortcuts.py [source_profile_id] [target_profile_id]
# Syntax: python3 script.py SOURCE_ID TARGET_ID
# python3 sync_steam_shortcuts.py 1816482424 123456789
"""

import vdf
import json
import sys
import os
from pathlib import Path

# Define the base Steam userdata path
STEAM_USERDATA_PATH = Path.home() / ".steam" / "steam" / "userdata"

def get_shortcuts_path(steam_id):
    """Get the full path to the shortcuts.vdf file for a given SteamID"""
    return STEAM_USERDATA_PATH / str(steam_id) / "config" / "shortcuts.vdf"

def read_shortcuts(steam_id):
    """Read and parse the shortcuts.vdf file for a profile. Returns a VDF dict."""
    path = get_shortcuts_path(steam_id)
    try:
        with open(path, 'rb') as f:
            return vdf.binary_load(f)
    except FileNotFoundError:
        print(f"Error: No shortcuts file found for profile {steam_id}. Does the directory exist?")
        sys.exit(1)

def write_shortcuts(steam_id, data):
    """Write data back to the shortcuts.vdf file for a profile."""
    path = get_shortcuts_path(steam_id)
    # Ensure the config directory exists
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, 'wb') as f:
        vdf.binary_dump(data, f)
    print(f"Successfully wrote shortcuts to profile {steam_id}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 sync_steam_shortcuts.py [source_profile_id] [target_profile_id]")
        print("Example: python3 sync_steam_shortcuts.py 1816482424 123456789")
        sys.exit(1)

    source_id = sys.argv[1]
    target_id = sys.argv[2]

    # Read the shortcuts from the SOURCE profile
    print(f"Reading shortcuts from source profile {source_id}...")
    source_data = read_shortcuts(source_id)

    # Write them to the TARGET profile
    print(f"Writing shortcuts to target profile {target_id}...")
    write_shortcuts(target_id, source_data)

    print("Sync complete!")

if __name__ == "__main__":
    main()
