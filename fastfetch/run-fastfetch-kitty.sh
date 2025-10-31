#!/bin/bash

# Fastfetch with Theme-Aware Logo
# Optimized for Kitty terminal with fallback for other terminals

# Update the theme logo symlink first
"$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1

# Simply run fastfetch - config.jsonc handles the logo display
# In Kitty terminal, it will use kitty-direct protocol from the config
# The config already points to current-theme-logo.png symlink
fastfetch
