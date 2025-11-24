#!/bin/bash

# Sync Kitty theme with current Hyprland theme

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
KITTY_THEME="$HOME/.config/kitty/current-theme.conf"

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

accent_blue=$(get_color '\$accent-blue')
accent_red=$(get_color '\$accent-red')
accent_green=$(get_color '\$accent-green')
accent_yellow=$(get_color '\$accent-yellow')
accent_purple=$(get_color '\$accent-purple')
accent_cyan=$(get_color '\$accent-cyan')
fg_primary=$(get_color '\$fg-primary')
fg_secondary=$(get_color '\$fg-secondary')
bg_base=$(get_color '\$bg-base')
surface_0=$(get_color '\$surface-0')

echo "Syncing Kitty theme for: $theme_name"

# Create kitty theme
cat > "$KITTY_THEME" << EOF
# $theme_name theme for kitty
foreground #$fg_primary
background #$bg_base
selection_foreground #$bg_base
selection_background #$accent_blue
cursor #$fg_primary
cursor_text_color #$bg_base

# Black
color0 #$bg_base
color8 #$surface_0

# Red  
color1 #$accent_red
color9 #$accent_red

# Green
color2 #$accent_green
color10 #$accent_green

# Yellow
color3 #$accent_yellow
color11 #$accent_yellow

# Blue
color4 #$accent_blue
color12 #$accent_blue

# Magenta
color5 #$accent_purple
color13 #$accent_purple

# Cyan
color6 #$accent_cyan
color14 #$accent_cyan

# White
color7 #$fg_secondary
color15 #$fg_primary
EOF

echo "✓ Kitty theme updated for $theme_name"

# Reload kitty if running
if pgrep -x kitty > /dev/null; then
    killall -SIGUSR1 kitty 2>/dev/null
    echo "  → Kitty windows reloaded"
fi
