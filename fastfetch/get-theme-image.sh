#!/bin/bash

# Get Theme Logo Path
# Detects the current Quickshell theme and returns the path to the corresponding logo

# Primary source: settings.json (most up-to-date)
SETTINGS="$HOME/.config/quickshell/settings.json"
THEME_NAME=""
if command -v python3 &>/dev/null && [ -f "$SETTINGS" ]; then
    THEME_NAME=$(python3 -c "import json; d=json.load(open('$SETTINGS')); print(d.get('theme',{}).get('current',''))" 2>/dev/null)
fi

# Fallback: read from ThemeManager.qml
if [ -z "$THEME_NAME" ]; then
    THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
    THEME_NAME=$(grep 'themeName:' "$THEME_MANAGER" 2>/dev/null | sed -E 's/.*"(.+)".*/\1/')
fi

# If still no theme found, exit with error
if [ -z "$THEME_NAME" ]; then
    echo "Error: Could not detect theme from settings.json or ThemeManager.qml" >&2
    exit 1
fi

# Convert theme name to lowercase for filename
THEME_LOWER=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]')

# Try simple name first (themename.png), then fall back to themename_arch.png
LOGO_PATH="$HOME/.config/fastfetch/logos/${THEME_LOWER}.png"

if [ ! -f "$LOGO_PATH" ]; then
    LOGO_PATH="$HOME/.config/fastfetch/logos/${THEME_LOWER}_arch.png"
fi

# Check if the logo exists
if [ -f "$LOGO_PATH" ]; then
    echo "$LOGO_PATH"
else
    echo "Error: Logo not found at $HOME/.config/fastfetch/logos/${THEME_LOWER}.png or ${THEME_LOWER}_arch.png" >&2
    exit 1
fi
