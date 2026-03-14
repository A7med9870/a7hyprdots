#!/bin/bash

FILE="/etc/sddm.conf.d/kde_settings.conf"

# Set session to KDE
sudo sed -i '3s/^Session=.*$/Session=plasma.desktop/' "$FILE"

# Create a temporary script that will survive the SDDM restart
cat > /tmp/switch_back_to_hyprland.sh <<EOF
#!/bin/bash
sleep 10
sudo sed -i '3s/^Session=.*$/Session=hyprland/' "$FILE"
rm /tmp/switch_back_to_hyprland.sh
EOF

chmod +x /tmp/switch_back_to_hyprland.sh
nohup /tmp/switch_back_to_hyprland.sh >/dev/null 2>&1 &

# Restart SDDM
sudo systemctl restart sddm
