#!/bin/bash

# Update Theme Logo Symlink
# This script updates the symlink to point to the current theme's logo

# Get the current theme logo path
THEME_LOGO=$("$HOME/.config/fastfetch/get-theme-image.sh")

# Check if we got a valid logo path
if [ $? -eq 0 ] && [ -f "$THEME_LOGO" ]; then
    # Create/update symlink
    ln -sf "$THEME_LOGO" "$HOME/.config/fastfetch/current-theme-logo.png"
    echo "Updated logo symlink to: $THEME_LOGO"
else
    echo "Failed to update logo symlink" >&2
    exit 1
fi
