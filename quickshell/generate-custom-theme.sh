#!/bin/bash
# generate-custom-theme.sh
# Generates ~/.config/hypr/themes/<Name>.conf and <Name>.lua from the 9
# user-editable colors exposed in the Settings widget's Theme tab (1
# background + 8 accents: blue, purple, pink, red, orange, yellow, green,
# teal). The other 6 named accent slots that exist in every theme file
# (rose, coral, maroon, cyan, sapphire, lavender) are aliased from these 8
# so the resulting file has the same complete shape every other theme's
# .conf/.lua has, and every other part of the pipeline (GTK sync, kitty,
# mako, wallpaper picker, etc.) keeps working unmodified for the Custom
# theme too.
#
# Also generates a matching fastfetch Arch-logo tinted with the palette's
# primary accent (blue), via ImageMagick, so `fastfetch` shows a logo in
# the new theme's color when it's active (matches the convention used by
# every other bundled theme's <name>_arch.png).
#
# Usage: generate-custom-theme.sh <bg> <blue> <purple> <pink> <red> <orange> <yellow> <green> <teal> [name]
# All colors are 6-digit hex, no '#' prefix. [name] defaults to "Custom"
# and is used as the theme's filename/display name (e.g. a "Save As" name).

THEMES_DIR="$HOME/.config/hypr/themes"
LOGOS_DIR="$HOME/.config/fastfetch/logos"
TEMPLATE_LOGO="$LOGOS_DIR/catppuccin_arch.png"
mkdir -p "$THEMES_DIR"

THEME_NAME="${10:-Custom}"

python3 - "$THEMES_DIR" "$THEME_NAME" "$@" << 'PYEOF'
import sys

themes_dir = sys.argv[1]
theme_name = sys.argv[2]
bg, blue, purple, pink, red, orange, yellow, green, teal = sys.argv[3:12]

def clamp(v):
    return max(0, min(255, int(round(v))))

def mix(hex_color, target, amount):
    """Mixes hex_color toward target (r,g,b) by amount (0-1)."""
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    tr, tg, tb = target
    r = clamp(r + (tr - r) * amount)
    g = clamp(g + (tg - g) * amount)
    b = clamp(b + (tb - b) * amount)
    return "{:02x}{:02x}{:02x}".format(r, g, b)

def darken(hex_color, amount):
    return mix(hex_color, (0, 0, 0), amount)

def lighten(hex_color, amount):
    return mix(hex_color, (255, 255, 255), amount)

bg_mantle = darken(bg, 0.15)
bg_crust = darken(bg, 0.30)
surface_0 = lighten(bg, 0.10)
surface_1 = lighten(bg, 0.20)
surface_2 = lighten(bg, 0.30)
border_0 = lighten(bg, 0.35)
border_1 = lighten(bg, 0.45)
border_2 = lighten(bg, 0.55)
fg_tertiary = lighten(bg, 0.65)
fg_secondary = lighten(bg, 0.78)
fg_primary = lighten(bg, 0.90)

a = {
    "rose": pink, "coral": red, "pink": pink, "purple": purple,
    "red": red, "maroon": red, "orange": orange, "yellow": yellow,
    "green": green, "teal": teal, "cyan": teal, "sapphire": blue,
    "blue": blue, "lavender": purple,
}

conf = """# ============================================
# {theme_name} Theme (user-defined)
# ============================================

# Accent colors
$accent-rose = rgb({rose})
$accent-roseAlpha = {rose}
$accent-coral = rgb({coral})
$accent-coralAlpha = {coral}
$accent-pink = rgb({pink})
$accent-pinkAlpha = {pink}
$accent-purple = rgb({purple})
$accent-purpleAlpha = {purple}
$accent-red = rgb({red})
$accent-redAlpha = {red}
$accent-maroon = rgb({maroon})
$accent-maroonAlpha = {maroon}
$accent-orange = rgb({orange})
$accent-orangeAlpha = {orange}
$accent-yellow = rgb({yellow})
$accent-yellowAlpha = {yellow}
$accent-green = rgb({green})
$accent-greenAlpha = {green}
$accent-teal = rgb({teal})
$accent-tealAlpha = {teal}
$accent-cyan = rgb({cyan})
$accent-cyanAlpha = {cyan}
$accent-sapphire = rgb({sapphire})
$accent-sapphireAlpha = {sapphire}
$accent-blue = rgb({blue})
$accent-blueAlpha = {blue}
$accent-lavender = rgb({lavender})
$accent-lavenderAlpha = {lavender}

# Text colors
$fg-primary = rgb({fg_primary})
$fg-primaryAlpha = {fg_primary}
$fg-secondary = rgb({fg_secondary})
$fg-secondaryAlpha = {fg_secondary}
$fg-tertiary = rgb({fg_tertiary})
$fg-tertiaryAlpha = {fg_tertiary}

# Border/Overlay colors
$border-2 = rgb({border_2})
$border-2Alpha = {border_2}
$border-1 = rgb({border_1})
$border-1Alpha = {border_1}
$border-0 = rgb({border_0})
$border-0Alpha = {border_0}

# Surface colors
$surface-2 = rgb({surface_2})
$surface-2Alpha = {surface_2}
$surface-1 = rgb({surface_1})
$surface-1Alpha = {surface_1}
$surface-0 = rgb({surface_0})
$surface-0Alpha = {surface_0}

# Background colors
$bg-base = rgb({bg})
$bg-baseAlpha = {bg}
$bg-mantle = rgb({bg_mantle})
$bg-mantleAlpha = {bg_mantle}
$bg-crust = rgb({bg_crust})
$bg-crustAlpha = {bg_crust}

# Glass border variables (35% accent / 10% white)
$glass-accent-rgba = rgba({blue}59)
""".format(bg=bg, bg_mantle=bg_mantle, bg_crust=bg_crust,
           surface_0=surface_0, surface_1=surface_1, surface_2=surface_2,
           border_0=border_0, border_1=border_1, border_2=border_2,
           fg_primary=fg_primary, fg_secondary=fg_secondary, fg_tertiary=fg_tertiary,
           theme_name=theme_name, **a)

lua = """-- ============================================
-- {theme_name} Theme (user-defined)
-- ============================================
return {{
    accent_rose     = "rgb({rose})",
    accent_coral    = "rgb({coral})",
    accent_pink     = "rgb({pink})",
    accent_purple   = "rgb({purple})",
    accent_red      = "rgb({red})",
    accent_maroon   = "rgb({maroon})",
    accent_orange   = "rgb({orange})",
    accent_yellow   = "rgb({yellow})",
    accent_green    = "rgb({green})",
    accent_teal     = "rgb({teal})",
    accent_cyan     = "rgb({cyan})",
    accent_sapphire = "rgb({sapphire})",
    accent_blue     = "rgb({blue})",
    accent_lavender = "rgb({lavender})",

    fg_primary   = "rgb({fg_primary})",
    fg_secondary = "rgb({fg_secondary})",
    fg_tertiary  = "rgb({fg_tertiary})",

    border_2 = "rgb({border_2})",
    border_1 = "rgb({border_1})",
    border_0 = "rgb({border_0})",

    surface_2 = "rgb({surface_2})",
    surface_1 = "rgb({surface_1})",
    surface_0 = "rgb({surface_0})",

    bg_base   = "rgb({bg})",
    bg_mantle = "rgb({bg_mantle})",
    bg_crust  = "rgb({bg_crust})",

    glass_accent = "rgba({blue}59)",
}}
""".format(bg=bg, bg_mantle=bg_mantle, bg_crust=bg_crust,
           surface_0=surface_0, surface_1=surface_1, surface_2=surface_2,
           border_0=border_0, border_1=border_1, border_2=border_2,
           fg_primary=fg_primary, fg_secondary=fg_secondary, fg_tertiary=fg_tertiary,
           theme_name=theme_name, **a)

with open(themes_dir + "/" + theme_name + ".conf", "w") as f:
    f.write(conf)
with open(themes_dir + "/" + theme_name + ".lua", "w") as f:
    f.write(lua)

print("ok")
PYEOF

# ── Generate a matching fastfetch Arch logo ──────────────────────────────────
# Every bundled theme has a <name>_arch.png (the Arch Linux logo tinted to
# that theme's primary accent color). Reproduce that here for the
# user-generated theme so `fastfetch` shows a matching logo when it's active.
# All bundled logos are the same silhouette; ImageMagick's -colorize fully
# replaces RGB while preserving the original alpha channel/anti-aliasing, so
# any existing logo works as the shape "template" regardless of its color.
BLUE_HEX="$2"
THEME_NAME_LOWER=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]')

if command -v magick &>/dev/null; then
    if [ -f "$TEMPLATE_LOGO" ]; then
        mkdir -p "$LOGOS_DIR"
        magick "$TEMPLATE_LOGO" -fill "#$BLUE_HEX" -colorize 100% \
            -define png:color-type=6 "$LOGOS_DIR/${THEME_NAME_LOWER}_arch.png"
        echo "Generated fastfetch logo: $LOGOS_DIR/${THEME_NAME_LOWER}_arch.png"
    else
        echo "Warning: template logo not found at $TEMPLATE_LOGO -- skipping fastfetch logo generation" >&2
    fi
else
    echo "Warning: ImageMagick ('magick') not found -- skipping fastfetch logo generation" >&2
fi
