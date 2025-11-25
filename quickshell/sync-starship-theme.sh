#!/bin/bash

# Sync Starship Prompt Colors with Current Hyprland Theme  
# Updates the palette colors - preserves ALL glyphs and formatting

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Get current theme from Hyprland config
THEME_FILE=$(grep "^source.*themes.*\.conf" "$HYPRLAND_CONF" | sed 's/.*= *//')

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    echo "Error: Could not determine theme file from Hyprland config"
    exit 1
fi

theme_name=$(basename "$THEME_FILE" .conf)

# Extract colors from Hyprland theme file
get_color() {
    local color_var="$1"
    grep "^$color_var" "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1
}

# Get theme colors
fg_primary=$(get_color '\$fg-primary')
bg_base=$(get_color '\$bg-base')
bg_mantle=$(get_color '\$bg-mantle')
surface0=$(get_color '\$surface-0')
accent_blue=$(get_color '\$accent-blue')
accent_cyan=$(get_color '\$accent-cyan')
accent_green=$(get_color '\$accent-green')
accent_orange=$(get_color '\$accent-orange')
accent_purple=$(get_color '\$accent-purple')
accent_red=$(get_color '\$accent-red')
accent_yellow=$(get_color '\$accent-yellow')

# Fallback colors if some don't exist
[ -z "$bg_mantle" ] && bg_mantle="$bg_base"
[ -z "$surface0" ] && surface0="$bg_base"
[ -z "$accent_cyan" ] && accent_cyan="$accent_blue"
[ -z "$accent_orange" ] && accent_orange="$accent_yellow"
[ -z "$accent_purple" ] && accent_purple="$accent_blue"

echo "Syncing Starship colors for theme: $theme_name"

# Update theme name in comment
sed -i "s/# Auto-synced with Quickshell Theme: .*/# Auto-synced with Quickshell Theme: $theme_name/" "$STARSHIP_CONFIG"

# Update the minimal palette colors using sed
sed -i "s/^color_fg = .*/color_fg = '#$fg_primary'/" "$STARSHIP_CONFIG"
sed -i "s/^color_bg = .*/color_bg = '#$bg_base'/" "$STARSHIP_CONFIG"
sed -i "s/^color_accent = .*/color_accent = '#$accent_green'/" "$STARSHIP_CONFIG"
sed -i "s/^color_red = .*/color_red = '#$accent_red'/" "$STARSHIP_CONFIG"

echo "✓ Palette colors updated (minimal prompt)"
echo "  Theme: $theme_name"
echo "  Accent: #$accent_green"
echo ""
echo "Restart terminal to see changes: exec zsh"
echo "  Theme: $theme_name"
echo "  Background: #$bg_base"
echo "  Accent: #$accent_green"
echo ""
echo "Restart terminal to see changes: exec zsh"
