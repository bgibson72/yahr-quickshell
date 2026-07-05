#!/bin/bash
# apply-hypr-settings.sh
# Re-applies user Hyprland appearance preferences from settings.json.
# Called after hyprctl reload (theme change) and at login via autostart.
# This ensures blur, shadow, animations, gaps, rounding, and border size
# survive theme switches and reboots.

SETTINGS_FILE="$HOME/.config/quickshell/settings.json"
[ -f "$SETTINGS_FILE" ] || exit 0

python3 - "$SETTINGS_FILE" << 'PYEOF'
import json, os, re, subprocess, sys

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

def current_border0_rgb():
    """Reads the active theme's neutral border-0 color (e.g. "565f89"),
    used for the inactive-window border in solid-accent mode. Falls back
    to a mid-gray on any failure."""
    try:
        theme_name = open(os.path.expanduser("~/.config/hypr/.current-theme")).read().strip()
        theme_conf = os.path.expanduser("~/.config/hypr/themes/" + theme_name + ".conf")
        with open(theme_conf) as tf:
            for line in tf:
                if line.strip().startswith("$border-0"):
                    return line.split("rgb(")[1].split(")")[0]
    except Exception:
        pass
    return "6c7086"

def apply_border_gradient(transparency_pct, angle_deg, solid_accent):
    """Window border color/angle is a structured Lua-table gradient (see
    hypr/appearance.lua's col.active_border/inactive_border) baked into the
    on-disk config, not a plain hl.config-settable value -- confirmed that
    `hyprctl eval` DOES update the stored option (hyprctl getoption reflects
    it) but Hyprland never actually repaints existing window borders with
    it; only a full `hyprctl reload` (re-reading the Lua files from disk)
    forces a real visual refresh. So this patches the live Lua files
    in place and reloads, BEFORE the rest of this script's eval-based
    settings run (which apply fine live without a reload and must come
    after, or the reload would revert them to their file defaults).

    transparency_pct: 0 = fully solid/opaque border, 100 = fully invisible
    (the inverse of opacity -- converted to opacity here for the actual
    alpha-byte math, since that's what the color stops represent).

    solid_accent: when true, use a single solid theme-accent color all the
    way around the active window's border (and the neutral border-0 color,
    dimmer, for inactive windows) instead of the black/accent/white glass
    gradient -- this used to be the default before the Lua config migration
    (see the pre-migration hyprland-backup conf: col.active_border =
    $accent-blue, col.inactive_border = $border-0).

    The entire `colors = { ... }` array is replaced wholesale (not just
    alpha bytes within fixed-position stops), since solid mode has a
    different number of stops than gradient mode -- this also means the
    replacement is idempotent regardless of which mode/values were
    previously written, and always uses the CURRENT theme's accent (so
    switching themes doesn't leave a stale color baked in from before)."""
    opacity_pct = 100 - transparency_pct

    def alpha_byte(pct):
        return format(max(0, min(255, round(pct / 100 * 255))), "02x")

    accent = current_accent_rgb()

    if solid_accent:
        active_a = alpha_byte(opacity_pct)
        inactive_a = alpha_byte(opacity_pct * 0.5)
        active_colors = '{ "rgba(' + accent + active_a + ')" }'
        inactive_colors = '{ "rgba(' + current_border0_rgb() + inactive_a + ')" }'
    else:
        scale = (opacity_pct / 100) * (255 / 0x59)
        def hexa(base):
            return format(max(0, min(255, round(base * scale))), "02x")
        active_colors = ('{ "rgba(000000' + hexa(0x40) + ')", "rgba(' + accent + hexa(0x59)
            + ')", "rgba(ffffff' + hexa(0x26) + ')" }')
        inactive_colors = '{ "rgba(000000' + hexa(0x1a) + ')", "rgba(ffffff' + hexa(0x12) + ')" }'

    try:
        appearance_path = os.path.expanduser("~/.config/hypr/appearance.lua")
        with open(appearance_path) as f:
            lines = f.readlines()
        out = []
        for line in lines:
            if "inactive_border" in line:
                line = re.sub(r"colors\s*=\s*\{[^}]*\}", "colors = " + inactive_colors, line)
                line = re.sub(r"angle\s*=\s*\d+", "angle = " + str(int(angle_deg)), line)
            elif "active_border" in line:
                line = re.sub(r"colors\s*=\s*\{[^}]*\}", "colors = " + active_colors, line)
                line = re.sub(r"angle\s*=\s*\d+", "angle = " + str(int(angle_deg)), line)
            out.append(line)
        with open(appearance_path, "w") as f:
            f.writelines(out)
    except Exception:
        pass

    subprocess.run(["hyprctl", "reload"], capture_output=True)

try:
    with open(sys.argv[1]) as f:
        s = json.load(f)
    h = s.get("hypr", {})
    g = s.get("general", {})

    # Must run first -- writes files + reloads, which would otherwise wipe
    # out the eval-based settings applied below.
    if "borderTransparency" in h or "borderAngle" in h or "borderSolidAccent" in h:
        apply_border_gradient(h.get("borderTransparency", 65), h.get("borderAngle", 45),
            h.get("borderSolidAccent", False))

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
