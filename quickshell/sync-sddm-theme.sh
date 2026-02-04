#!/bin/bash
# Sync SDDM theme with current YAHR theme and wallpaper

SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
QS_DIR="$HOME/.config/quickshell"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"

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

# Get current wallpaper from swww
current_wallpaper=""
if command -v swww &> /dev/null; then
    # swww query returns format like: "eDP-1: ... image: /path/to/wallpaper"
    wallpaper_line=$(swww query | head -n1)
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
DateFormat="dddd, MMMM d"

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
