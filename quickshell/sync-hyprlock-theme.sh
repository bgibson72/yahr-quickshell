#!/bin/bash

# Sync Hyprlock Colors with Current Quickshell Theme

HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
SETTINGS_JSON="$HOME/.config/quickshell/settings.json"

# Get current theme from Hyprland config (most reliable source during theme switches)
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
accent_green=$(get_color '\$accent-green')
accent_red=$(get_color '\$accent-red')
fg_primary=$(get_color '\$fg-primary')
fg_secondary=$(get_color '\$fg-secondary')
fg_tertiary=$(get_color '\$fg-tertiary')
bg_base=$(get_color '\$bg-base')

echo "Syncing Hyprlock colors for theme: $theme_name"

# Convert RGB hex to rgba format for hyprlock
hex_to_rgba() {
    local hex=$1
    local alpha=${2:-FF}  # Default to opaque
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

# Update placeholder text (simple text without markup)
sed -i "s/placeholder_text = .*/placeholder_text = Enter Password.../" "$HYPRLOCK_CONF"

# Update fail text color in span
sed -i "s/fail_text = <span foreground=\"#[0-9a-fA-F]\{6\}\"><b>\$FAIL/fail_text = <span foreground=\"#$accent_red\"><b>\$FAIL/g" "$HYPRLOCK_CONF"

# Update date format in the Date Display label
# Read date format settings from quickshell settings.json
DATE_FORMAT_DMY=false
DATE_LONG=false
SHOW_DAY_OF_WEEK=false
if [ -f "$SETTINGS_JSON" ] && command -v python3 &>/dev/null; then
    DATE_FORMAT_DMY=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateFormat','MDY')=='DMY').lower())" 2>/dev/null || echo false)
    DATE_LONG=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateLong',False)).lower())" 2>/dev/null || echo false)
    SHOW_DAY_OF_WEEK=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('showDayOfWeek',False)).lower())" 2>/dev/null || echo false)
fi

# Build date shell format string for hyprlock's date +... command
if [ "$DATE_LONG" = "true" ]; then
    if [ "$DATE_FORMAT_DMY" = "true" ]; then
        DATE_CMD_FMT="%-d %B %Y"       # e.g. 25 March 2026
    else
        DATE_CMD_FMT="%B %-d, %Y"      # e.g. March 25, 2026
    fi
    if [ "$SHOW_DAY_OF_WEEK" = "true" ]; then
        DATE_CMD_FMT="%A, $DATE_CMD_FMT"  # e.g. Wednesday, March 25, 2026
    fi
else
    if [ "$DATE_FORMAT_DMY" = "true" ]; then
        DATE_CMD_FMT="%d/%m/%Y"        # e.g. 25/03/2026
    else
        DATE_CMD_FMT="%m/%d/%Y"        # e.g. 03/25/2026
    fi
fi

# Replace the date format inside the Date Display label's text line
sed -i "/# Date Display/,/position = 0, 120/ s|text = cmd\[update:[0-9]*\] date +\"[^\"]*\"|text = cmd[update:60000] date +\"$DATE_CMD_FMT\"|" "$HYPRLOCK_CONF"

echo "✓ Hyprlock colors updated for $theme_name theme"
echo "  Inner: $inner_color"
echo "  Outer: $outer_color"
echo "  Check: $check_color"
echo "  Fail: $fail_color"
echo "  Date format: $DATE_CMD_FMT"
