#!/bin/bash

# Standalone Spicetify setup helper for YAHR Quickshell.
# Run this if you skipped Spotify/Spicetify during the main install,
# or if you need to re-initialise Spicetify after a Spotify update.
#
# Usage: ./spicetify-setup.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; }

THEMES_DIR="$HOME/.config/spicetify/Themes"
QUICKSHELL_DIR="$HOME/.config/quickshell"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  YAHR – Spicetify Setup${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Check prerequisites ────────────────────────────────────────────────────────
if ! command -v spotify &>/dev/null; then
    error "Spotify not found.  Install it first (e.g. yay -S spotify)."
    exit 1
fi

if ! command -v spicetify &>/dev/null; then
    error "Spicetify CLI not found.  Install it first (e.g. yay -S spicetify-cli)."
    exit 1
fi

success "Spotify and Spicetify CLI found"

# ── Fix permissions on /opt/spotify ───────────────────────────────────────────
if [ -d "/opt/spotify" ]; then
    info "Setting permissions on /opt/spotify (sudo required)…"
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    success "Permissions fixed"
else
    warn "/opt/spotify not found – skipping permission fix"
fi

# ── Install community themes ───────────────────────────────────────────────────
mkdir -p "$THEMES_DIR"

info "Cloning spicetify/spicetify-themes community themes…"
TMP_THEMES=$(mktemp -d)
if git clone --depth=1 https://github.com/spicetify/spicetify-themes.git "$TMP_THEMES/spicetify-themes"; then
    for theme_dir in "$TMP_THEMES/spicetify-themes"/*/; do
        tname=$(basename "$theme_dir")
        [[ -d "$theme_dir" ]] && cp -r "$theme_dir" "$THEMES_DIR/$tname"
    done
    success "Community themes installed to $THEMES_DIR"
else
    warn "Could not clone spicetify-themes – check your internet connection"
fi
rm -rf "$TMP_THEMES"

info "Cloning catppuccin/spicetify Catppuccin theme…"
TMP_CAT=$(mktemp -d)
if git clone --depth=1 https://github.com/catppuccin/spicetify.git "$TMP_CAT/catppuccin"; then
    mkdir -p "$THEMES_DIR/catppuccin"
    # Repo stores theme files directly under catppuccin/
    src_dir=$(find "$TMP_CAT/catppuccin" -name "color.ini" | head -1 | xargs dirname)
    if [[ -n "$src_dir" ]]; then
        cp "$src_dir/color.ini" "$src_dir/user.css" "$THEMES_DIR/catppuccin/"
        success "Catppuccin Spicetify theme installed"
    else
        warn "Could not locate color.ini in catppuccin/spicetify repo"
    fi
else
    warn "Could not clone catppuccin/spicetify"
fi
rm -rf "$TMP_CAT"

# ── Configure and apply ────────────────────────────────────────────────────────
info "Configuring Spicetify…"
spicetify config prefs_path "$HOME/.config/spotify/prefs" 2>/dev/null
spicetify config inject_theme_js 1 2>/dev/null

# Determine which theme to apply based on current YAHR theme
CURRENT_THEME=""
if [ -f "$HOME/.config/hypr/.current-theme" ]; then
    CURRENT_THEME=$(cat "$HOME/.config/hypr/.current-theme")
fi

info "Running spicetify backup…"
spicetify backup

# Apply via the sync script if it exists, else apply Catppuccin/mocha as default
if [ -x "$QUICKSHELL_DIR/sync-spicetify-theme.sh" ]; then
    info "Applying theme matching current YAHR theme (${CURRENT_THEME:-default})…"
    "$QUICKSHELL_DIR/sync-spicetify-theme.sh" "${CURRENT_THEME:-Catppuccin}"
else
    # Fallback: apply Catppuccin mocha directly
    DEFAULT_THEME="catppuccin"
    DEFAULT_SCHEME="mocha"
    if [ ! -d "$THEMES_DIR/$DEFAULT_THEME" ]; then
        DEFAULT_THEME="Dribbblish"
        DEFAULT_SCHEME="base"
    fi
    spicetify config current_theme "$DEFAULT_THEME" 2>/dev/null
    spicetify config color_scheme "$DEFAULT_SCHEME" 2>/dev/null
    if spicetify apply; then
        success "Spicetify applied: $DEFAULT_THEME ($DEFAULT_SCHEME)"
    else
        warn "spicetify apply failed – try launching Spotify once, then rerun this script"
    fi
fi

echo ""
success "Spicetify setup complete!"
info "Themes will now sync automatically when you switch YAHR themes."
info "Manual sync: ~/.config/quickshell/sync-spicetify-theme.sh [ThemeName]"
echo ""
