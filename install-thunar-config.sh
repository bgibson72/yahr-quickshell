#!/bin/bash

# Thunar Configuration Installer
# Installs Thunar settings for consistent look and feel

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THUNAR_DIR="$SCRIPT_DIR/thunar"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Thunar Configuration Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Thunar is installed
if ! command -v thunar &> /dev/null; then
    echo "⚠ Warning: Thunar is not installed"
    echo "Install with: sudo pacman -S thunar"
    exit 1
fi

# Backup existing configuration
if [ -d "$HOME/.config/Thunar" ] || [ -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ]; then
    echo "Backing up existing Thunar configuration..."
    mkdir -p ~/config-backup/thunar-$(date +%Y%m%d-%H%M%S)
    cp -r ~/.config/Thunar/* ~/config-backup/thunar-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null
    cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml ~/config-backup/thunar-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null
    echo "✓ Backup created in ~/config-backup/"
    echo ""
fi

# Create necessary directories
echo "Creating configuration directories..."
mkdir -p ~/.config/Thunar
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
echo "✓ Directories created"
echo ""

# Install configuration files
echo "Installing Thunar configuration..."

if [ -f "$THUNAR_DIR/accels.scm" ]; then
    cp "$THUNAR_DIR/accels.scm" ~/.config/Thunar/
    echo "✓ Installed keyboard shortcuts (accels.scm)"
fi

if [ -f "$THUNAR_DIR/uca.xml" ]; then
    cp "$THUNAR_DIR/uca.xml" ~/.config/Thunar/
    echo "✓ Installed custom actions (uca.xml)"
fi

if [ -f "$THUNAR_DIR/thunar.xml" ]; then
    cp "$THUNAR_DIR/thunar.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    echo "✓ Installed main preferences (thunar.xml)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Thunar configuration installed successfully!"
echo ""
echo "Settings applied:"
echo "  • Icon View with 150% zoom"
echo "  • Show hidden files enabled"
echo "  • Double-click to open"
echo "  • Symbolic icons in sidebar"
echo ""
echo "Restart Thunar to apply changes:"
echo "  thunar -q && thunar &"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
