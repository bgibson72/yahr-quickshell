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

def apply_border_alpha(border_alpha):
    """Window border color is a structured Lua-table gradient (see
    hypr/appearance.lua's col.active_border/inactive_border) baked into the
    on-disk config, not a plain hl.config-settable value -- confirmed that
    `hyprctl eval` DOES update the stored option (hyprctl getoption reflects
    it) but Hyprland never actually repaints existing window borders with
    it; only a full `hyprctl reload` (re-reading the Lua files from disk)
    forces a real visual refresh. So this patches the live Lua files
    in place (regex-matched by pattern, not by the original literal alpha,
    so it stays idempotent across repeated changes) and reloads, BEFORE the
    rest of this script's eval-based settings run (which apply fine live
    without a reload and must come after, or the reload would revert them
    to their file defaults)."""
    scale = (border_alpha / 100) * (255 / 0x59)
    def hexa(base):
        return format(max(0, min(255, round(base * scale))), "02x")
    a_black, a_accent, a_white = hexa(0x40), hexa(0x59), hexa(0x26)
    i_black, i_white = hexa(0x1a), hexa(0x12)

    try:
        appearance_path = os.path.expanduser("~/.config/hypr/appearance.lua")
        with open(appearance_path) as f:
            lines = f.readlines()
        out = []
        for line in lines:
            if "inactive_border" in line:
                line = re.sub(r"rgba\(000000[0-9a-fA-F]{2}\)", "rgba(000000" + i_black + ")", line)
                line = re.sub(r"rgba\(ffffff[0-9a-fA-F]{2}\)", "rgba(ffffff" + i_white + ")", line)
            elif "active_border" in line:
                line = re.sub(r"rgba\(000000[0-9a-fA-F]{2}\)", "rgba(000000" + a_black + ")", line)
                line = re.sub(r"rgba\(ffffff[0-9a-fA-F]{2}\)", "rgba(ffffff" + a_white + ")", line)
            out.append(line)
        with open(appearance_path, "w") as f:
            f.writelines(out)
    except Exception:
        pass

    try:
        theme_name = open(os.path.expanduser("~/.config/hypr/.current-theme")).read().strip()
        theme_lua = os.path.expanduser("~/.config/hypr/themes/" + theme_name + ".lua")
        with open(theme_lua) as f:
            tcontent = f.read()
        tcontent = re.sub(
            r'(glass_accent\s*=\s*"rgba\([0-9a-fA-F]{6})[0-9a-fA-F]{2}(\)")',
            lambda m: m.group(1) + a_accent + m.group(2),
            tcontent)
        with open(theme_lua, "w") as f:
            f.write(tcontent)
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
    if "borderAlpha" in h:
        apply_border_alpha(h["borderAlpha"])

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
