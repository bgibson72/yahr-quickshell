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
    HYPR_THEME_FILE="$HOME/.config/hypr/themes/${HYPR_THEME}.conf"
    if [ -f "$HYPR_THEME_FILE" ]; then
        sed -i "s|^source = .*/themes/.*\.conf|source = $HYPR_THEME_FILE|" "$HOME/.config/hypr/hyprland.conf"
        echo -e "${GREEN}✓ Hyprland theme updated to: $HYPR_THEME${NC}"
        # Reload Hyprland config
        hyprctl reload 2>/dev/null
    fi
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
        echo -e "${GREEN}✓ Wallpaper updated${NC}"
    fi
fi

# Sync SDDM theme first (synchronously for reliability)
SDDM_SYNC="$HOME/.config/quickshell/sync-sddm-theme.sh"
if [ -f "$SDDM_SYNC" ]; then
    echo "Syncing SDDM theme..."
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
if [ -x "$HOME/.config/quickshell/update-theme-logo.sh" ]; then
    echo "Updating fastfetch logo..."
    "$HOME/.config/quickshell/update-theme-logo.sh" > /dev/null 2>&1
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
