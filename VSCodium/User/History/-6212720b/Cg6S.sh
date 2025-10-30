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

# Sync Zed theme if script exists
if [ -f "$HOME/.config/quickshell/sync-zed-theme.sh" ]; then
    echo "Syncing Zed theme..."
    "$HOME/.config/quickshell/sync-zed-theme.sh" "$THEME"
    echo ""
fi

# Sync Vencord/Vesktop theme
if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then
    echo "Syncing Vencord theme..."
    # Wait a moment for Quickshell to update settings.json
    sleep 1
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

echo ""

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
