#!/bin/bash

# VSCodium Theme Sync Script
# Reads colors from Hyprland theme and applies them to VSCodium

# Get the current theme from hyprland.conf
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
VSCODIUM_SETTINGS="$HOME/.config/VSCodium/User/settings.json"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  VSCodium Theme Sync${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Find the sourced theme file
THEME_FILE=$(grep "^source = " "$HYPR_CONF" | head -1 | awk '{print $3}')

if [ -z "$THEME_FILE" ]; then
    echo -e "${YELLOW}⚠ Could not find theme file in hyprland.conf${NC}"
    exit 1
fi

# Expand the path
THEME_FILE="${THEME_FILE/#\~/$HOME}"

if [ ! -f "$THEME_FILE" ]; then
    echo -e "${YELLOW}⚠ Theme file not found: $THEME_FILE${NC}"
    exit 1
fi

THEME_NAME=$(basename "$THEME_FILE" .conf)
echo -e "Current theme: ${GREEN}$THEME_NAME${NC}"
echo ""

# Function to convert rgb(r,g,b) to #RRGGBB
rgb_to_hex() {
    local rgb=$1
    # Extract RGB values
    rgb=$(echo "$rgb" | sed 's/rgb(\(.*\))/\1/')
    
    # If already in hex format (6 chars), just add #
    if [[ ${#rgb} -eq 6 ]]; then
        echo "#$rgb"
    else
        # It's in r, g, b format - not used in your themes, but just in case
        echo "$rgb"
    fi
}

# Parse theme colors
declare -A colors

while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z0-9_-]+)\ *=\ *rgb\(([0-9a-fA-F]+)\) ]]; then
        var_name="${BASH_REMATCH[1]}"
        hex_value="${BASH_REMATCH[2]}"
        colors[$var_name]="#$hex_value"
    fi
done < "$THEME_FILE"

# Map theme colors to VSCodium color customizations
# Background colors
BG_BASE="${colors[bg-base]:-#1a1b26}"
BG_MANTLE="${colors[bg-mantle]:-#16161e}"
BG_CRUST="${colors[bg-crust]:-#0f0f14}"
SURFACE_0="${colors[surface-0]:-#292e42}"
SURFACE_1="${colors[surface-1]:-#33467c}"
SURFACE_2="${colors[surface-2]:-#414868}"

# Text colors
FG_PRIMARY="${colors[fg-primary]:-#c0caf5}"
FG_SECONDARY="${colors[fg-secondary]:-#a9b1d6}"
FG_TERTIARY="${colors[fg-tertiary]:-#9aa5ce}"

# Border colors
BORDER_0="${colors[border-0]:-#565f89}"
BORDER_1="${colors[border-1]:-#737aa2}"
BORDER_2="${colors[border-2]:-#828bb8}"

# Accent colors
ACCENT_BLUE="${colors[accent-blue]:-#7aa2f7}"
ACCENT_GREEN="${colors[accent-green]:-#9ece6a}"
ACCENT_YELLOW="${colors[accent-yellow]:-#e0af68}"
ACCENT_RED="${colors[accent-red]:-#f7768e}"
ACCENT_ORANGE="${colors[accent-orange]:-#ff9e64}"
ACCENT_PURPLE="${colors[accent-purple]:-#9d7cd8}"
ACCENT_CYAN="${colors[accent-cyan]:-#73daca}"

# Backup existing settings
if [ -f "$VSCODIUM_SETTINGS" ]; then
    cp "$VSCODIUM_SETTINGS" "$VSCODIUM_SETTINGS.backup"
    echo -e "${GREEN}✓ Backed up existing settings${NC}"
fi

# Create/update VSCodium color customizations using Python
python3 << EOF
import json
import os

settings_file = "$VSCODIUM_SETTINGS"

# Read existing settings
if os.path.exists(settings_file):
    with open(settings_file, 'r') as f:
        # Remove comments for parsing
        content = f.read()
        lines = []
        for line in content.split('\n'):
            # Simple comment removal (doesn't handle all edge cases but works for most)
            if '//' in line and not '"' in line.split('//')[0]:
                line = line.split('//')[0].rstrip()
            lines.append(line)
        content = '\n'.join(lines)
        
        try:
            settings = json.loads(content)
        except json.JSONDecodeError:
            settings = {}
else:
    settings = {}

# VSCodium color customizations
settings["workbench.colorCustomizations"] = {
    # Editor colors
    "editor.background": "$BG_BASE",
    "editor.foreground": "$FG_PRIMARY",
    "editorLineNumber.foreground": "$FG_TERTIARY",
    "editorLineNumber.activeForeground": "$ACCENT_BLUE",
    "editorCursor.foreground": "$ACCENT_BLUE",
    "editor.selectionBackground": "${SURFACE_1}80",
    "editor.selectionHighlightBackground": "${SURFACE_0}80",
    "editor.findMatchBackground": "${ACCENT_YELLOW}40",
    "editor.findMatchHighlightBackground": "${ACCENT_YELLOW}20",
    
    # Sidebar
    "sideBar.background": "$BG_MANTLE",
    "sideBar.foreground": "$FG_SECONDARY",
    "sideBar.border": "$BORDER_0",
    "sideBarTitle.foreground": "$FG_PRIMARY",
    "sideBarSectionHeader.background": "$SURFACE_0",
    "sideBarSectionHeader.foreground": "$FG_PRIMARY",
    
    # Activity Bar
    "activityBar.background": "$BG_CRUST",
    "activityBar.foreground": "$ACCENT_BLUE",
    "activityBar.inactiveForeground": "$FG_TERTIARY",
    "activityBar.border": "$BORDER_0",
    "activityBarBadge.background": "$ACCENT_BLUE",
    "activityBarBadge.foreground": "$BG_BASE",
    
    # Title Bar
    "titleBar.activeBackground": "$BG_MANTLE",
    "titleBar.activeForeground": "$FG_PRIMARY",
    "titleBar.inactiveBackground": "$BG_CRUST",
    "titleBar.inactiveForeground": "$FG_TERTIARY",
    "titleBar.border": "$BORDER_0",
    
    # Status Bar
    "statusBar.background": "$BG_MANTLE",
    "statusBar.foreground": "$FG_SECONDARY",
    "statusBar.border": "$BORDER_0",
    "statusBar.noFolderBackground": "$BG_MANTLE",
    "statusBar.debuggingBackground": "$ACCENT_ORANGE",
    "statusBar.debuggingForeground": "$BG_BASE",
    
    # Tabs
    "tab.activeBackground": "$BG_BASE",
    "tab.activeForeground": "$FG_PRIMARY",
    "tab.inactiveBackground": "$BG_MANTLE",
    "tab.inactiveForeground": "$FG_TERTIARY",
    "tab.border": "$BORDER_0",
    "tab.activeBorder": "$ACCENT_BLUE",
    "tab.activeBorderTop": "$ACCENT_BLUE",
    
    # Panel (Terminal, Output, etc)
    "panel.background": "$BG_MANTLE",
    "panel.border": "$BORDER_0",
    "panelTitle.activeBorder": "$ACCENT_BLUE",
    "panelTitle.activeForeground": "$FG_PRIMARY",
    "panelTitle.inactiveForeground": "$FG_TERTIARY",
    
    # Terminal
    "terminal.background": "$BG_BASE",
    "terminal.foreground": "$FG_PRIMARY",
    "terminal.ansiBlack": "$BG_CRUST",
    "terminal.ansiRed": "$ACCENT_RED",
    "terminal.ansiGreen": "$ACCENT_GREEN",
    "terminal.ansiYellow": "$ACCENT_YELLOW",
    "terminal.ansiBlue": "$ACCENT_BLUE",
    "terminal.ansiMagenta": "$ACCENT_PURPLE",
    "terminal.ansiCyan": "$ACCENT_CYAN",
    "terminal.ansiWhite": "$FG_PRIMARY",
    "terminal.ansiBrightBlack": "$BORDER_2",
    "terminal.ansiBrightRed": "$ACCENT_RED",
    "terminal.ansiBrightGreen": "$ACCENT_GREEN",
    "terminal.ansiBrightYellow": "$ACCENT_YELLOW",
    "terminal.ansiBrightBlue": "$ACCENT_BLUE",
    "terminal.ansiBrightMagenta": "$ACCENT_PURPLE",
    "terminal.ansiBrightCyan": "$ACCENT_CYAN",
    "terminal.ansiBrightWhite": "$FG_PRIMARY",
    
    # Lists and Trees
    "list.activeSelectionBackground": "$SURFACE_1",
    "list.activeSelectionForeground": "$FG_PRIMARY",
    "list.inactiveSelectionBackground": "$SURFACE_0",
    "list.hoverBackground": "${SURFACE_0}80",
    "list.focusBackground": "$SURFACE_1",
    "list.highlightForeground": "$ACCENT_BLUE",
    
    # Input
    "input.background": "$SURFACE_0",
    "input.foreground": "$FG_PRIMARY",
    "input.border": "$BORDER_1",
    "input.placeholderForeground": "$FG_TERTIARY",
    "inputOption.activeBorder": "$ACCENT_BLUE",
    
    # Buttons
    "button.background": "$ACCENT_BLUE",
    "button.foreground": "$BG_BASE",
    "button.hoverBackground": "$ACCENT_CYAN",
    
    # Scrollbar
    "scrollbarSlider.background": "${SURFACE_2}80",
    "scrollbarSlider.hoverBackground": "${SURFACE_2}",
    "scrollbarSlider.activeBackground": "$BORDER_1",
    
    # Badge
    "badge.background": "$ACCENT_BLUE",
    "badge.foreground": "$BG_BASE",
    
    # Notifications
    "notificationCenter.border": "$BORDER_0",
    "notificationCenterHeader.background": "$BG_MANTLE",
    "notifications.background": "$SURFACE_0",
    "notifications.border": "$BORDER_0",
    "notificationLink.foreground": "$ACCENT_BLUE",
    
    # Breadcrumbs
    "breadcrumb.background": "$BG_BASE",
    "breadcrumb.foreground": "$FG_SECONDARY",
    "breadcrumb.focusForeground": "$FG_PRIMARY",
    "breadcrumb.activeSelectionForeground": "$ACCENT_BLUE",
    
    # Git colors
    "gitDecoration.modifiedResourceForeground": "$ACCENT_YELLOW",
    "gitDecoration.deletedResourceForeground": "$ACCENT_RED",
    "gitDecoration.untrackedResourceForeground": "$ACCENT_GREEN",
    "gitDecoration.ignoredResourceForeground": "$FG_TERTIARY",
    "gitDecoration.conflictingResourceForeground": "$ACCENT_ORANGE",
}

# Write back to file
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)

print("Settings updated successfully")
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ VSCodium colors synchronized with $THEME_NAME theme${NC}"
    echo ""
    echo "Restart VSCodium to see the changes!"
else
    echo -e "${YELLOW}⚠ Failed to update VSCodium settings${NC}"
    echo "Your backup is at: $VSCODIUM_SETTINGS.backup"
    exit 1
fi
