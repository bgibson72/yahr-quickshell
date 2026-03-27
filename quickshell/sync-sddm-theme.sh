#!/bin/bash
# Sync SDDM theme with current YAHR theme and wallpaper

SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
QS_DIR="$HOME/.config/quickshell"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"
SETTINGS_JSON="$QS_DIR/settings.json"

# Read date format from quickshell settings.json
DATE_FORMAT_DMY=false
DATE_LONG=false
SHOW_DAY_OF_WEEK=false
if [ -f "$SETTINGS_JSON" ] && command -v python3 &>/dev/null; then
    DATE_FORMAT_DMY=$(python3 -c "import json,sys; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateFormat','MDY')=='DMY').lower())" 2>/dev/null || echo false)
    DATE_LONG=$(python3 -c "import json,sys; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateLong',False)).lower())" 2>/dev/null || echo false)
    SHOW_DAY_OF_WEEK=$(python3 -c "import json,sys; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('showDayOfWeek',False)).lower())" 2>/dev/null || echo false)
fi

# Build Qt date format string for SDDM
# Qt format: d=day, M=month, yyyy=year, dddd=full weekday, MMMM=full month
if [ "$DATE_LONG" = "true" ]; then
    if [ "$DATE_FORMAT_DMY" = "true" ]; then
        # e.g. 25 March 2026
        SDDM_DATE_FORMAT="d MMMM yyyy"
    else
        # e.g. March 25, 2026
        SDDM_DATE_FORMAT="MMMM d, yyyy"
    fi
    if [ "$SHOW_DAY_OF_WEEK" = "true" ]; then
        SDDM_DATE_FORMAT="dddd, $SDDM_DATE_FORMAT"
    fi
else
    if [ "$DATE_FORMAT_DMY" = "true" ]; then
        SDDM_DATE_FORMAT="dd/MM/yyyy"
    else
        SDDM_DATE_FORMAT="MM/dd/yyyy"
    fi
fi

# Get current theme from Hyprland config (most reliable source during theme switches)
THEME_FILE=$(grep "^source.*themes.*\.conf" "$HYPRLAND_CONF" | sed 's/.*= *//')

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    echo "Error: Could not determine theme file from Hyprland config"
    exit 1
fi

current_theme=$(basename "$THEME_FILE" .conf)

# Extract colors from Hyprland theme file
get_color() {
    local color_var="$1"
    grep "^$color_var" "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1
}

accent_blue=$(get_color '\$accent-blue')
accent_purple=$(get_color '\$accent-purple')
fg_primary=$(get_color '\$fg-primary')
fg_secondary=$(get_color '\$fg-secondary')
bg_base=$(get_color '\$bg-base')
surface0=$(get_color '\$surface-0')

# Convert RGB hex to #RRGGBB format
accent_blue="#$accent_blue"
accent_purple="#$accent_purple"
fg_primary="#$fg_primary"
fg_secondary="#$fg_secondary"
bg_base="#$bg_base"
surface0="#$surface0"

# Get current wallpaper from awww
current_wallpaper=""
if command -v awww &> /dev/null; then
    # awww query returns format like: "eDP-1: ... image: /path/to/wallpaper"
    wallpaper_line=$(awww query | head -n1)
    if [[ $wallpaper_line =~ image:\ (.+)$ ]]; then
        current_wallpaper="${BASH_REMATCH[1]}"
        # Trim any trailing whitespace
        current_wallpaper=$(echo "$current_wallpaper" | xargs)
    fi
fi

# Fallback to a default wallpaper if swww doesn't have one set
if [[ -z "$current_wallpaper" || ! -f "$current_wallpaper" ]]; then
    current_wallpaper="$HOME/.config/quickshell/themes/wallpapers/default.jpg"
fi

# Copy wallpaper to SDDM theme directory (so SDDM can access it)
if [[ -f "$current_wallpaper" ]]; then
    wallpaper_filename="background-$(basename "$current_wallpaper")"
    sudo cp "$current_wallpaper" "$SDDM_THEME_DIR/$wallpaper_filename" 2>/dev/null
    # Use the copied wallpaper path
    sddm_wallpaper="$wallpaper_filename"
else
    sddm_wallpaper="background.jpg"
fi

echo "Syncing SDDM theme..."
echo "  Theme: $current_theme"
echo "  Wallpaper: $current_wallpaper"
echo "  Colors: $accent_blue, $accent_purple, etc."

# Update theme.conf with extracted colors and wallpaper
sudo tee "$THEME_CONF" > /dev/null << EOF
[General]
Background="$sddm_wallpaper"
BackgroundBlur=20

# Colors from $current_theme
ThemeColor="$accent_blue"
AccentColor="$accent_purple"
BgBase="$bg_base"
BgSurface="$surface0"
FgPrimary="$fg_primary"
FgSecondary="$fg_secondary"

# Typography
Font="MapleMono NF"
FontSize=12
TitleFontSize=36

# Features
EnableAvatars=true
ShowHostname=true
ShowSessionButton=true
ShowPowerButtons=true

# Time and Date
TimeFormat="h:mm AP"
DateFormat="$SDDM_DATE_FORMAT"

# Translations (using defaults)
TranslateLogin=
TranslateLoginFailed=
TranslateUsername=
TranslatePassword=
TranslateSession=
TranslateSuspend=
TranslateReboot=
TranslateShutdown=
EOF

echo "✓ SDDM theme synced successfully!"
echo ""
echo "Test with: sddm-greeter-qt6 --test-mode --theme $SDDM_THEME_DIR"
