#!/bin/bash
# Integration snippet for switch-theme.sh
# Add this to your ~/.config/quickshell/switch-theme.sh

# Add this block after the Zed theme sync section (around line 60):

# Sync Vencord/Vesktop theme if script exists
if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then
    echo "Syncing Vencord theme..."
    "$HOME/.config/quickshell/sync-vencord-theme.sh" --theme-file
    echo ""
fi
