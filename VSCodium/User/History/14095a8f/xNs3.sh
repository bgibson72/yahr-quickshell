#!/bin/bash

# Update the theme logo symlink for fastfetch
# This should be called when your theme changes

THEME_IMAGE=$("$HOME/.config/fastfetch/get-theme-image.sh")
SYMLINK_PATH="$HOME/.config/fastfetch/current-theme-logo.png"

if [ -f "$THEME_IMAGE" ]; then
    ln -sf "$THEME_IMAGE" "$SYMLINK_PATH"
else
    # Remove symlink if no theme image exists
    rm -f "$SYMLINK_PATH"
fi
