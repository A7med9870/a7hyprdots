#!/usr/bin/env bash

### Full credit for this script to https://github.com/TheGassyNinja

export DISPLAY=:0
current=$(date +%H-%M-%S-%d-%m-%Y).png


if [[ -z "${1}" ]]; then
		import -window root "${HOME}/${current}" || exit 0 # If no argument, full screen (all monitors)
else
		import "${HOME}/${current}" || exit 0 # Custom selection, or click a window
fi


notify-send "Screenshot ${current} taken successfully!"
