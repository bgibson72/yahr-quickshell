#!/bin/bash

# Fastfetch with Kitty Graphics Protocol via Chafa
# This uses chafa's kitty format for pixel-perfect image rendering

# Configuration
SCALE="${1:-0.15}"  # Default scale 0.15, can be overridden as first argument
PADDING=6           # Number of blank lines between image and text

# Get the current theme image
IMAGE_PATH="$HOME/.config/fastfetch/current-theme-logo.png"

# Check if image exists
if [ -f "$IMAGE_PATH" ]; then
    # Display the image using chafa with kitty protocol
    chafa -f kitty --scale="$SCALE" "$IMAGE_PATH"
    
    # Add padding with newlines
    printf '\n%.0s' $(seq 1 $PADDING)
    
    # Run fastfetch without logo (since we already displayed the image)
    fastfetch --logo none
else
    # No image found, run with default logo
    fastfetch
fi
