#!/bin/bash

# Sync Neovim/AstroVim theme with Quickshell theme

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
NVIM_THEME_SWITCHER="$HOME/.config/nvim/lua/theme-switcher.lua"
NVIM_CONFIG="$HOME/.config/nvim/lua/plugins/astroui.lua"

# Get current theme from Hyprland config
THEME_FILE=$(grep "^source.*themes.*\.conf" "$HYPRLAND_CONF" | sed 's/.*= *//')

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    echo "Error: Could not determine theme file from Hyprland config"
    exit 1
fi

theme_name=$(basename "$THEME_FILE" .conf)

# Map Hyprland theme names to Neovim colorscheme names
# These match the themes in ~/.config/hypr/themes/
# Note: Material theme uses catppuccin as fallback since material colorscheme isn't available
declare -A NVIM_THEME_MAP=(
    ["Catppuccin"]="catppuccin-mocha"
    ["Gruvbox"]="gruvbox"
    ["TokyoNight"]="tokyonight-night"
    ["Dracula"]="dracula"
    ["Everforest"]="everforest"
    ["Nord"]="nord"
    ["RosePine"]="rose-pine"
    ["Kanagawa"]="kanagawa"
    ["NightFox"]="nightfox"
    ["Eldritch"]="eldritch"
    ["Material"]="catppuccin-mocha"
)

nvim_theme="${NVIM_THEME_MAP[$theme_name]}"

if [ -z "$nvim_theme" ]; then
    echo "Warning: No Neovim theme mapping for $theme_name, defaulting to catppuccin-mocha"
    nvim_theme="catppuccin-mocha"
fi

echo "Syncing Neovim theme to: $nvim_theme"

# Create/update the theme-switcher.lua file
cat > "$NVIM_THEME_SWITCHER" << EOF
-- Auto-generated theme switcher for Neovim
-- This file is managed by quickshell/sync-nvim-theme.sh
-- DO NOT EDIT MANUALLY - changes will be overwritten

return {
  theme = "$nvim_theme"
}
EOF

# Update astroui.lua to use the theme from theme-switcher.lua
if [ -f "$NVIM_CONFIG" ]; then
    # Check if the colorscheme line needs updating
    if grep -q 'colorscheme = ".*"' "$NVIM_CONFIG"; then
        sed -i "s/colorscheme = \".*\"/colorscheme = \"$nvim_theme\"/" "$NVIM_CONFIG"
        echo "✓ Updated Neovim colorscheme to: $nvim_theme"
    fi
fi

# Notify running Neovim instances to reload the colorscheme
# This uses nvim --remote if available
if command -v nvim &> /dev/null; then
    # Find all running nvim instances and send reload command
    for server in /tmp/nvim*/0; do
        if [ -S "$server" ]; then
            nvim --server "$server" --remote-send "<Esc>:colorscheme $nvim_theme<CR>" 2>/dev/null || true
        fi
    done
fi

echo "✓ Neovim theme synced"
