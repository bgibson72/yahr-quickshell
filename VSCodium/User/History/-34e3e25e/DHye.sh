#!/bin/bash

# Zed Theme Sync Script
# Syncs Zed theme with current system theme

ZED_SETTINGS="$HOME/.config/zed/settings.json"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Zed Theme Sync${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get theme argument or detect from Hyprland
THEME_NAME="$1"

if [ -z "$THEME_NAME" ]; then
    # Try to detect from Hyprland config
    HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
    THEME_FILE=$(grep "^source = " "$HYPR_CONF" | head -1 | awk '{print $3}')
    THEME_FILE="${THEME_FILE/#\~/$HOME}"
    THEME_NAME=$(basename "$THEME_FILE" .conf)
fi

echo -e "System theme: ${GREEN}$THEME_NAME${NC}"

# Map system theme names to Zed theme names
# Add or modify mappings as needed
declare -A THEME_MAP=(
    ["catppuccin-mocha"]="Catppuccin Mocha"
    ["catppuccin"]="Catppuccin Mocha"
    ["tokyonight-night"]="Tokyo Night"
    ["tokyonight"]="Tokyo Night"
    ["gruvbox-dark"]="Gruvbox Dark Hard"
    ["gruvbox"]="Gruvbox Dark Hard"
    ["everforest-dark"]="Everforest Dark"
    ["everforest"]="Everforest Dark"
    ["rose-pine"]="Rosé Pine Moon"
    ["rosepine"]="Rosé Pine Moon"
    ["material-deepocean"]="One Dark"
    ["material"]="One Dark"
    ["nightfox-dusk"]="One Dark"
    ["nightfox"]="One Dark"
    ["kanagawa-dark"]="One Dark"
    ["kanagawa"]="One Dark"
    ["dracula"]="Dracula"
    ["nord"]="Nord"
)

# Get Zed theme for current system theme
ZED_THEME="${THEME_MAP[$THEME_NAME]}"

if [ -z "$ZED_THEME" ]; then
    echo -e "${YELLOW}⚠ No Zed theme mapping found for: $THEME_NAME${NC}"
    echo "  Using fallback: One Dark"
    ZED_THEME="One Dark"
fi

echo -e "Zed theme: ${GREEN}$ZED_THEME${NC}"
echo ""

# Check if settings file exists
if [ ! -f "$ZED_SETTINGS" ]; then
    echo -e "${YELLOW}⚠ Zed settings file not found${NC}"
    echo "Creating new settings file..."
    mkdir -p "$(dirname "$ZED_SETTINGS")"
    cat > "$ZED_SETTINGS" <<EOF
{
  "theme": {
    "mode": "system",
    "light": "$ZED_THEME",
    "dark": "$ZED_THEME"
  }
}
EOF
    echo -e "${GREEN}✓ Zed settings created${NC}"
    exit 0
fi

# Backup current settings
cp "$ZED_SETTINGS" "$ZED_SETTINGS.backup"

# Update theme using Python for proper JSON handling
python3 <<EOF
import json
import sys

settings_file = "$ZED_SETTINGS"

try:
    # Read current settings (with comments support)
    with open(settings_file, 'r') as f:
        content = f.read()
    
    # Remove JSON comments (// and /* */)
    import re
    content = re.sub(r'//.*?\n', '\n', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    
    settings = json.loads(content)
    
    # Update theme
    if 'theme' not in settings:
        settings['theme'] = {}
    
    settings['theme']['mode'] = 'system'
    settings['theme']['light'] = "$ZED_THEME"
    settings['theme']['dark'] = "$ZED_THEME"
    
    # Write back with nice formatting
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
    
    print("success")
    
except Exception as e:
    print(f"error: {e}", file=sys.stderr)
    sys.exit(1)
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Zed theme synchronized to: $ZED_THEME${NC}"
    echo ""
    echo "Zed will apply the theme automatically on next focus!"
else
    echo -e "${YELLOW}⚠ Failed to update Zed settings${NC}"
    echo "Your backup is at: $ZED_SETTINGS.backup"
    exit 1
fi
