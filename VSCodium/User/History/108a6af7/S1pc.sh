#!/bin/bash

# Quickshell Theme Switcher Integration
# This script should be called after changing themes in Quickshell

# Update fastfetch logo symlink
"$HOME/.config/fastfetch/update-theme-logo.sh"

# Optionally reload kitty config (if in Kitty terminal)
if [ "$TERM" = "xterm-kitty" ] && command -v kitten &> /dev/null; then
    kitten @ set-colors --configured ~/.config/kitty/themes/current-theme.conf
fi

echo "Theme integration complete!"
