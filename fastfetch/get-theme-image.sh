#!/bin/bash

# Get Theme Logo Path
# Detects the current Quickshell theme and returns the path to the corresponding logo

# Path to the theme manager file
THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"

# Extract the current theme name
THEME_NAME=$(grep 'themeName:' "$THEME_MANAGER" 2>/dev/null | sed -E 's/.*"(.+)".*/\1/')

# If no theme found, exit with error
if [ -z "$THEME_NAME" ]; then
    echo "Error: Could not detect theme" >&2
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
