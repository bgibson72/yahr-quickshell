-- ============================================================
-- YAHR – Yet Another Hyprland Rice
-- Main Hyprland configuration (Lua, requires Hyprland ≥ 0.55)
-- ============================================================
--
-- Theme switching:  write a theme name to ~/.config/hypr/.current-theme
--                   then run `hyprctl reload`  (switch-theme.sh does this)
--
-- Available themes: Catppuccin  Dracula  Eldritch  Everforest  Gruvbox
--                   Kanagawa  Material  Monochrome  NightFox  Nord
--                   RosePine  Solarized  TokyoNight

-- ── Read active theme ────────────────────────────────────────────────
local home = os.getenv("HOME")

local function trim(s)
    return s and s:match("^%s*(.-)%s*$") or s
end

local function readFirstLine(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local line = f:read("*l")
    f:close()
    return trim(line)
end

local themeName = readFirstLine(home .. "/.config/hypr/.current-theme") or "Catppuccin"

-- Load theme with fallback to Catppuccin if the name is invalid
local ok, theme = pcall(require, "themes." .. themeName)
if not ok then
    theme = require("themes.Catppuccin")
end

-- Expose theme globally so appearance.lua can access it
_G.HYPR_THEME = theme

-- ── Load configuration modules ────────────────────────────────────────
require("variables")    -- env vars (replaces variables.conf)
require("monitors")     -- monitor layout (replaces monitors.conf)
require("autostart")    -- exec-once (replaces autostart.conf)
require("appearance")   -- decoration, animations, layout (replaces look-and-feel.conf)
require("input")        -- keyboard, mouse, touchpad (replaces input.conf)
require("keybinds")     -- binds + app launchers (replaces keybinds.conf + programs.conf)
require("rules")        -- window/layer rules (replaces rules.conf + hypremoji.conf)
