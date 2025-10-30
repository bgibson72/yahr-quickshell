#!/bin/bash
# Quick push script for YAHR configs

REPO_DIR="$HOME/yahr-push-temp"

# Clean and create
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR/config"
cd "$REPO_DIR"

# Init git
git init
git remote add origin https://github.com/bgibson72/yahr-quickshell.git

# Copy configs
cp -r ~/.config/{hypr,kitty,mako,nvim,quickshell,vesktop,VSCodium} config/

# Remove nested .git
find config/ -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

# Add README
cp /home/bryan/.config/quickshell/README.md README-FULL.md

# Simple README
cat > README.md << 'EOF'
# YAHR - Yet Another Hyprland Rice

Unified configuration for Arch Linux + Hyprland with theme synchronization.

## Features
- 11 themes across all apps
- Quickshell desktop environment
- Custom widgets and bar
- Complete documentation

## Install
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
cp -r yahr-quickshell/config/* ~/.config/
```

Press `Super+T` for theme switcher!
EOF

# .gitignore
cat > .gitignore << 'EOF'
*.log
*.swp
.DS_Store
config/quickshell/settings.json
config/vesktop/sessionData/
config/VSCodium/User/globalStorage/
config/VSCodium/User/workspaceStorage/
EOF

# Commit
git add .
git commit -m "YAHR unified config - Hyprland + Quickshell + themes"

echo ""
echo "✅ Repository prepared at: $REPO_DIR"
echo ""
echo "To push:"
echo "  cd $REPO_DIR"
echo "  git push -u origin main --force"
