#!/bin/bash

# Define the file path
FILE="/etc/sddm.conf.d/kde_settings.conf"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# 1. First change: Switch to KDE and restart SDDM
sudo sed -i '3s/^Session=.*$/Session=plasma.desktop/' "$FILE"
echo "Session set to plasma.desktop in $FILE"

# 2. Schedule the confirmation dialog to appear in 2 minutes
# We'll use 'at' to schedule a Konsole prompt
SCRIPT_CONTENT=$(cat <<'EOF'
#!/bin/bash
konsole --title "Restore Hyprland?" -e bash -c \
'read -p "Restore Hyprland as default session? (y/N): " answer && \
if [[ $answer =~ [yY] ]]; then \
    sudo sed -i '"'3s/^Session=.*$/Session=hyprland/'"' "/etc/sddm.conf.d/kde_settings.conf" && \
    echo "Hyprland restored as default session"; \
else \
    echo "Keeping Plasma as default session"; \
fi && \
sleep 3'
EOF
)

# Create temporary script
TEMP_SCRIPT="/tmp/restore_hyprland_prompt.sh"
echo "$SCRIPT_CONTENT" > "$TEMP_SCRIPT"
chmod +x "$TEMP_SCRIPT"

# Schedule it to run in 2 minutes
echo "$TEMP_SCRIPT" | at now + 1 minutes

# 3. Restart SDDM to enter KDE immediately
sudo systemctl restart sddm
