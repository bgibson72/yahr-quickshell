#!/bin/bash

# Sync Mako notification borders with current Hyprland theme

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
MAKO_CONF="$HOME/.config/mako/config"

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

get_rgba() {
    local color_var="$1"
    grep "^$color_var" "$THEME_FILE" | sed -E 's/.*= *rgba\(([^)]+)\).*/\1/' | head -1
}

bg_base=$(get_color '\$bg-base')
fg_primary=$(get_color '\$fg-primary')
accent_purple=$(get_color '\$accent-purple')
accent_green=$(get_color '\$accent-green')
accent_red=$(get_color '\$accent-red')
glass_accent=$(get_rgba '\$glass-accent-rgba')

# Fallback: if glass-accent-rgba not found, derive from accent-purple with 35% alpha
if [ -z "$glass_accent" ]; then
    glass_accent="${accent_purple}59"
fi

# Read border_size from look-and-feel.conf (same source as Settings > Hyprland)
HYPR_LAF="$HOME/.config/hypr/look-and-feel.conf"
border_size=$(grep 'border_size = ' "$HYPR_LAF" 2>/dev/null | grep -oE '[0-9]+' | head -1)
border_size="${border_size:-1}"

echo "Syncing Mako theme for: $theme_name (border-size: ${border_size}px)"

# Update mako config by replacing color lines in-place
sed -i \
    -e "s/^background-color=.*/background-color=#${bg_base}E8/" \
    -e "s/^text-color=.*/text-color=#${fg_primary}/" \
    -e "s/^border-color=.*/border-color=#${glass_accent}/" \
    -e "s/^progress-color=.*/progress-color=over #${glass_accent}/" \
    -e "s/^border-size=.*/border-size=${border_size}/" \
    "$MAKO_CONF"

# Update urgency-specific border colors
python3 - "$MAKO_CONF" "$accent_green" "$accent_purple" "$accent_red" << 'PYEOF'
import sys, re

conf_path = sys.argv[1]
green     = sys.argv[2]
purple    = sys.argv[3]
red       = sys.argv[4]

with open(conf_path) as f:
    content = f.read()

# Replace border-color inside each urgency block
def replace_urgency_border(text, urgency, color):
    pattern = r'(\[urgency=' + urgency + r'\][^\[]*?border-color=)#[0-9a-fA-F]+'
    return re.sub(pattern, lambda m: m.group(1) + '#' + color + '59', text, flags=re.DOTALL)

content = replace_urgency_border(content, 'low',      green)
content = replace_urgency_border(content, 'normal',   purple)
content = replace_urgency_border(content, 'critical', red)

with open(conf_path, 'w') as f:
    f.write(content)
PYEOF

# Reload mako
if command -v makoctl &> /dev/null; then
    makoctl reload 2>/dev/null && echo "✓ Mako reloaded"
fi

echo "✓ Mako theme updated for $theme_name"
