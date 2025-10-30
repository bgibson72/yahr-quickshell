#!/bin/bash

# Fastfetch with Kitty Graphics Protocol via Chafa
# This uses chafa's kitty format for pixel-perfect image rendering

# Get the current theme image
IMAGE_PATH="$HOME/.config/fastfetch/current-theme-logo.png"

# Check if image exists
if [ -f "$IMAGE_PATH" ]; then
    # Display the image using chafa with kitty protocol
    chafa -f kitty --scale=0.25 "$IMAGE_PATH"
    echo ""
    # Run fastfetch without logo (since we already displayed the image)
    fastfetch --logo none
else
    # No image found, run with default logo
    fastfetch
fi
