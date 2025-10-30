#!/bin/bash

# Quickshell Installation and Setup Script
# This script will help you install Quickshell and migrate from Waybar

set -e

echo "========================================="
echo "  Quickshell Installation & Migration   "
echo "========================================="
echo ""

# Check if running Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "⚠️  This script is designed for Arch Linux systems"
    echo "For other distros, you'll need to install Quickshell manually"
    echo "See: https://github.com/outfoxxed/quickshell"
    exit 1
fi

# Check if yay or paru is installed
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo "❌ No AUR helper found (yay or paru)"
    echo "Please install yay or paru first:"
    echo "  sudo pacman -S --needed git base-devel"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay && makepkg -si"
    exit 1
fi

echo "✓ Found AUR helper: $AUR_HELPER"
echo ""

# Check if Quickshell is already installed
if command -v quickshell &> /dev/null; then
    echo "✓ Quickshell is already installed"
    QUICKSHELL_VERSION=$(quickshell --version 2>&1 || echo "unknown")
    echo "  Version: $QUICKSHELL_VERSION"
else
    echo "Installing Quickshell from AUR..."
    $AUR_HELPER -S quickshell-git --needed
    echo "✓ Quickshell installed successfully"
fi

echo ""
echo "========================================="
echo "  Configuration Status                  "
echo "========================================="
echo ""

# Check if configuration exists
if [ -d "$HOME/.config/quickshell" ]; then
    echo "✓ Quickshell configuration found at ~/.config/quickshell"
    echo ""
    ls -lh "$HOME/.config/quickshell"/*.qml 2>/dev/null | awk '{print "  " $9}'
else
    echo "❌ No Quickshell configuration found"
    echo "The configuration should have been created in ~/.config/quickshell"
    exit 1
fi

echo ""
echo "========================================="
echo "  Migration Steps                       "
echo "========================================="
echo ""

# Check if Waybar is running
if pgrep -x waybar > /dev/null; then
    echo "⚠️  Waybar is currently running"
    read -p "Do you want to stop Waybar now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        killall waybar
        echo "✓ Waybar stopped"
    else
        echo "⚠️  You'll need to stop Waybar manually before starting Quickshell"
    fi
else
    echo "✓ Waybar is not running"
fi

echo ""
echo "========================================="
echo "  Testing Quickshell                    "
echo "========================================="
echo ""

read -p "Do you want to test Quickshell now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting Quickshell..."
    echo "Press Ctrl+C to stop the test"
    echo ""
    sleep 2
    quickshell -c "$HOME/.config/quickshell/shell.qml"
fi

echo ""
echo "========================================="
echo "  Setup Complete!                       "
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Test your configuration:"
echo "   quickshell"
echo ""
echo "2. If everything works, add to Hyprland autostart:"
echo "   echo 'exec-once = quickshell' >> ~/.config/hypr/hyprland.conf"
echo ""
echo "3. Remove Waybar autostart from Hyprland (if present):"
echo "   sed -i '/exec-once.*waybar/d' ~/.config/hypr/hyprland.conf"
echo ""
echo "4. Restart Hyprland or run manually:"
echo "   killall waybar && quickshell &"
echo ""
echo "📖 See ~/.config/quickshell/README.md for more information"
echo ""
