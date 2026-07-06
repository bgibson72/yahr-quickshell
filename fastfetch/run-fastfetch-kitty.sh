#!/bin/bash

# Fastfetch with Theme-Aware Logo
# Optimized for Kitty terminal with fallback for other terminals

# Update the theme logo symlink first
"$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1

# Omit the logo when the terminal is too narrow to fit it alongside the
# info text (e.g. 3+ kitty windows tiled in one workspace) -- below this
# many columns, the logo+text layout wraps/overlaps and looks broken.
# Comfortably tuned between a typical 2-window split (~65-70 cols, logo
# looks fine) and a 3-window split (~45-50 cols, logo must go).
MIN_COLS_FOR_LOGO=60

COLS=$(tput cols 2>/dev/null || echo 0)

if [ "$COLS" -gt 0 ] && [ "$COLS" -lt "$MIN_COLS_FOR_LOGO" ]; then
    fastfetch -c "$HOME/.config/fastfetch/config.jsonc" --logo none
else
    fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
fi
