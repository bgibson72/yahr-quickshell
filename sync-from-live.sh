#!/bin/bash

# Sync configs FROM live ~/.config/ TO repo
# Use this before committing to capture any changes made in live configs

REPO_DIR="$HOME/yahr-quickshell"
CONFIG_DIR="$HOME/.config"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Sync Live Config → Repo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Quickshell
if [ -d "$CONFIG_DIR/quickshell" ]; then
    echo "Syncing quickshell..."
    rsync -av --exclude='*.backup*' --exclude='settings.json' \
        "$CONFIG_DIR/quickshell/" "$REPO_DIR/quickshell/"
    echo "✓ Quickshell synced"
fi

# Hypr
if [ -d "$CONFIG_DIR/hypr" ]; then
    echo "Syncing hypr..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/hypr/" "$REPO_DIR/hypr/"
    echo "✓ Hypr synced"
fi

# Kitty
if [ -d "$CONFIG_DIR/kitty" ]; then
    echo "Syncing kitty..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/kitty/" "$REPO_DIR/kitty/"
    echo "✓ Kitty synced"
fi

# Mako
if [ -d "$CONFIG_DIR/mako" ]; then
    echo "Syncing mako..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/mako/" "$REPO_DIR/mako/"
    echo "✓ Mako synced"
fi

# Nvim
if [ -d "$CONFIG_DIR/nvim" ]; then
    echo "Syncing nvim..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/nvim/" "$REPO_DIR/nvim/"
    echo "✓ Nvim synced"
fi

# Wofi
if [ -d "$CONFIG_DIR/wofi" ]; then
    echo "Syncing wofi..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/wofi/" "$REPO_DIR/wofi/"
    echo "✓ Wofi synced"
fi

# Fastfetch
if [ -d "$CONFIG_DIR/fastfetch" ]; then
    echo "Syncing fastfetch..."
    rsync -av --exclude='*.backup*' \
        "$CONFIG_DIR/fastfetch/" "$REPO_DIR/fastfetch/"
    echo "✓ Fastfetch synced"
fi

# Starship
if [ -f "$CONFIG_DIR/starship.toml" ]; then
    echo "Syncing starship..."
    cp "$CONFIG_DIR/starship.toml" "$REPO_DIR/dotfiles/starship.toml"
    echo "✓ Starship synced"
fi

echo ""
echo "✓ All configs synced to repo"
echo ""
echo "Ready to commit:"
echo "  cd ~/Dev/yahr-quickshell"
echo "  git status"
echo "  git add -A"
echo "  git commit -m 'Update configs from live system'"
