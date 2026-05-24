#!/bin/bash
# Sync SDDM theme with current YAHR theme and wallpaper

SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
QS_DIR="$HOME/.config/quickshell"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"

# Prefer .current-theme as the source of truth (set by the quickshell theme switcher),
# fall back to parsing hyprland.conf's source line.
if [ -f "$CURRENT_THEME_FILE" ]; then
    current_theme=$(cat "$CURRENT_THEME_FILE" | tr -d '[:space:]')
    THEME_FILE="$HYPR_THEMES_DIR/${current_theme}.conf"
fi

if [ -z "$current_theme" ] || [ ! -f "$THEME_FILE" ]; then
    THEME_FILE=$(grep "^source.*themes.*\.conf" "$HYPRLAND_CONF" | sed 's/.*= *//')
    current_theme=$(basename "$THEME_FILE" .conf)
fi

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    echo "Error: Could not determine theme file"
    exit 1
fi

# Extract colors from Hyprland theme file
get_color() {
    local color_var="$1"
    grep "^$color_var" "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1
}

accent_blue=$(get_color '\$accent-blue')
accent_purple=$(get_color '\$accent-purple')
accent_red=$(get_color '\$accent-red')
fg_primary=$(get_color '\$fg-primary')
fg_secondary=$(get_color '\$fg-secondary')
bg_base=$(get_color '\$bg-base')
surface0=$(get_color '\$surface-0')

# Convert RGB hex to #RRGGBB format
accent_blue="#$accent_blue"
accent_purple="#$accent_purple"
accent_red="#$accent_red"
fg_primary="#$fg_primary"
fg_secondary="#$fg_secondary"
bg_base="#$bg_base"
surface0="#$surface0"

# Read widgetOpacity and uiFont from live ThemeManager.qml
widget_opacity=$(grep 'property real widgetOpacity' "$HOME/.config/quickshell/ThemeManager.qml" 2>/dev/null | head -1 | grep -oP '[0-9]+\.?[0-9]*$')
widget_opacity="${widget_opacity:-0.75}"
ui_font=$(grep 'property string uiFont' "$HOME/.config/quickshell/ThemeManager.qml" 2>/dev/null | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
ui_font="${ui_font:-Sen}"

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
echo "  Colors: $accent_blue, $accent_purple, $accent_red, etc."

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
FailColor="$accent_red"

# Widget opacity (synced from quickshell)
WidgetOpacity=$widget_opacity

# Typography
Font="$ui_font"
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

# Also copy Main.qml so QML logic (e.g. widgetOpacity) stays up to date
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/yahr-theme/Main.qml" ]]; then
    sudo cp "$SCRIPT_DIR/yahr-theme/Main.qml" "$SDDM_THEME_DIR/Main.qml" 2>/dev/null && \
        echo "✓ Main.qml updated" || \
        echo "⚠ Could not copy Main.qml (check sudo access)"
fi

echo ""
echo "Test with: sddm-greeter-qt6 --test-mode --theme $SDDM_THEME_DIR"
