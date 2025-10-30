#!/bin/bash

# Fastfetch Theme Image Selector
# Detects current theme from Quickshell/Hyprland and returns appropriate image

# Default image directory
IMAGE_DIR="$HOME/.config/fastfetch/images"
DEFAULT_IMAGE="$IMAGE_DIR/default.png"

# Try to get theme from Quickshell ThemeManager
THEME_FILE="$HOME/.config/quickshell/ThemeManager.qml"
if [ -f "$THEME_FILE" ]; then
    THEME=$(grep 'themeName:' "$THEME_FILE" | sed -E 's/.*"(.+)".*/\1/')
fi

# If no theme found, try to detect from hyprland active theme
if [ -z "$THEME" ]; then
    HYPR_THEME_FILE="$HOME/.config/hypr/themes/active.conf"
    if [ -f "$HYPR_THEME_FILE" ]; then
        THEME=$(basename "$(readlink -f "$HYPR_THEME_FILE")" .conf)
    fi
fi

# Try to find matching image in theme directory (supports various formats)
if [ -n "$THEME" ]; then
    THEME_DIR="$IMAGE_DIR/$THEME"
    
    # Look for image named after the theme in the theme directory
    for ext in png jpg jpeg gif webp; do
        if [ -f "$THEME_DIR/${THEME}.${ext}" ]; then
            echo "$THEME_DIR/${THEME}.${ext}"
            exit 0
        fi
    done
    
    # Fallback: look for any image in the theme directory
    for ext in png jpg jpeg gif webp; do
        FIRST_IMAGE=$(find "$THEME_DIR" -maxdepth 1 -type f -iname "*.${ext}" 2>/dev/null | head -n 1)
        if [ -n "$FIRST_IMAGE" ]; then
            echo "$FIRST_IMAGE"
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
