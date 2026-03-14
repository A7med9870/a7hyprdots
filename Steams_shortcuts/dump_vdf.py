#!/usr/bin/env python3
import vdf
import json
import sys

# Load the binary VDF file
with open(sys.argv[1], 'rb') as f:  # The first argument you pass to the script
    data = vdf.binary_load(f)      # This function is key for binary VDFs

# Write the data to a JSON file
with open(sys.argv[2], 'w') as f:   # The second argument you pass to the script
    json.dump(data, f, indent=4)   # Make the JSON pretty and readable

# python3 dump_vdf.py ~/.steam/steam/userdata/1816482424/config/shortcuts.vdf ./shortcuts.json
