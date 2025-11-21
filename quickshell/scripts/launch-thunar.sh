#!/bin/bash

# Wrapper script to launch Thunar with correct GTK theme environment
# This ensures icon theme is properly loaded when launched from Quickshell

# Read current GTK icon theme from settings
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    ICON_THEME=$(grep "gtk-icon-theme-name" "$HOME/.config/gtk-3.0/settings.ini" | cut -d'=' -f2)
    export GTK_ICON_THEME="$ICON_THEME"
fi

# Launch Thunar with any arguments passed
exec thunar "$@"
