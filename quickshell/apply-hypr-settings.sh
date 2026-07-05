#!/bin/bash
# apply-hypr-settings.sh
# Re-applies user Hyprland appearance preferences from settings.json.
# Called after hyprctl reload (theme change) and at login via autostart.
# This ensures blur, shadow, animations, gaps, rounding, and border size
# survive theme switches and reboots.

SETTINGS_FILE="$HOME/.config/quickshell/settings.json"
[ -f "$SETTINGS_FILE" ] || exit 0

python3 - "$SETTINGS_FILE" << 'PYEOF'
import json, os, subprocess, sys

def ev(expr):
    subprocess.run(["hyprctl", "eval", expr], capture_output=True)

def current_accent_rgb():
    """Reads the active theme's accent-blue color (e.g. "7aa2f7") from
    ~/.config/hypr/themes/<Name>.conf, where <Name> comes from
    ~/.config/hypr/.current-theme. Falls back to black on any failure."""
    try:
        theme_name = open(os.path.expanduser("~/.config/hypr/.current-theme")).read().strip()
        theme_conf = os.path.expanduser("~/.config/hypr/themes/" + theme_name + ".conf")
        with open(theme_conf) as tf:
            for line in tf:
                if line.strip().startswith("$accent-blue"):
                    return line.split("rgb(")[1].split(")")[0]
    except Exception:
        pass
    return "000000"

try:
    with open(sys.argv[1]) as f:
        s = json.load(f)
    h = s.get("hypr", {})
    g = s.get("general", {})

    if "borderSize" in h:
        ev("hl.config({general={border_size=" + str(int(h["borderSize"])) + "}})")
    if "rounding" in h:
        ev("hl.config({decoration={rounding=" + str(int(h["rounding"])) + "}})")
    if "gapsIn" in h:
        ev("hl.config({general={gaps_in=" + str(int(h["gapsIn"])) + "}})")
    if "gapsOut" in h:
        ev("hl.config({general={gaps_out=" + str(int(h["gapsOut"])) + "}})")
    if "animations" in h:
        v = "true" if h["animations"] else "false"
        ev("hl.config({animations={enabled=" + v + "}})")
    if "shadow" in h:
        v = "true" if h["shadow"] else "false"
        ev("hl.config({decoration={shadow={enabled=" + v + "}}})")
    if "blur" in h:
        v = "true" if h["blur"] else "false"
        ev("hl.config({decoration={blur={enabled=" + v + "}}})")
        # Also control layer-specific blur so quickshell/mako respect the setting
        ev("hl.layer_rule({match={namespace='^quickshell'}, blur=" + v + "})")
        ev("hl.layer_rule({match={namespace='^mako'}, blur=" + v + "})")
    if "blurSize" in h:
        ev("hl.config({decoration={blur={size=" + str(int(h["blurSize"])) + "}}})")
    if "shadowRange" in h:
        ev("hl.config({decoration={shadow={range=" + str(int(h["shadowRange"])) + "}}})")
    if "shadowAlpha" in h:
        rgb = current_accent_rgb() if h.get("shadowUseAccent", False) else "000000"
        alpha_hex = format(round(h["shadowAlpha"] / 100 * 255), "02x")
        ev('hl.config({decoration={shadow={color="rgba(' + rgb + alpha_hex + ')"}}})')
    if "borderAlpha" in h:
        # Window border is a structured 3/2-stop gradient (see
        # hypr/appearance.lua's col.active_border/inactive_border), not a
        # plain color string -- hl.config needs the nested
        # {colors={...}, angle=N} table form for gradient variables.
        accent = current_accent_rgb()
        scale = (h["borderAlpha"] / 100) * (255 / 0x59)
        def hexa(base):
            return format(max(0, min(255, round(base * scale))), "02x")
        active_colors = ('{"rgba(000000' + hexa(0x40) + ')","rgba(' + accent + hexa(0x59)
            + ')","rgba(ffffff' + hexa(0x26) + ')"}')
        inactive_colors = '{"rgba(000000' + hexa(0x1a) + ')","rgba(ffffff' + hexa(0x12) + ')"}'
        ev('hl.config({general={col={active_border={colors=' + active_colors + ',angle=45},'
            + 'inactive_border={colors=' + inactive_colors + ',angle=45}}}})')

    # App window transparency (kitty, thunar, code)
    if "appWindowTransparent" in g:
        active_op   = "0.92" if g["appWindowTransparent"] else "1.0"
        inactive_op = "0.88" if g["appWindowTransparent"] else "1.0"
        for cls in ["kitty", "thunar", "code"]:
            ev("hl.window_rule({ match = { class = '^" + cls + "$' }, opacity = '"
               + active_op + " override " + inactive_op + " override' })")
except Exception as e:
    print("apply-hypr-settings: " + str(e), file=sys.stderr)
    sys.exit(1)
PYEOF
