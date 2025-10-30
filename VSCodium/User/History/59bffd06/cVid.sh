#!/bin/bash

# Dynamic Fastfetch Launcher with Theme-Aware Images
# This script detects the current theme and runs fastfetch with the appropriate image

# Get the theme image path
IMAGE_PATH=$("$HOME/.config/fastfetch/get-theme-image.sh")

# Check if we got a valid image path
if [ -f "$IMAGE_PATH" ]; then
    # Run fastfetch with the theme image using chafa with high quality settings
    if command -v chafa &> /dev/null; then
        fastfetch \
            --chafa-canvas-mode TRUECOLOR \
            --chafa-symbols all \
            --chafa-dither-mode diffusion
    # Fallback to kitty protocol if in kitty terminal
    elif [ "$TERM" = "xterm-kitty" ] || [ -n "$KITTY_WINDOW_ID" ]; then
        fastfetch --logo "$IMAGE_PATH" --logo-type kitty --logo-width 30 --logo-height 15
    # Fallback to default ASCII logo
    else
        echo "Note: Install 'chafa' for image support: sudo pacman -S chafa"
        fastfetch
    fi
else
    # No image found, run with default logo
    fastfetch
fi
