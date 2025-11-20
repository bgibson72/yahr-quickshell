#!/bin/bash
# Sync SDDM theme with current YAHR theme and wallpaper

SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
QS_DIR="$HOME/.config/quickshell"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"
THEME_MANAGER="$QS_DIR/ThemeManager.qml"

# Check if ThemeManager.qml exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found: $THEME_MANAGER"
    exit 1
fi

# Extract theme name and colors directly from ThemeManager.qml
current_theme=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

# Parse colors from ThemeManager.qml (using the first accent as themeColor)
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
accent_purple=$(grep 'property color accentPurple:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
fg_secondary=$(grep 'property color fgSecondary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
surface0=$(grep 'property color surface0:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)

# Use accentTeal or accentCyan as themeColor if accentBlue doesn't exist
if [[ -z "$accent_blue" ]]; then
    accent_blue=$(grep 'property color accent' "$THEME_MANAGER" | grep -E 'Teal|Cyan|Blue' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
fi

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

echo "Syncing SDDM theme..."
echo "  Theme: $current_theme"
echo "  Wallpaper: $current_wallpaper"
echo "  Colors: $accent_blue, $accent_purple, etc."

# Update theme.conf with extracted colors and wallpaper
sudo tee "$THEME_CONF" > /dev/null << EOF
[General]
Background="$current_wallpaper"
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
TimeFormat="hh:mm"
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
