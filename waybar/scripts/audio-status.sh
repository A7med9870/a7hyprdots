#!/bin/bash

volume=$(pamixer --get-volume)
muted=$(pamixer --get-mute)

# Get device type for appropriate icon
device_info=$(pactl list sinks | grep -A 10 "State: RUNNING" | head -11 || pactl list sinks | grep -A 10 "State: IDLE" | head -11)

if echo "$device_info" | grep -qi "headphone"; then
    icon=""
elif echo "$device_info" | grep -qi "headset"; then
    icon=""
elif echo "$device_info" | grep -qi "bluetooth"; then
    icon=""
else
    # Default volume icons based on volume level
    if [ "$volume" -eq 0 ]; then
        icon=""
    elif [ "$volume" -lt 50 ]; then
        icon=""
    else
        icon=""
    fi
fi

if [ "$muted" = "true" ]; then
    echo "{\"text\": \" $icon\", \"class\": \"muted\", \"tooltip\": \"Audio Muted\"}"
else
    echo "{\"text\": \"$volume% $icon\", \"class\": \"\", \"tooltip\": \"Volume: $volume%\"}"
fi
