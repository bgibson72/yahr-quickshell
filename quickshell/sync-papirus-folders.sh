#!/bin/bash

# Sync Papirus Folder Colors with Current Theme
# Uses papirus-folders utility to change folder icon colors

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"

# Check if papirus-folders is available
if ! command -v papirus-folders &> /dev/null; then
    echo "Error: papirus-folders command not found"
    echo "Install with: sudo pacman -S papirus-icon-theme"
    exit 1
fi

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found at $THEME_MANAGER"
    exit 1
fi

# Get current theme name (check for both themeName and currentTheme properties)
theme_name=$(grep -E 'property string (themeName|currentTheme):' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Setting Papirus folder colors for theme: $theme_name"

# Map theme names to Papirus folder colors
# Based on the dominant accent color of each theme
case "$theme_name" in
    "tokyonight-night"|"TokyoNight")
        folder_color="blue"  # Tokyo Night's signature blue (#7aa2f7)
        ;;
    "catppuccin-mocha"|"Catppuccin")
        folder_color="blue"  # Catppuccin blue (#89b4fa)
        ;;
    "gruvbox-dark"|"Gruvbox")
        folder_color="orange"  # Gruvbox orange (#fe8019)
        ;;
    "material"|"Material")
        folder_color="red"  # Material red
        ;;
    "everforest"|"Everforest")
        folder_color="brown"  # Everforest earthy brown
        ;;
    "kanagawa"|"Kanagawa")
        folder_color="palebrown"  # Kanagawa pale brown
        ;;
    "nightfox"|"NightFox")
        folder_color="cyan"  # Nightfox cyan
        ;;
    "rosepine"|"RosePine")
        folder_color="pink"  # Rose Pine signature pink
        ;;
    "dracula"|"Dracula")
        folder_color="magenta"  # Dracula purple/magenta
        ;;
    "nord"|"Nord")
        folder_color="bluegrey"  # Nord blue-grey aesthetic
        ;;
    "eldritch"|"Eldritch")
        folder_color="violet"  # Eldritch purple/violet
        ;;
    *)
        folder_color="blue"  # Default fallback
        echo "Unknown theme, using default blue folders"
        ;;
esac

# Apply the folder color
echo "Applying Papirus folder color: $folder_color"

# Note: papirus-folders requires sudo to modify system icon files
# For passwordless operation, add to /etc/sudoers.d/papirus-folders:
# %wheel ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders
sudo papirus-folders -C "$folder_color" --theme Papirus-Dark 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Successfully updated Papirus folder colors to $folder_color"
else
    echo "Note: papirus-folders requires sudo permissions"
    echo "For automatic updates, add this to /etc/sudoers.d/papirus-folders:"
    echo "  %wheel ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders"
    exit 1
fi
