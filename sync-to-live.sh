#!/bin/bash

# Sync configs FROM repo TO live ~/.config/
# Use this when you've edited files in the repo and want to test them

REPO_DIR="$HOME/yahr-quickshell"
CONFIG_DIR="$HOME/.config"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Sync Repo → Live Config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Quickshell
if [ -d "$REPO_DIR/quickshell" ]; then
    echo "Syncing quickshell..."
    rsync -av --exclude='*.backup*' --exclude='settings.json' --exclude='ThemeManager.qml' \
        "$REPO_DIR/quickshell/" "$CONFIG_DIR/quickshell/" \
        || { echo "✗ Quickshell sync failed"; exit 1; }
    echo "✓ Quickshell synced"
fi

# Hypr
if [ -d "$REPO_DIR/hypr" ]; then
    echo "Syncing hypr..."
    rsync -av --exclude='*.backup*' --exclude='hyprland.conf' --exclude='look-and-feel.conf' \
        "$REPO_DIR/hypr/" "$CONFIG_DIR/hypr/" \
        || { echo "✗ Hypr sync failed"; exit 1; }
    echo "✓ Hypr synced"
fi

# Kitty
if [ -d "$REPO_DIR/kitty" ]; then
    echo "Syncing kitty..."
    rsync -av --exclude='*.backup*' --exclude='current-theme.conf' --exclude='themes/current-theme.conf' \
        "$REPO_DIR/kitty/" "$CONFIG_DIR/kitty/" \
        || { echo "✗ Kitty sync failed"; exit 1; }
    # Re-apply the current theme so the dynamic theme file matches the active theme
    if [ -x "$CONFIG_DIR/quickshell/sync-kitty-theme.sh" ]; then
        "$CONFIG_DIR/quickshell/sync-kitty-theme.sh" > /dev/null 2>&1 || true
    fi
    echo "✓ Kitty synced"
fi

# Mako
if [ -d "$REPO_DIR/mako" ]; then
    echo "Syncing mako..."
    rsync -av --exclude='*.backup*' --exclude='config' \
        "$REPO_DIR/mako/" "$CONFIG_DIR/mako/" \
        || { echo "✗ Mako sync failed"; exit 1; }
    # Re-apply the current theme so the dynamic config matches the active theme
    if [ -x "$CONFIG_DIR/quickshell/sync-mako-theme.sh" ]; then
        "$CONFIG_DIR/quickshell/sync-mako-theme.sh" > /dev/null 2>&1 || true
    fi
    echo "✓ Mako synced"
fi

# Nvim
if [ -d "$REPO_DIR/nvim" ]; then
    echo "Syncing nvim..."
    rsync -av --exclude='*.backup*' \
        "$REPO_DIR/nvim/" "$CONFIG_DIR/nvim/" \
        || { echo "✗ Nvim sync failed"; exit 1; }
    echo "✓ Nvim synced"
fi

# Wofi
if [ -d "$REPO_DIR/wofi" ]; then
    echo "Syncing wofi..."
    rsync -av --exclude='*.backup*' \
        "$REPO_DIR/wofi/" "$CONFIG_DIR/wofi/" \
        || { echo "✗ Wofi sync failed"; exit 1; }
    echo "✓ Wofi synced"
fi

# Fastfetch
if [ -d "$REPO_DIR/fastfetch" ]; then
    echo "Syncing fastfetch..."
    rsync -av --exclude='*.backup*' \
        "$REPO_DIR/fastfetch/" "$CONFIG_DIR/fastfetch/" \
        || { echo "✗ Fastfetch sync failed"; exit 1; }
    echo "✓ Fastfetch synced"
fi

# Starship
if [ -f "$REPO_DIR/dotfiles/starship.toml" ]; then
    echo "Syncing starship..."
    cp "$REPO_DIR/dotfiles/starship.toml" "$CONFIG_DIR/starship.toml" \
        || { echo "✗ Starship sync failed"; exit 1; }
    echo "✓ Starship synced"
fi

echo ""
echo "✓ All configs synced to live ~/.config/"
echo ""
echo "Restart affected applications to see changes:"
echo "  • Quickshell: pkill quickshell && quickshell &"
echo "  • Mako: makoctl reload"
echo "  • Terminal: exec bash (for starship)"
