#!/bin/bash
# Setup sudoers for passwordless SDDM theme sync

SUDOERS_FILE="/etc/sudoers.d/sddm-sync-yahr"
SUDOERS_CONTENT="# Allow SDDM theme sync without password
%wheel ALL=(ALL) NOPASSWD: /usr/bin/cp * /usr/share/sddm/themes/yahr-theme/*
%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /usr/share/sddm/themes/yahr-theme/theme.conf"

echo "Setting up passwordless SDDM theme sync..."
echo ""

# Check if user is in wheel group
if ! groups | grep -q wheel; then
    echo "ERROR: You must be in the 'wheel' group to use sudo"
    echo "Add yourself to wheel group: sudo usermod -aG wheel $USER"
    exit 1
fi

# Create sudoers file
echo "$SUDOERS_CONTENT" | sudo tee "$SUDOERS_FILE" > /dev/null

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create sudoers file"
    exit 1
fi

# Set correct permissions
sudo chmod 0440 "$SUDOERS_FILE"

# Validate sudoers file
if sudo visudo -c -f "$SUDOERS_FILE" &> /dev/null; then
    echo "✓ Sudoers configured successfully!"
    echo ""
    echo "SDDM theme will now sync automatically without password prompts."
    echo ""
    echo "Test it: ~/.config/quickshell/sync-sddm-theme.sh"
else
    echo "ERROR: Failed to validate sudoers file"
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi
