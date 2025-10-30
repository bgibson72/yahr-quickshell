#!/bin/bash
# Script to push YAHR configs to GitHub

set -e

echo "=== YAHR Config Push Script ==="
echo ""

# Create temporary repo structure
TEMP_REPO="/tmp/yahr-push-$(date +%s)"
echo "Creating temporary repository at $TEMP_REPO"
mkdir -p "$TEMP_REPO/config"

# Initialize git
cd "$TEMP_REPO"
git init
git remote add origin https://github.com/bgibson72/yahr-quickshell.git

# Copy config directories
echo "Copying configuration directories..."
cp -r ~/.config/hypr config/
cp -r ~/.config/kitty config/
cp -r ~/.config/mako config/
cp -r ~/.config/nvim config/
cp -r ~/.config/quickshell config/
cp -r ~/.config/vesktop config/
cp -r ~/.config/VSCodium config/

# Remove embedded git repos
echo "Cleaning up embedded git repositories..."
find config/ -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

# Copy documentation
echo "Adding documentation..."
cp ~/.config/quickshell/README.md config/quickshell/
cp ~/.config/mako/README.md config/mako/

# Create root README
cat > README.md << 'EOF'
# YAHR Configuration Repository

**YAHR** - Yet Another Hyprland Rice 🍚

A complete, theme-synchronized desktop environment configuration for Arch Linux + Hyprland.

## 🎨 Features

- **Unified Theme System**: One command switches themes across all applications
- **11 Beautiful Themes**: Material, Catppuccin, Dracula, Eldritch, Everforest, Gruvbox, Kanagawa, NightFox, Nord, Rosé Pine, TokyoNight
- **Quickshell Desktop Environment**: Custom bar, widgets, and controls
- **Seamless Integration**: Hyprland, Kitty, Neovim, VSCodium, Vesktop, Zed, and more

## 📦 What's Included

- **hypr** - Hyprland window manager with theme system
- **quickshell** - Custom desktop environment
- **kitty** - Terminal with synced themes
- **mako** - Notification daemon
- **nvim** - Neovim (AstroNvim)
- **VSCodium** - Editor with theme sync
- **vesktop** - Discord with theme sync

## 🚀 Installation

```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell
cp -r config/* ~/.config/
```

See individual config directories for detailed documentation.

## 📚 Documentation

- [Quickshell Guide](config/quickshell/README.md)
- [Mako Setup](config/mako/README.md)

## ⌨️ Quick Keys

- `Super + T` - Theme Switcher
- `Super + D` - App Launcher  
- `Super + C` - Calendar
- `Super + Enter` - Terminal

---

Made with ❤️ for Arch + Hyprland
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# OS-specific
.DS_Store
Thumbs.db
*~

# Editor
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log

# Cache
.cache/

# User-specific
config/quickshell/settings.json
config/vesktop/sessionData/
config/VSCodium/User/globalStorage/
config/VSCodium/User/workspaceStorage/
EOF

# Add and commit
echo "Adding files to git..."
git add .

echo "Committing..."
git commit -m "Initial commit: YAHR unified configuration

- Hyprland with 11-theme system
- Quickshell desktop environment
- Kitty terminal with theme sync
- Mako notifications with theme integration
- Complete documentation"

echo ""
echo "=== Ready to Push ==="
echo "Repository prepared at: $TEMP_REPO"
echo ""
echo "To push to GitHub, run:"
echo "  cd $TEMP_REPO"
echo "  git branch -M main"
echo "  git push -u origin main --force"
echo ""
echo "Note: This will REPLACE the current repository content."
echo "Make sure you want to do this before running the push command!"
