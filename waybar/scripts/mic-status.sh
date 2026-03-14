#!/bin/bash

volume=$(pamixer --default-source --get-volume)
muted=$(pamixer --default-source --get-mute)

if [ "$muted" = "true" ]; then
    echo '{"text": "", "class": "muted", "tooltip": "Microphone Muted"}'
else
    echo "{\"text\": \"$volume% \", \"class\": \"\", \"tooltip\": \"Microphone Volume: $volume%\"}"
fi
