#!/bin/bash

# Fastfetch with Kitty Graphics Protocol
# Uses fastfetch's native kitty protocol support for proper alignment

# Update the theme logo symlink first
"$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1

# Run fastfetch with config (which uses the symlink)
# The config.jsonc already has type: kitty and source: current-theme-logo.png
fastfetch
