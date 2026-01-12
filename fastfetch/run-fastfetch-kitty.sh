#!/bin/bash

# Fastfetch with Theme-Aware Logo
# Optimized for Kitty terminal with fallback for other terminals

# Update the theme logo symlink first
"$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1

# Run fastfetch with config file
fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
