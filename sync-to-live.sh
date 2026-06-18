#!/bin/bash

# Sync configs FROM repo TO live ~/.config/
# Use this when you've edited files in the repo and want to test them

REPO_DIR="$HOME/yahr-quickshell"
CONFIG_DIR="$HOME/.config"

REQUIRED_QUICKSHELL_QML=(
    "shell.qml"
    "SystemInfoWidget.qml"
    "CalendarTab.qml"
    "WeatherTab.qml"
    "SystemTab.qml"
    "WallpaperPickerContent.qml"
    "SettingsWidget.qml"
    "ThemeManager.qml"
)

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

sync_tree() {
    local src="$1"
    local dst="$2"
    shift 2
    local excludes=("$@")

    mkdir -p "$dst"

    if command_exists rsync; then
        local rsync_args=(-av)
        local ex
        for ex in "${excludes[@]}"; do
            rsync_args+=("--exclude=$ex")
        done
        rsync "${rsync_args[@]}" "$src/" "$dst/"
        return $?
    fi

    echo "  ! rsync not found, using tar fallback"
    local tar_args=()
    local ex
    for ex in "${excludes[@]}"; do
        tar_args+=("--exclude=$ex")
    done

    (
        cd "$src" || exit 1
        tar cf - "${tar_args[@]}" .
    ) | (
        cd "$dst" || exit 1
        tar xpf -
    )
}

validate_quickshell_qml_set() {
    local base_dir="$1"
    local label="$2"
    local missing=()
    local file

    for file in "${REQUIRED_QUICKSHELL_QML[@]}"; do
        if [ ! -f "$base_dir/$file" ]; then
            missing+=("$file")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "✗ Missing required Quickshell QML files in $label:"
        for file in "${missing[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    return 0
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Sync Repo → Live Config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Quickshell
if [ -d "$REPO_DIR/quickshell" ]; then
    validate_quickshell_qml_set "$REPO_DIR/quickshell" "repo" \
        || { echo "✗ Quickshell preflight validation failed"; exit 1; }

    echo "Syncing quickshell..."
    sync_tree "$REPO_DIR/quickshell" "$CONFIG_DIR/quickshell" '*.backup*' 'settings.json' 'ThemeManager.qml' \
        || { echo "✗ Quickshell sync failed"; exit 1; }

    validate_quickshell_qml_set "$CONFIG_DIR/quickshell" "live config" \
        || { echo "✗ Quickshell post-sync validation failed"; exit 1; }

    echo "✓ Quickshell synced"
fi

# Hypr
if [ -d "$REPO_DIR/hypr" ]; then
    echo "Syncing hypr..."
    sync_tree "$REPO_DIR/hypr" "$CONFIG_DIR/hypr" '*.backup*' 'hyprland.conf' 'look-and-feel.conf' '.current-theme' \
        || { echo "✗ Hypr sync failed"; exit 1; }
    echo "✓ Hypr synced"
fi

# Kitty
if [ -d "$REPO_DIR/kitty" ]; then
    echo "Syncing kitty..."
    sync_tree "$REPO_DIR/kitty" "$CONFIG_DIR/kitty" '*.backup*' 'current-theme.conf' 'themes/current-theme.conf' \
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
    sync_tree "$REPO_DIR/mako" "$CONFIG_DIR/mako" '*.backup*' 'config' \
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
    sync_tree "$REPO_DIR/nvim" "$CONFIG_DIR/nvim" '*.backup*' \
        || { echo "✗ Nvim sync failed"; exit 1; }
    echo "✓ Nvim synced"
fi

# Wofi
if [ -d "$REPO_DIR/wofi" ]; then
    echo "Syncing wofi..."
    sync_tree "$REPO_DIR/wofi" "$CONFIG_DIR/wofi" '*.backup*' \
        || { echo "✗ Wofi sync failed"; exit 1; }
    echo "✓ Wofi synced"
fi

# Fastfetch
if [ -d "$REPO_DIR/fastfetch" ]; then
    echo "Syncing fastfetch..."
    sync_tree "$REPO_DIR/fastfetch" "$CONFIG_DIR/fastfetch" '*.backup*' \
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
