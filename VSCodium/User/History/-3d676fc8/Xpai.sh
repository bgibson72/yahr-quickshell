#!/bin/bash

# Fastfetch with Theme-Aware Logo
# Uses different methods depending on terminal capabilities

# Update the theme logo symlink first
"$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1

IMAGE_PATH="$HOME/.config/fastfetch/current-theme-logo.png"

# Check if we're in a real Kitty terminal
if [ -n "$KITTY_WINDOW_ID" ] || [ "$TERM" = "xterm-kitty" ]; then
    # In Kitty: use fastfetch's native kitty protocol (should work in real Kitty)
    fastfetch
else
    # In other terminals (like VSCode): use chafa method for compatibility
    if [ -f "$IMAGE_PATH" ] && command -v chafa &> /dev/null; then
        # Use chafa with kitty format and proper sizing
        chafa -f symbols --symbols vhalf --size 40x20 "$IMAGE_PATH"
        echo ""
        fastfetch --logo none
    else
        # Fallback to default
        fastfetch
    fi
fi
