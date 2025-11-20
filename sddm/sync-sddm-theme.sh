#!/bin/bash
# Sync SDDM theme with current YAHR theme and wallpaper

SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
QS_DIR="$HOME/.config/quickshell"
SETTINGS_FILE="$QS_DIR/settings.json"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"

# Get current theme from settings.json
current_theme=$(jq -r '.theme.current' "$SETTINGS_FILE" 2>/dev/null || echo "Gruvbox")

# Map theme names to file names (try to find matching file)
theme_file=""
for file in "$QS_DIR/themes"/*.qml; do
    if [[ -f "$file" ]]; then
        basename=$(basename "$file" .qml)
        # Convert filename to potential theme name (e.g., gruvbox-dark -> Gruvbox)
        if [[ "$basename" =~ gruvbox && "$current_theme" == "Gruvbox" ]]; then
            theme_file="$basename.qml"
            break
        elif [[ "$basename" =~ catppuccin && "$current_theme" =~ "Catppuccin" ]]; then
            theme_file="$basename.qml"
            break
        elif [[ "$basename" =~ tokyonight && "$current_theme" =~ "Tokyo" ]]; then
            theme_file="$basename.qml"
            break
        fi
    fi
done

# Fallback to gruvbox if no match found
if [[ -z "$theme_file" ]]; then
    theme_file="gruvbox-dark.qml"
    echo "Warning: No matching theme file found for '$current_theme', using Gruvbox"
fi

# Extract colors from QML theme file
theme_path="$QS_DIR/themes/$theme_file"

if [[ ! -f "$theme_path" ]]; then
    echo "Error: Theme file not found: $theme_path"
    exit 1
fi

# Parse colors from QML (using grep and sed)
accent_blue=$(grep 'property color accentBlue:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')
accent_purple=$(grep 'property color accentPurple:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')
fg_secondary=$(grep 'property color fgSecondary:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')
surface0=$(grep 'property color surface0:' "$theme_path" | sed -E 's/.*"([^"]+)".*/\1/')

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
