#!/bin/bash

# Sync Starship Prompt Colors with Current Quickshell Theme
# Uses Starship's palette feature to update only colors, preserving custom format

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_BACKUP="$HOME/.config/starship.toml.backup"

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found at $THEME_MANAGER"
    exit 1
fi

# Extract theme colors
theme_name=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_cyan=$(grep 'property color accentCyan:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_green=$(grep 'property color accentGreen:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_yellow=$(grep 'property color accentYellow:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_secondary=$(grep 'property color fgSecondary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface0=$(grep 'property color surface0:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface1=$(grep 'property color surface1:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

# Fallback to cyan if blue doesn't exist
if [[ -z "$accent_blue" ]]; then
    accent_blue="$accent_cyan"
fi

echo "Syncing Starship colors for theme: $theme_name"

# Backup existing config
if [[ -f "$STARSHIP_CONFIG" ]]; then
    cp "$STARSHIP_CONFIG" "$STARSHIP_BACKUP"
fi

# Check if config exists
if [[ ! -f "$STARSHIP_CONFIG" ]]; then
    echo "Error: starship.toml not found at $STARSHIP_CONFIG"
    echo "Please create your custom starship configuration first."
    exit 1
fi

# Remove existing palette section if it exists
sed -i '/^\[palette\]/,/^$/d' "$STARSHIP_CONFIG"

# Append new palette section at the end
cat >> "$STARSHIP_CONFIG" << EOF

[palette]
# Auto-synced with Quickshell Theme: $theme_name
bg_base = "$bg_base"
surface0 = "$surface0"
surface1 = "$surface1"
fg_primary = "$fg_primary"
fg_secondary = "$fg_secondary"
accent_green = "$accent_green"
accent_blue = "$accent_blue"
accent_cyan = "$accent_cyan"
accent_yellow = "$accent_yellow"
EOF

echo "✓ Starship palette updated for $theme_name theme"
echo "  (Your custom format and glyphs are preserved)"
echo ""
echo "Now update your starship.toml format to use palette colors like:"
echo '  style = "fg:bg_base bg:accent_blue"'
echo "  Accent Blue: $accent_blue"
echo "  Accent Green: $accent_green"
echo "  Accent Yellow: $accent_yellow"
echo "  Accent Cyan: $accent_cyan"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
