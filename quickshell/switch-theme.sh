#!/bin/bash

# Quickshell Theme Switcher
# Switches Quickshell theme to match available theme presets

THEME="$1"
THEME_DIR="$HOME/.config/quickshell/themes"
TARGET="$HOME/.config/quickshell/ThemeManager.qml"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Quickshell Theme Switcher${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -z "$THEME" ]; then
    echo -e "${YELLOW}Available themes:${NC}"
    echo ""
    ls "$THEME_DIR"/*.qml 2>/dev/null | while read -r file; do
        basename "$file" .qml | sed 's/^/  • /'
    done
    echo ""
    echo "Usage: $0 <theme-name>"
    echo "Example: $0 catppuccin-mocha"
    exit 1
fi

THEME_FILE="$THEME_DIR/${THEME}.qml"

if [ ! -f "$THEME_FILE" ]; then
    echo -e "${YELLOW}⚠ Theme not found: $THEME${NC}"
    echo ""
    echo "Available themes:"
    ls "$THEME_DIR"/*.qml 2>/dev/null | while read -r file; do
        basename "$file" .qml | sed 's/^/  • /'
    done
    exit 1
fi

# Backup current theme
if [ -f "$TARGET" ]; then
    cp "$TARGET" "$TARGET.backup"
fi

# Copy new theme
cp "$THEME_FILE" "$TARGET"

# Inject persistent user preferences (widgetOpacity, barLarge) from settings.json
SETTINGS_FILE="$HOME/.config/quickshell/settings.json"
WIDGET_OPACITY="0.75"
BAR_LARGE="false"
UI_FONT="Sen"
HYPR_ROUNDING="12"
SHOW_WIDGET_BORDERS="true"
WIDGET_BORDER_WIDTH="1"
WORKSPACE_STYLE="numbers"
SHADOW_RANGE="20"
SHADOW_ALPHA="33"
SHADOW_USE_ACCENT="false"
if [[ -f "$SETTINGS_FILE" ]]; then
    wo=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('general',{}).get('widgetTransparent', True) and 0.75 or 1.0)" 2>/dev/null)
    [[ -n "$wo" ]] && WIDGET_OPACITY="$wo"
    bl=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print('true' if d.get('bar',{}).get('barSize','small')=='large' else 'false')" 2>/dev/null)
    [[ -n "$bl" ]] && BAR_LARGE="$bl"
    uf=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('general',{}).get('uiFont','Sen'))" 2>/dev/null)
    [[ -n "$uf" ]] && UI_FONT="$uf"
    hr=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('hypr',{}).get('rounding',12))" 2>/dev/null)
    [[ -n "$hr" ]] && HYPR_ROUNDING="$hr"
    swb=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print('true' if d.get('general',{}).get('showWidgetBorders',True) else 'false')" 2>/dev/null)
    [[ -n "$swb" ]] && SHOW_WIDGET_BORDERS="$swb"
    wbw=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('general',{}).get('widgetBorderWidth',1))" 2>/dev/null)
    [[ -n "$wbw" ]] && WIDGET_BORDER_WIDTH="$wbw"
    ws=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('bar',{}).get('workspaceStyle','numbers'))" 2>/dev/null)
    [[ -n "$ws" ]] && WORKSPACE_STYLE="$ws"
    sr=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('hypr',{}).get('shadowRange',20))" 2>/dev/null)
    [[ -n "$sr" ]] && SHADOW_RANGE="$sr"
    sa=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print(d.get('hypr',{}).get('shadowAlpha',33))" 2>/dev/null)
    [[ -n "$sa" ]] && SHADOW_ALPHA="$sa"
    sua=$(python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); print('true' if d.get('hypr',{}).get('shadowUseAccent',False) else 'false')" 2>/dev/null)
    [[ -n "$sua" ]] && SHADOW_USE_ACCENT="$sua"
fi
# Append properties if not already present, or update them
if grep -q "widgetOpacity" "$TARGET"; then
    sed -i "s/property real widgetOpacity:.*/property real widgetOpacity: $WIDGET_OPACITY/" "$TARGET"
else
    sed -i "/^}$/i\\    property real widgetOpacity: $WIDGET_OPACITY" "$TARGET"
fi
if grep -q "barLarge" "$TARGET"; then
    sed -i "s/property bool barLarge:.*/property bool barLarge: $BAR_LARGE/" "$TARGET"
else
    sed -i "/^}$/i\\    property bool barLarge: $BAR_LARGE" "$TARGET"
fi
if grep -q "uiFont" "$TARGET"; then
    sed -i "s/property string uiFont:.*/property string uiFont: \"$UI_FONT\"/" "$TARGET"
else
    sed -i "/^}$/i\\    property string uiFont: \"$UI_FONT\"" "$TARGET"
fi
if grep -q "hyprRounding" "$TARGET"; then
    sed -i "s/property int hyprRounding:.*/property int hyprRounding: $HYPR_ROUNDING/" "$TARGET"
else
    sed -i "/^}$/i\\    property int hyprRounding: $HYPR_ROUNDING" "$TARGET"
fi
if grep -q "showWidgetBorders" "$TARGET"; then
    sed -i "s/property bool showWidgetBorders:.*/property bool showWidgetBorders: $SHOW_WIDGET_BORDERS/" "$TARGET"
else
    sed -i "/^}$/i\\    property bool showWidgetBorders: $SHOW_WIDGET_BORDERS" "$TARGET"
fi
if grep -q "widgetBorderWidth" "$TARGET"; then
    sed -i "s/property int widgetBorderWidth:.*/property int widgetBorderWidth: $WIDGET_BORDER_WIDTH/" "$TARGET"
else
    sed -i "/^}$/i\\    property int widgetBorderWidth: $WIDGET_BORDER_WIDTH" "$TARGET"
fi
if grep -q "workspaceStyle" "$TARGET"; then
    sed -i "s/property string workspaceStyle:.*/property string workspaceStyle: \"$WORKSPACE_STYLE\"/" "$TARGET"
else
    sed -i "/^}$/i\\    property string workspaceStyle: \"$WORKSPACE_STYLE\"" "$TARGET"
fi
if grep -q "hyprShadowRange" "$TARGET"; then
    sed -i "s/property int hyprShadowRange:.*/property int hyprShadowRange: $SHADOW_RANGE/" "$TARGET"
else
    sed -i "/^}$/i\\    property int hyprShadowRange: $SHADOW_RANGE" "$TARGET"
fi
if grep -q "hyprShadowAlpha" "$TARGET"; then
    sed -i "s/property int hyprShadowAlpha:.*/property int hyprShadowAlpha: $SHADOW_ALPHA/" "$TARGET"
else
    sed -i "/^}$/i\\    property int hyprShadowAlpha: $SHADOW_ALPHA" "$TARGET"
fi
if grep -q "hyprShadowUseAccent" "$TARGET"; then
    sed -i "s/property bool hyprShadowUseAccent:.*/property bool hyprShadowUseAccent: $SHADOW_USE_ACCENT/" "$TARGET"
else
    sed -i "/^}$/i\\    property bool hyprShadowUseAccent: $SHADOW_USE_ACCENT" "$TARGET"
fi

echo -e "${GREEN}✓ Theme switched to: $THEME${NC}"
echo ""

# Update Hyprland theme source
# Map Quickshell theme names to Hyprland theme files
declare -A HYPR_THEME_MAP=(
    ["catppuccin-mocha"]="Catppuccin"
    ["gruvbox-dark"]="Gruvbox"
    ["tokyonight-night"]="TokyoNight"
    ["dracula"]="Dracula"
    ["everforest"]="Everforest"
    ["nord"]="Nord"
    ["rosepine"]="RosePine"
    ["kanagawa"]="Kanagawa"
    ["nightfox"]="NightFox"
    ["eldritch"]="Eldritch"
    ["material"]="Material"
    ["monochrome"]="Monochrome"
    ["solarized"]="Solarized"
)

HYPR_THEME="${HYPR_THEME_MAP[$THEME]}"
if [ -n "$HYPR_THEME" ]; then
    # Write theme name before reload so hyprland.lua picks it up immediately
    echo "$HYPR_THEME" > "$HOME/.config/hypr/.current-theme"
    echo -e "${GREEN}✓ Hyprland theme set to: $HYPR_THEME${NC}"
    # Reload Hyprland config (hyprland.lua reads .current-theme on every reload)
    hyprctl reload 2>/dev/null
    # Re-apply user appearance preferences that theme defaults would have reset
    sleep 0.3
    bash "$HOME/.config/quickshell/apply-hypr-settings.sh" 2>/dev/null &
fi

# Export theme file path for sync scripts to use
export QUICKSHELL_THEME_FILE="$THEME_FILE"

# Update theme reference immediately for wallpaper picker
# Write the Title Case theme name (from HYPR_THEME_MAP) for wallpaper folders
if [ -n "$HYPR_THEME" ]; then
    echo "$HYPR_THEME" > "$HOME/.config/hypr/.current-theme"
else
    echo "$THEME" > "$HOME/.config/hypr/.current-theme"
fi

# Update wallpaper to match new theme
# Use HYPR_THEME (Title Case) for wallpaper directory name
THEME_FOR_WALLPAPER="${HYPR_THEME:-$THEME}"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/$THEME_FOR_WALLPAPER"
if [ -d "$WALLPAPER_DIR" ] && command -v awww &> /dev/null; then
    # Get a random wallpaper from the theme directory
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        echo "Updating wallpaper..."
        awww img "$WALLPAPER" --transition-type fade --transition-fps 60 &
        # Persist wallpaper so autostart restores the correct one on next login
        printf "%s" "$WALLPAPER" > "$HOME/.config/quickshell/last-wallpaper"
        echo -e "${GREEN}✓ Wallpaper updated${NC}"
    fi
fi

# Sync SDDM theme first (synchronously for reliability)
# Wait 500ms for awww to finish applying the wallpaper before querying it
SDDM_SYNC="$HOME/.config/quickshell/sync-sddm-theme.sh"
if [ -f "$SDDM_SYNC" ]; then
    echo "Syncing SDDM theme..."
    sleep 0.5
    "$SDDM_SYNC"
    echo ""
fi

# Background all sync operations to speed up theme switching
(
    # Sync Vencord/Vesktop theme
    if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then
        echo "Syncing Vencord theme..."
        "$HOME/.config/quickshell/sync-vencord-theme.sh" --theme-file
        echo -e "${GREEN}✓ Vencord theme synced${NC}"
        
        # Auto-restart Vesktop if running
        if pgrep -x vesktop > /dev/null; then
            echo -e "${YELLOW}  → Restarting Vesktop to apply theme...${NC}"
            killall vesktop 2>/dev/null
            sleep 0.5
            vesktop &>/dev/null &
            disown
            echo -e "${GREEN}  ✓ Vesktop restarted${NC}"
        else
        echo -e "${YELLOW}  → Vesktop not running (launch it to see theme)${NC}"
    fi
    
    # Send desktop notification if notify-send is available
    if command -v notify-send &> /dev/null; then
        notify-send "Theme Switched: $THEME" "Vesktop theme applied" -i preferences-desktop-theme 2>/dev/null &
    fi
    echo ""
fi

# Update fastfetch logo
if [ -x "$HOME/.config/fastfetch/update-theme-logo.sh" ]; then
    echo "Updating fastfetch logo..."
    "$HOME/.config/fastfetch/update-theme-logo.sh" > /dev/null 2>&1
fi

# Sync Starship prompt colors
if [ -x "$HOME/.config/quickshell/sync-starship-theme.sh" ]; then
    echo "Syncing Starship prompt colors..."
    "$HOME/.config/quickshell/sync-starship-theme.sh" > /dev/null 2>&1
fi

# Sync Bento browser start page
if [ -x "$HOME/.config/quickshell/sync-bento-theme.sh" ]; then
    echo "Syncing Bento start page..."
    "$HOME/.config/quickshell/sync-bento-theme.sh" > /dev/null 2>&1
fi

# Sync Firefox theme
if [ -x "$HOME/.config/quickshell/sync-firefox-theme.sh" ]; then
    echo "Syncing Firefox theme..."
    "$HOME/.config/quickshell/sync-firefox-theme.sh"
fi

# Sync GTK theme
if [ -x "$HOME/.config/quickshell/sync-gtk-theme.sh" ]; then
    echo "Syncing GTK theme..."
    "$HOME/.config/quickshell/sync-gtk-theme.sh"
    
    # Source the GTK theme environment and update Hyprland
    if [ -f "$HOME/.config/gtk-3.0/gtk-theme-env.sh" ]; then
        source "$HOME/.config/gtk-3.0/gtk-theme-env.sh"
        if command -v hyprctl &> /dev/null; then
            hyprctl setenv GTK_THEME "$GTK_THEME"
        fi
    fi
fi

# Sync Papirus folder colors
if [ -x "$HOME/.config/quickshell/sync-papirus-folders.sh" ]; then
    echo "Syncing Papirus folder colors..."
    "$HOME/.config/quickshell/sync-papirus-folders.sh"
fi

# Sync Hyprlock theme
if [ -x "$HOME/.config/quickshell/sync-hyprlock-theme.sh" ]; then
    echo "Syncing Hyprlock theme..."
    "$HOME/.config/quickshell/sync-hyprlock-theme.sh"
fi

# Sync Kitty theme
if [ -x "$HOME/.config/quickshell/sync-kitty-theme.sh" ]; then
    echo "Syncing Kitty theme..."
    "$HOME/.config/quickshell/sync-kitty-theme.sh"
fi

# Sync Mako notification borders
if [ -x "$HOME/.config/quickshell/sync-mako-theme.sh" ]; then
    echo "Syncing Mako theme..."
    "$HOME/.config/quickshell/sync-mako-theme.sh"
fi

# Sync Wofi theme
if [ -x "$HOME/.config/quickshell/sync-wofi-theme.sh" ]; then
    echo "Syncing Wofi theme..."
    "$HOME/.config/quickshell/sync-wofi-theme.sh"
fi

# Sync Neovim theme
if [ -x "$HOME/.config/quickshell/sync-nvim-theme.sh" ]; then
    echo "Syncing Neovim theme..."
    "$HOME/.config/quickshell/sync-nvim-theme.sh"
fi

# Sync VSCodium theme
if [ -x "$HOME/.config/quickshell/sync-vscodium-theme.sh" ]; then
    echo "Syncing VSCodium theme..."
    "$HOME/.config/quickshell/sync-vscodium-theme.sh"
fi

# Sync VS Code theme
if [ -x "$HOME/.config/quickshell/sync-vscode-theme.sh" ]; then
    echo "Syncing VS Code theme..."
    "$HOME/.config/quickshell/sync-vscode-theme.sh"
fi

echo ""
) &

# Main theme switch continues immediately
echo -e "${GREEN}✓ Theme switching in progress (background)${NC}"

# Check if quickshell is running
if pgrep -x quickshell > /dev/null; then
    echo -e "${GREEN}✓ Quickshell is running - theme will apply automatically${NC}"
else
    echo -e "${YELLOW}⚠ Quickshell is not running${NC}"
    echo "Start it with: quickshell &"
fi
    
    # Send desktop notification if notify-send is available
echo ""

# Check if quickshell is running
if pgrep -x quickshell > /dev/null; then
    echo -e "${GREEN}✓ Quickshell is running - theme will apply automatically${NC}"
else
    echo -e "${YELLOW}⚠ Quickshell is not running${NC}"
    echo "Start it with: quickshell &"
fi
