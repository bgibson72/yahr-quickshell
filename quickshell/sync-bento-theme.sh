#!/bin/bash

# Sync Bento Browser Start Page with Current Hyprland Theme

SETTINGS_JSON="$HOME/.config/quickshell/settings.json"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
BENTO_CSS="$HOME/bento/app.css"

# Check if Bento integration is enabled in settings
if [ -f "$SETTINGS_JSON" ]; then
    bento_enabled=$(grep -A 20 '"bento"' "$SETTINGS_JSON" | grep '"enabled"' | grep -o 'true\|false' | head -1)
    if [ "$bento_enabled" = "false" ]; then
        echo "Bento integration is disabled in settings - skipping sync"
        exit 0
    fi
fi

# Check if Bento directory exists
if [ ! -f "$BENTO_CSS" ]; then
    echo "Bento not installed at $HOME/bento - skipping sync"
    exit 0
fi

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
fg_secondary=$(get_color '\$fg-secondary')
bg_base=$(get_color '\$bg-base')
surface0=$(get_color '\$surface-0')
surface1=$(get_color '\$surface-1')
accent_blue=$(get_color '\$accent-blue')

# Fallback if surface1 doesn't exist
[ -z "$surface1" ] && surface1="$surface0"

echo "Syncing Bento start page for theme: $theme_name"

# Update :root light theme colors (inverted - light backgrounds, dark text)
sed -i "/^:root {/,/^}/ s/--accent: #[0-9a-fA-F]\{6\};/--accent: #$accent_blue;/" "$BENTO_CSS"
sed -i "/^:root {/,/^}/ s/--background: #[0-9a-fA-F]\{6\};/--background: #$fg_primary;/" "$BENTO_CSS"
sed -i "/^:root {/,/^}/ s/--cards: #[0-9a-fA-F]\{6\};/--cards: #$fg_secondary;/" "$BENTO_CSS"
sed -i "/^:root {/,/^\.darktheme/ s/--fg: #[0-9a-fA-F]\{6\};/--fg: #$bg_base;/" "$BENTO_CSS"
sed -i "/^:root {/,/^\.darktheme/ s/--sfg: #[0-9a-fA-F]\{6\};/--sfg: #$surface0;/" "$BENTO_CSS"

# Update .darktheme colors (dark backgrounds, light text)
# Use surface-1 for cards (lighter than background)
sed -i "/^\.darktheme {/,/^}/ s/--accent: #[0-9a-fA-F]\{6\};/--accent: #$accent_blue;/" "$BENTO_CSS"
sed -i "/^\.darktheme {/,/^}/ s/--background: #[0-9a-fA-F]\{6\};/--background: #$bg_base;/" "$BENTO_CSS"
sed -i "/^\.darktheme {/,/^}/ s/--cards: #[0-9a-fA-F]\{6\};/--cards: #$surface1;/" "$BENTO_CSS"
sed -i "/^\.darktheme {/,/^}/ s/--fg: #[0-9a-fA-F]\{6\};/--fg: #$fg_primary;/" "$BENTO_CSS"
sed -i "/^\.darktheme {/,/^}/ s/--sfg: #[0-9a-fA-F]\{6\};/--sfg: #$fg_secondary;/" "$BENTO_CSS"

echo "✓ Bento start page colors updated (light mode inverted)"
echo "  Theme: $theme_name"
echo "  Accent: #$accent_blue"
echo "  Background: #$bg_base"
echo ""
echo "Refresh your browser to see the changes!"
