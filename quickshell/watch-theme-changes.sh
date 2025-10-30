#!/bin/bash
# ============================================
# Theme Change Watcher
# Monitors settings.json and auto-syncs Vencord
# ============================================

SETTINGS_FILE="$HOME/.config/quickshell/settings.json"
LAST_THEME=""

echo "Theme watcher started - monitoring $SETTINGS_FILE"

while true; do
    # Get current theme from settings
    CURRENT_THEME=$(jq -r '.theme.current' "$SETTINGS_FILE" 2>/dev/null)
    
    # Check if theme changed
    if [ -n "$CURRENT_THEME" ] && [ "$CURRENT_THEME" != "$LAST_THEME" ] && [ "$CURRENT_THEME" != "null" ]; then
        if [ -n "$LAST_THEME" ]; then
            echo "Theme changed: $LAST_THEME → $CURRENT_THEME"
            
            # Sync Vencord theme
            if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then
                "$HOME/.config/quickshell/sync-vencord-theme.sh" --theme-file
                
                # Restart Vesktop if running
                if pgrep -x vesktop > /dev/null; then
                    echo "Restarting Vesktop..."
                    killall vesktop 2>/dev/null
                    sleep 0.5
                    vesktop &>/dev/null &
                    disown
                fi
            fi
        fi
        LAST_THEME="$CURRENT_THEME"
    fi
    
    # Check every 2 seconds
    sleep 2
done
