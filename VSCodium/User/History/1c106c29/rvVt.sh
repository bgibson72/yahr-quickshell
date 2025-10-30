#!/bin/bash
# Reliable push script for YAHR configs

set -e

REPO_DIR="$HOME/yahr-push-final"

echo "🚀 YAHR Configuration Push"
echo "=========================="
echo ""

# Clean start
echo "1. Cleaning old temp directory..."
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

# Copy configs
echo "2. Copying configuration directories..."
cd "$HOME/.config"
cp -r hypr kitty mako nvim quickshell vesktop VSCodium "$REPO_DIR/"

# Remove any .git subdirectories
echo "3. Cleaning embedded git repositories..."
cd "$REPO_DIR"
find . -name ".git" -type d | while read dir; do
    echo "   Removing: $dir"
    rm -rf "$dir"
done

# Create .gitignore
echo "4. Creating .gitignore..."
cat > .gitignore << 'EOF'
# Logs and temp files
*.log
*.swp
*.swo
*.tmp
.DS_Store

# User-specific data
quickshell/settings.json
vesktop/sessionData/
VSCodium/User/globalStorage/
VSCodium/User/workspaceStorage/
VSCodium/logs/
VSCodium/CachedData/
EOF

# Create README
echo "5. Creating README.md..."
cat > README.md << 'EOF'
# YAHR - Yet Another Hyprland Rice 🍚

Complete Arch Linux + Hyprland desktop configuration with unified theme system.

## Features
- 🎨 11 beautiful themes with instant switching
- 🖥️ Quickshell desktop environment
- ⚡ Synced themes across all apps
- 📦 Ready to use configurations

## Quick Install
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell
# Backup first!
mkdir -p ~/config-backup
cp -r ~/.config/{hypr,kitty,quickshell} ~/config-backup/ 2>/dev/null || true
# Install
cp -r hypr kitty mako nvim quickshell vesktop VSCodium ~/.config/
```

## Included Applications
- **hypr** - Hyprland window manager (+ 11 themes)
- **quickshell** - Custom desktop environment
- **kitty** - Terminal with theme sync
- **mako** - Notification daemon
- **nvim** - Neovim (AstroNvim)
- **VSCodium** - Code editor
- **vesktop** - Discord client

## Quick Start
After installation:
- Press `Super + T` for theme switcher
- Press `Super + D` for app launcher
- Press `Super + C` for calendar

## Documentation
- [Quickshell Guide](quickshell/README.md)
- [Mako Setup](mako/README.md)

## Themes
Material • Catppuccin • Dracula • Eldritch • Everforest • Gruvbox • Kanagawa • NightFox • Nord • Rosé Pine • TokyoNight

---
MIT License • Made with ❤️ for Arch + Hyprland
EOF

# Initialize git
echo "6. Initializing git repository..."
git init -b main
git remote add origin https://github.com/bgibson72/yahr-quickshell.git

# Add all files
echo "7. Adding files to git..."
git add -A

# Show what will be committed
echo ""
echo "Files to commit:"
git diff --cached --name-only | head -20
echo "... (showing first 20 files)"
echo ""
TOTAL=$(git diff --cached --name-only | wc -l)
echo "Total files: $TOTAL"
echo ""

# Commit
echo "8. Creating commit..."
git commit -m "YAHR: Complete Hyprland configuration with 11-theme system

Includes:
- Hyprland with theme definitions
- Quickshell desktop environment
- Kitty terminal with theme sync
- Mako notifications
- Neovim (AstroNvim)
- VSCodium with theme integration
- Vesktop (Discord) theme support

All applications synchronized with unified theme switcher."

echo ""
echo "✅ SUCCESS!"
echo ""
echo "Repository prepared at: $REPO_DIR"
echo ""
echo "To push to GitHub, run:"
echo "  cd $REPO_DIR"
echo "  git push -u origin main --force"
echo ""
echo "⚠️  This will replace the current repository content."
