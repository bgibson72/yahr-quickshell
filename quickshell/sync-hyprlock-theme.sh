#!/bin/bash

# Sync Hyprlock Colors with Current Quickshell Theme

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found"
    exit 1
fi

# Extract theme colors
theme_name=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_green=$(grep 'property color accentGreen:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_red=$(grep 'property color accentRed:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_secondary=$(grep 'property color fgSecondary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_tertiary=$(grep 'property color fgTertiary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Syncing Hyprlock colors for theme: $theme_name"

# Convert #RRGGBB to rgba format for hyprlock
hex_to_rgba() {
    local hex=$1
    local alpha=${2:-FF}  # Default to opaque
    hex=${hex#\#}  # Remove # if present
    echo "rgba(${hex}${alpha})"
}

# Convert colors
inner_color=$(hex_to_rgba "$bg_base" "E6")      # Background with 90% opacity
outer_color=$(hex_to_rgba "$accent_blue" "FF")  # Border color
check_color=$(hex_to_rgba "$accent_green" "FF") # Success color
fail_color=$(hex_to_rgba "$accent_red" "FF")    # Error color
font_color=$(hex_to_rgba "$fg_primary" "FF")    # Primary text
date_color=$(hex_to_rgba "$fg_secondary" "E6")  # Secondary text
user_color=$(hex_to_rgba "$fg_tertiary" "CC")   # Tertiary text

# Backup
cp "$HYPRLOCK_CONF" "$HYPRLOCK_CONF.backup"

# Update colors using sed
sed -i "s/inner_color = rgba([0-9a-fA-F]\+)/inner_color = $inner_color/" "$HYPRLOCK_CONF"
sed -i "s/outer_color = rgba([0-9a-fA-F]\+)/outer_color = $outer_color/" "$HYPRLOCK_CONF"
sed -i "s/check_color = rgba([0-9a-fA-F]\+)/check_color = $check_color/" "$HYPRLOCK_CONF"
sed -i "s/fail_color = rgba([0-9a-fA-F]\+)/fail_color = $fail_color/" "$HYPRLOCK_CONF"

# Update text colors (more specific patterns to avoid conflicts)
sed -i "/# Time Display/,/position = 0, 250/ s/color = rgba([0-9a-fA-F]\+)/color = $font_color/" "$HYPRLOCK_CONF"
sed -i "/# Date Display/,/position = 0, 120/ s/color = rgba([0-9a-fA-F]\+)/color = $date_color/" "$HYPRLOCK_CONF"
sed -i "/# User label/,/position = 0, -200/ s/color = rgba([0-9a-fA-F]\+)/color = $user_color/" "$HYPRLOCK_CONF"
sed -i "/font_color = rgba/s/font_color = rgba([0-9a-fA-F]\+)/font_color = $font_color/" "$HYPRLOCK_CONF"

# Update placeholder and fail text colors in spans
fg_secondary_nohash="${fg_secondary#\#}"
accent_red_nohash="${accent_red#\#}"
sed -i "s/##[0-9a-fA-F]\{6\}/$accent_red_nohash/g" "$HYPRLOCK_CONF"
sed -i "s/foreground=\"##/foreground=\"#/g" "$HYPRLOCK_CONF"

echo "✓ Hyprlock colors updated for $theme_name theme"
echo "  Inner: $inner_color"
echo "  Outer: $outer_color"
echo "  Check: $check_color"
echo "  Fail: $fail_color"
