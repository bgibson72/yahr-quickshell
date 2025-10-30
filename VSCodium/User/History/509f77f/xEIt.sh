#!/usr/bin/env bash
# Install script for Pluck

set -e

echo "Installing Pluck..."

# Build release version
cargo build --release

# Create directories if they don't exist
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

# Copy binary
cp target/release/pluck ~/.local/bin/
chmod +x ~/.local/bin/pluck

# Create desktop entry
cat > ~/.local/share/applications/pluck.desktop << 'EOF'
[Desktop Entry]
Name=Pluck
Comment=Extract color palettes from images
Exec=pluck
Icon=applications-graphics
Terminal=false
Type=Application
Categories=Graphics;Utility;
Keywords=color;palette;image;picker;
EOF

echo "✓ Pluck installed successfully!"
echo ""
echo "You can now:"
echo "  1. Run from terminal: pluck"
echo "  2. Launch from your application menu"
echo ""
echo "Note: You may need to log out and back in for the application menu entry to appear"
echo "      or run: update-desktop-database ~/.local/share/applications/"
