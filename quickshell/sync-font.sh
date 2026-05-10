#!/bin/bash
# sync-font.sh — Apply the UI font to hyprlock and GTK
# Usage: sync-font.sh [font-name]
#        If no argument provided, reads from settings.json

SETTINGS_FILE="$HOME/.config/quickshell/settings.json"

if [[ -n "$1" ]]; then
    FONT="$1"
else
    FONT=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('general',{}).get('uiFont','Sen'))" 2>/dev/null)
    FONT="${FONT:-Sen}"
fi

# Update hyprlock.conf font variable
HYPRLOCK="$HOME/.config/hypr/hyprlock.conf"
if [[ -f "$HYPRLOCK" ]]; then
    sed -i "s/^\\\$font = .*$/\$font = $FONT/" "$HYPRLOCK"
    echo "✓ hyprlock font set to: $FONT"
else
    echo "⚠ hyprlock.conf not found at $HYPRLOCK"
fi

# Update GTK3 settings
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
if [[ -f "$GTK3_SETTINGS" ]]; then
    sed -i "s/^gtk-font-name=.*/gtk-font-name=$FONT 10/" "$GTK3_SETTINGS"
    echo "✓ GTK3 font set to: $FONT 10"
else
    echo "⚠ gtk-3.0/settings.ini not found at $GTK3_SETTINGS"
fi

# Apply via gsettings for running GNOME/GTK apps
gsettings set org.gnome.desktop.interface font-name "$FONT 10" 2>/dev/null && \
    echo "✓ gsettings font updated" || \
    echo "⚠ gsettings not available (normal on non-GNOME desktops)"

echo "✓ System font sync complete: $FONT"
