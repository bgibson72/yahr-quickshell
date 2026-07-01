#!/bin/bash

# Sync Spicetify (Spotify UI) theme to match the active YAHR Quickshell theme.
# Called automatically by theme-switcher-quickshell during theme switching.
# Can also be run manually: sync-spicetify-theme.sh [ThemeName]
#
# Theme name should be Title Case (e.g. Catppuccin, TokyoNight, Gruvbox).
# If omitted, the current theme is read from ~/.config/hypr/.current-theme.

SPICETIFY_THEMES_DIR="$HOME/.config/spicetify/Themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

THEME="${1:-}"

# ── Resolve theme ─────────────────────────────────────────────────────────────
if [[ -z "$THEME" ]]; then
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        THEME=$(cat "$CURRENT_THEME_FILE")
    else
        echo "sync-spicetify-theme: no theme supplied and $CURRENT_THEME_FILE not found"
        exit 1
    fi
fi

# ── Prerequisites ─────────────────────────────────────────────────────────────
if ! command -v spicetify &>/dev/null; then
    echo "spicetify not found – skipping Spotify theme sync"
    exit 0
fi

if ! command -v spotify &>/dev/null; then
    echo "Spotify not found – skipping Spicetify theme sync"
    exit 0
fi

# ── Theme mapping ─────────────────────────────────────────────────────────────
# Keys are the Title-Case theme names written by theme-switcher-quickshell.
# Values: "<SpicetifyThemeDir> [color_scheme]"
#
# - "catppuccin"  → official Catppuccin/spicetify theme (mocha variant)
# - "Dribbblish"  → spicetify/spicetify-themes; has built-in color-scheme support
declare -A THEME_MAP=(
    ["Catppuccin"]="catppuccin mocha"
    ["TokyoNight"]="Dribbblish base"
    ["Gruvbox"]="Dribbblish gruvbox"
    ["Dracula"]="Dribbblish dracula"
    ["Nord"]="Dribbblish nord"
    ["RosePine"]="Dribbblish rosepine"
    ["Kanagawa"]="Dribbblish base"
    ["NightFox"]="Dribbblish base"
    ["Eldritch"]="Dribbblish dracula"
    ["Material"]="Dribbblish base"
    ["Monochrome"]="Dribbblish base"
    ["Solarized"]="Dribbblish solarized"
    ["Everforest"]="Dribbblish base"
)

ENTRY="${THEME_MAP[$THEME]}"
if [[ -z "$ENTRY" ]]; then
    echo -e "${YELLOW}⚠ No Spicetify mapping for theme '$THEME' – falling back to Dribbblish base${NC}"
    ENTRY="Dribbblish base"
fi

SPIC_THEME=$(awk '{print $1}' <<< "$ENTRY")
SPIC_SCHEME=$(awk '{print $2}' <<< "$ENTRY")

# ── Verify theme is installed ─────────────────────────────────────────────────
if [[ ! -d "$SPICETIFY_THEMES_DIR/$SPIC_THEME" ]]; then
    echo -e "${YELLOW}⚠ Spicetify theme '$SPIC_THEME' not installed at $SPICETIFY_THEMES_DIR/$SPIC_THEME${NC}"
    echo "  Run the YAHR installer or: ~/.config/quickshell/spicetify-setup.sh"
    exit 0
fi

# ── Apply ─────────────────────────────────────────────────────────────────────
echo "Applying Spicetify theme: $SPIC_THEME${SPIC_SCHEME:+ ($SPIC_SCHEME)}"

spicetify config current_theme "$SPIC_THEME" 2>/dev/null

if [[ -n "$SPIC_SCHEME" ]]; then
    spicetify config color_scheme "$SPIC_SCHEME" 2>/dev/null
fi

# Ensure Spotify app directory is writable (required for AUR spotify package)
sudo chmod a+wr /opt/spotify /opt/spotify/Apps -R 2>/dev/null

if spicetify apply 2>/dev/null; then
    echo -e "${GREEN}✓ Spicetify theme applied: $SPIC_THEME${SPIC_SCHEME:+ ($SPIC_SCHEME)}${NC}"

    # Restart Spotify if it is currently open so the new theme is loaded
    if pgrep -x spotify &>/dev/null; then
        echo "  Restarting Spotify to apply new theme…"
        killall spotify 2>/dev/null
        sleep 0.8
        spotify &>/dev/null &
        disown
        echo -e "${GREEN}  ✓ Spotify restarted${NC}"
    fi
else
    echo -e "${YELLOW}⚠ spicetify apply failed${NC}"
    echo "  If this is a fresh install, run:"
    echo "    sudo chmod a+wr /opt/spotify && sudo chmod a+wr /opt/spotify/Apps -R"
    echo "    spicetify backup apply"
fi
