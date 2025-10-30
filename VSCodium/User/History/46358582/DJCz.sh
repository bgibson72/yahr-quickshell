#!/bin/bash

# Fastfetch Theme Image Selector
# Detects current theme from Quickshell/Hyprland and returns appropriate image

# Default image directory
IMAGE_DIR="$HOME/.config/fastfetch/images"
DEFAULT_IMAGE="$IMAGE_DIR/default.png"

# Try to get theme from Quickshell ThemeManager
THEME_FILE="$HOME/.config/quickshell/ThemeManager.qml"
if [ -f "$THEME_FILE" ]; then
    THEME=$(grep 'themeName:' "$THEME_FILE" | sed -E 's/.*"(.+)".*/\1/' | tr '[:upper:]' '[:lower:]')
fi

# If no theme found, try to detect from hyprland active theme
if [ -z "$THEME" ]; then
    HYPR_THEME_FILE="$HOME/.config/hypr/themes/active.conf"
    if [ -f "$HYPR_THEME_FILE" ]; then
        THEME=$(basename "$(readlink -f "$HYPR_THEME_FILE")" .conf | tr '[:upper:]' '[:lower:]')
    fi
fi

# Try to find matching image (supports various formats)
if [ -n "$THEME" ]; then
    for ext in png jpg jpeg gif webp; do
        if [ -f "$IMAGE_DIR/${THEME}.${ext}" ]; then
            echo "$IMAGE_DIR/${THEME}.${ext}"
            exit 0
        fi
    done
fi

# Fallback to default image if it exists, otherwise use ASCII art
if [ -f "$DEFAULT_IMAGE" ]; then
    echo "$DEFAULT_IMAGE"
else
    echo "auto"
fi
