#!/bin/bash

# Sync configs FROM repo TO live ~/.config/
# Use this when you've edited files in the repo and want to test them

REPO_DIR="$HOME/yahr-quickshell"
CONFIG_DIR="$HOME/.config"

has_rsync=false
if command -v rsync >/dev/null 2>&1; then
    has_rsync=true
fi

sync_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    shift 2
    local excludes=("$@")

    mkdir -p "$dest_dir"

    if [ "$has_rsync" = true ]; then
        local rsync_args=(-av)
        local ex
        for ex in "${excludes[@]}"; do
            rsync_args+=("--exclude=$ex")
        done
        rsync "${rsync_args[@]}" "$src_dir/" "$dest_dir/"
        return $?
    fi

    local tar_excludes=()
    local ex
    for ex in "${excludes[@]}"; do
        tar_excludes+=("--exclude=$ex")
    done

    (cd "$src_dir" && tar "${tar_excludes[@]}" -cf - .) | (cd "$dest_dir" && tar -xf -)
}

sync_hypr_dir() {
    local src_dir="$1"
    local dest_dir="$2"

    mkdir -p "$dest_dir"

    sync_dir "$src_dir" "$dest_dir" '*.backup*' 'hyprland.conf' 'look-and-feel.conf' '.current-theme' '*.lua' \
        || return 1

    local lua_file
    while IFS= read -r -d '' lua_file; do
        local rel_path="${lua_file#$src_dir/}"
        local dest_path="$dest_dir/$rel_path"
        local dest_parent
        dest_parent="$(dirname "$dest_path")"
        mkdir -p "$dest_parent"

        local tmp_path
        tmp_path="$dest_path.tmp-sync"
        cp "$lua_file" "$tmp_path" || return 1
        mv "$tmp_path" "$dest_path" || return 1
    done < <(find "$src_dir" -type f -name '*.lua' -print0)
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Sync Repo → Live Config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$has_rsync" = false ]; then
    echo "⚠ rsync not found; using tar fallback"
    echo ""
fi

# Quickshell
if [ -d "$REPO_DIR/quickshell" ]; then
    echo "Syncing quickshell..."
    sync_dir "$REPO_DIR/quickshell" "$CONFIG_DIR/quickshell" '*.backup*' 'settings.json' 'ThemeManager.qml' \
        || { echo "✗ Quickshell sync failed"; exit 1; }
    echo "✓ Quickshell synced"
fi

# Hypr
if [ -d "$REPO_DIR/hypr" ]; then
    echo "Syncing hypr..."
    sync_hypr_dir "$REPO_DIR/hypr" "$CONFIG_DIR/hypr" \
        || { echo "✗ Hypr sync failed"; exit 1; }
    echo "✓ Hypr synced"
fi

# Kitty
if [ -d "$REPO_DIR/kitty" ]; then
    echo "Syncing kitty..."
    sync_dir "$REPO_DIR/kitty" "$CONFIG_DIR/kitty" '*.backup*' 'current-theme.conf' 'themes/current-theme.conf' \
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
    sync_dir "$REPO_DIR/mako" "$CONFIG_DIR/mako" '*.backup*' 'config' \
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
    sync_dir "$REPO_DIR/nvim" "$CONFIG_DIR/nvim" '*.backup*' \
        || { echo "✗ Nvim sync failed"; exit 1; }
    echo "✓ Nvim synced"
fi

# Wofi
if [ -d "$REPO_DIR/wofi" ]; then
    echo "Syncing wofi..."
    sync_dir "$REPO_DIR/wofi" "$CONFIG_DIR/wofi" '*.backup*' \
        || { echo "✗ Wofi sync failed"; exit 1; }
    echo "✓ Wofi synced"
fi

# Fastfetch
if [ -d "$REPO_DIR/fastfetch" ]; then
    echo "Syncing fastfetch..."
    sync_dir "$REPO_DIR/fastfetch" "$CONFIG_DIR/fastfetch" '*.backup*' \
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
