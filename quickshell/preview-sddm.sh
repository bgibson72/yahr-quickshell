#!/bin/bash
# Preview SDDM theme in test mode without logging out.
# Temporarily applies a theme's colors to SDDM, launches the greeter, screenshots,
# then restores the original theme.conf.
#
# Usage: preview-sddm.sh [ThemeName]   (default: Catppuccin)
# Keybind: Super+Shift+L  (configured in hypr/keybinds.conf)
# Screenshot saved to: ~/Pictures/Screenshots/sddm-preview-<timestamp>.png

PREVIEW_THEME="${1:-Catppuccin}"
SDDM_THEME_DIR="/usr/share/sddm/themes/yahr-theme"
THEME_CONF="$SDDM_THEME_DIR/theme.conf"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"
THEME_FILE="$HYPR_THEMES_DIR/$PREVIEW_THEME.conf"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
SETTINGS_JSON="$HOME/.config/quickshell/settings.json"
mkdir -p "$SCREENSHOT_DIR"

# Verify setup
if [[ ! -d "$SDDM_THEME_DIR" ]]; then
    notify-send "SDDM Preview" "Theme not found: $SDDM_THEME_DIR" --urgency=critical
    exit 1
fi
if ! command -v sddm-greeter-qt6 &>/dev/null; then
    notify-send "SDDM Preview" "sddm-greeter-qt6 not found – is SDDM installed?" --urgency=critical
    exit 1
fi
if [[ ! -f "$THEME_FILE" ]]; then
    notify-send "SDDM Preview" "Theme file not found: $THEME_FILE" --urgency=critical
    exit 1
fi

# Extract colors from the chosen theme file
get_color() {
    grep "^\$$1 " "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1
}
accent_blue="#$(get_color 'accent-blue')"
accent_purple="#$(get_color 'accent-purple')"
fg_primary="#$(get_color 'fg-primary')"
fg_secondary="#$(get_color 'fg-secondary')"
bg_base="#$(get_color 'bg-base')"
surface0="#$(get_color 'surface-0')"

# Read date format from settings.json
DATE_FORMAT_DMY=false; DATE_LONG=false; SHOW_DAY_OF_WEEK=false
if [[ -f "$SETTINGS_JSON" ]] && command -v python3 &>/dev/null; then
    DATE_FORMAT_DMY=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateFormat','MDY')=='DMY').lower())" 2>/dev/null || echo false)
    DATE_LONG=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('dateLong',False)).lower())" 2>/dev/null || echo false)
    SHOW_DAY_OF_WEEK=$(python3 -c "import json; d=json.load(open('$SETTINGS_JSON')); print(str(d.get('general',{}).get('showDayOfWeek',False)).lower())" 2>/dev/null || echo false)
fi
if [[ "$DATE_LONG" == "true" ]]; then
    SDDM_DATE_FORMAT="$( [[ "$DATE_FORMAT_DMY" == "true" ]] && echo "d MMMM yyyy" || echo "MMMM d, yyyy" )"
    [[ "$SHOW_DAY_OF_WEEK" == "true" ]] && SDDM_DATE_FORMAT="dddd, $SDDM_DATE_FORMAT"
else
    SDDM_DATE_FORMAT="$( [[ "$DATE_FORMAT_DMY" == "true" ]] && echo "dd/MM/yyyy" || echo "MM/dd/yyyy" )"
fi

# Find a wallpaper for the preview theme
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/$PREVIEW_THEME"
PREVIEW_WALLPAPER=""
if [[ -d "$WALLPAPER_DIR" ]]; then
    PREVIEW_WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort | head -1)
fi
# Fall back to current awww wallpaper
if [[ -z "$PREVIEW_WALLPAPER" ]] && command -v awww &>/dev/null; then
    wallpaper_line=$(awww query 2>/dev/null | head -n1)
    [[ $wallpaper_line =~ image:\ (.+)$ ]] && PREVIEW_WALLPAPER="${BASH_REMATCH[1]// /}"
fi

# Copy wallpaper into SDDM theme dir if found
if [[ -n "$PREVIEW_WALLPAPER" && -f "$PREVIEW_WALLPAPER" ]]; then
    SDDM_BG="background-preview-$(basename "$PREVIEW_WALLPAPER")"
    sudo cp "$PREVIEW_WALLPAPER" "$SDDM_THEME_DIR/$SDDM_BG" 2>/dev/null
else
    SDDM_BG="background.jpg"
fi

# Save original theme.conf so we can restore it afterward
SAVED_CONF=$(sudo cat "$THEME_CONF" 2>/dev/null)

# Apply preview theme colors
sudo tee "$THEME_CONF" > /dev/null << EOF
[General]
Background="$SDDM_BG"
BackgroundBlur=20

# Colors from $PREVIEW_THEME
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
EOF

notify-send "SDDM Preview" "Launching $PREVIEW_THEME login screen preview…"

# Launch greeter in test mode
sddm-greeter-qt6 --test-mode --theme "$SDDM_THEME_DIR" &
GREETER_PID=$!

# Wait for the window to fully render before screenshotting
sleep 3

# Take a full-screen screenshot with grim
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCREENSHOT_FILE="$SCREENSHOT_DIR/sddm-preview-$PREVIEW_THEME-$TIMESTAMP.png"

if grim "$SCREENSHOT_FILE" 2>/dev/null; then
    wl-copy < "$SCREENSHOT_FILE" 2>/dev/null || true
    notify-send "SDDM Preview" "Screenshot saved to:\n$SCREENSHOT_FILE" --icon=camera-photo
else
    notify-send "SDDM Preview" "Screenshot failed – grim returned an error" --urgency=normal
fi

# Wait for greeter to close, then restore original theme.conf
wait "$GREETER_PID" 2>/dev/null
if [[ -n "$SAVED_CONF" ]]; then
    echo "$SAVED_CONF" | sudo tee "$THEME_CONF" > /dev/null
fi
