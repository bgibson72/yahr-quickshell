#!/bin/bash

# Sync Starship Prompt Colors with Current Quickshell Theme  
# Only replaces hex color values - preserves ALL glyphs and formatting

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Extract theme name and colors
theme_name=$(grep 'property string currentTheme:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_cyan=$(grep 'property color accentCyan:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_green=$(grep 'property color accentGreen:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_yellow=$(grep 'property color accentYellow:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface0=$(grep 'property color surface0:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Syncing Starship colors for theme: $theme_name"

# Backup with timestamp
cp "$STARSHIP_CONFIG" "$STARSHIP_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"

# Use Python to intelligently replace colors by frequency
python3 << PYTHON_EOF
import re
from collections import Counter

with open("$STARSHIP_CONFIG", 'r') as f:
    content = f.read()

# Find all hex colors and count frequency
hex_colors = re.findall(r'#[0-9a-fA-F]{6}', content)
color_freq = Counter(hex_colors)

# Sort by frequency (most common first)
sorted_colors = [c for c, _ in color_freq.most_common()]

# Map old colors to new colors based on typical usage
# Most frequent = background, then accents in order of usage
color_map = {}
new_colors = ["$bg_base", "$accent_green", "$surface0", "$accent_blue", "$accent_yellow", "$accent_cyan", "$fg_primary"]

for i, old_color in enumerate(sorted_colors):
    if i < len(new_colors):
        color_map[old_color] = new_colors[i]

# Replace all occurrences
for old, new in color_map.items():
    content = content.replace(old, new)

# Update theme name in comment
content = re.sub(r'# Auto-synced with Quickshell Theme: .*', 
                 f'# Auto-synced with Quickshell Theme: $theme_name', 
                 content)

# Write back
with open("$STARSHIP_CONFIG", 'w') as f:
    f.write(content)

print("✓ Colors updated (all glyphs preserved)")
PYTHON_EOF

echo "  Accent Blue: $accent_blue"
echo "  Accent Green: $accent_green"  
echo "  Accent Yellow: $accent_yellow"
echo "  Accent Cyan: $accent_cyan"
echo ""
echo "Restart terminal to see changes: exec zsh"
