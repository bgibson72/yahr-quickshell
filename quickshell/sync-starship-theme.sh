#!/bin/bash

# Sync Starship Prompt Colors with Current Quickshell Theme  
# Only replaces hex color values - preserves ALL glyphs and formatting

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Extract theme name and colors
theme_name=$(grep -E 'property string (themeName|currentTheme):' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_red=$(grep 'property color accentRed:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Syncing Starship colors for theme: $theme_name"

# Update starship.toml with proper color assignments
# color_fg = primary text color
# color_bg = background
# color_accent = accent color for prompt (should be visible!)
# color_red = error color

sed -i "s/^color_fg = .*/color_fg = '$fg_primary'/" "$STARSHIP_CONFIG"
sed -i "s/^color_bg = .*/color_bg = '$bg_base'/" "$STARSHIP_CONFIG"
sed -i "s/^color_accent = .*/color_accent = '$accent_blue'/" "$STARSHIP_CONFIG"
sed -i "s/^color_red = .*/color_red = '$accent_red'/" "$STARSHIP_CONFIG"

# Update theme name in comment
sed -i "s/# Auto-synced with Quickshell Theme: .*/# Auto-synced with Quickshell Theme: $theme_name/" "$STARSHIP_CONFIG"

echo "✓ Updated Starship colors:"
echo "  Foreground: $fg_primary"
echo "  Background: $bg_base"
echo "  Accent: $accent_blue"
echo "  Error: $accent_red"
