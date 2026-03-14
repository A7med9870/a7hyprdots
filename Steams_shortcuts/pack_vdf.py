#!/usr/bin/env python3
import vdf
import json
import sys

# Read the edited JSON file
with open(sys.argv[1], 'r') as f:  # The first argument: your JSON file
    data = json.load(f)            # Load the data from the JSON

# Write the data back to a binary VDF file
with open(sys.argv[2], 'wb') as f:  # The second argument: the output .vdf file
    vdf.binary_dump(data, f)       # This function is key for binary VDFs

# python3 pack_vdf.py ./shortcuts.json ~/.steam/steam/userdata/1816482424/config/shortcuts.vdf
