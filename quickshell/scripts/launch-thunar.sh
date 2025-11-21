#!/bin/bash

# Wrapper script to launch Thunar with correct GTK theme environment
# This ensures icon theme is properly loaded when launched from Quickshell

# Get icon theme from gsettings (preferred) or gtk-3.0 settings
ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")

if [ -z "$ICON_THEME" ] && [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    ICON_THEME=$(grep "gtk-icon-theme-name" "$HOME/.config/gtk-3.0/settings.ini" | cut -d'=' -f2)
fi

# Export all relevant GTK environment variables
if [ -n "$ICON_THEME" ]; then
    export GTK_ICON_THEME="$ICON_THEME"
fi

# Also export the full GTK theme if available
GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
if [ -n "$GTK_THEME" ]; then
    export GTK_THEME="$GTK_THEME"
fi

# Launch Thunar with any arguments passed
exec thunar "$@"
