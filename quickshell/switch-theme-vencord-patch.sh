#!/bin/bash
# This patches the switch-theme.sh to add Vencord reload reminder

THEME_SWITCHER="$HOME/.config/quickshell/switch-theme.sh"

# Read the file
CONTENT=$(cat "$THEME_SWITCHER")

# Replace the Vencord sync section
NEW_CONTENT=$(cat "$THEME_SWITCHER" | sed '/# Sync Vencord\/Vesktop theme/,/^fi$/c\
# Sync Vencord/Vesktop theme\
if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then\
    echo "Syncing Vencord theme..."\
    "$HOME/.config/quickshell/sync-vencord-theme.sh" --theme-file\
    echo -e "${GREEN}✓ Vencord theme synced${NC}"\
    echo -e "${YELLOW}  → Reload Vesktop (Ctrl+R) to see changes${NC}"\
    \
    # Send desktop notification if notify-send is available\
    if command -v notify-send \&> /dev/null; then\
        notify-send "Theme Switched: $THEME" "Reload Vesktop (Ctrl+R) to apply Vencord theme" -i preferences-desktop-theme 2>/dev/null \&\
    fi\
    echo ""\
fi' | head -70)

echo "$NEW_CONTENT" | head -73 > "${THEME_SWITCHER}.tmp"
tail -n +71 "$THEME_SWITCHER" >> "${THEME_SWITCHER}.tmp"
mv "${THEME_SWITCHER}.tmp" "$THEME_SWITCHER"
chmod +x "$THEME_SWITCHER"

echo "✓ switch-theme.sh updated with Vencord reload reminder"
