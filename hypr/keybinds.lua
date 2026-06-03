-- =============================
-- Keybindings
-- =============================
-- Replaces: keybinds.conf + programs.conf
-- Includes: hypremoji keybind (was sourced from hypremoji.conf)

local MOD = "SUPER"

-- Application shortcuts (replaces programs.conf variables)
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "firefox"
local editor      = "nvim"
local menu        = "~/.config/quickshell/toggle-app-launcher"
local calendar    = "~/.config/quickshell/toggle-calendar"
local powermenu   = "~/.config/quickshell/toggle-power-menu"
local themeswitcher = "~/.config/quickshell/toggle-theme-switcher"

-- Core application launchers
hl.bind(MOD .. " + Return",      hl.dsp.exec_cmd(terminal))
hl.bind(MOD .. " + F",           hl.dsp.exec_cmd(fileManager))
hl.bind(MOD .. " + B",           hl.dsp.exec_cmd(browser))
hl.bind(MOD .. " + E",           hl.dsp.exec_cmd(editor))
hl.bind(MOD .. " + A",           hl.dsp.exec_cmd(menu))
hl.bind(MOD .. " + C",           hl.dsp.exec_cmd(calendar))
hl.bind(MOD .. " + Escape",      hl.dsp.exec_cmd(powermenu))
hl.bind(MOD .. " + T",           hl.dsp.exec_cmd(themeswitcher))

-- Window management
hl.bind(MOD .. " + Q",           hl.dsp.window.close())
hl.bind(MOD .. " + M",           hl.dsp.exit())
hl.bind(MOD .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(MOD .. " + P",           hl.dsp.window.pseudo())

-- Screenshots / UI toggles
hl.bind(MOD .. " + Print",       hl.dsp.exec_cmd("~/.config/quickshell/toggle-screenshot"))
hl.bind(MOD .. " + SHIFT + W",   hl.dsp.exec_cmd("~/.config/quickshell/wallpaper-picker"))
hl.bind(MOD .. " + SHIFT + S",   hl.dsp.exec_cmd("~/.config/quickshell/toggle-settings"))
hl.bind(MOD .. " + SHIFT + L",   hl.dsp.exec_cmd("~/.config/quickshell/preview-sddm.sh"))

-- Emoji picker (was sourced from hypremoji.conf)
hl.bind(MOD .. " + period",      hl.dsp.exec_cmd("hypremoji"))

-- Notification center (mako)
hl.bind(MOD .. " + N",           hl.dsp.exec_cmd("makoctl restore"))

-- Restart Quickshell
hl.bind(MOD .. " + Z",           hl.dsp.exec_cmd("~/.config/quickshell/restart-quickshell.sh"))

-- Focus movement
hl.bind(MOD .. " + left",        hl.dsp.focus({ direction = "left" }))
hl.bind(MOD .. " + right",       hl.dsp.focus({ direction = "right" }))
hl.bind(MOD .. " + up",          hl.dsp.focus({ direction = "up" }))
hl.bind(MOD .. " + down",        hl.dsp.focus({ direction = "down" }))

-- Workspace switching (1–9 and 10)
for i = 1, 9 do
    hl.bind(MOD .. " + " .. i,              hl.dsp.focus({ workspace = i }))
    hl.bind(MOD .. " + SHIFT + " .. i,      hl.dsp.window.move({ workspace = i }))
end
hl.bind(MOD .. " + 0",           hl.dsp.focus({ workspace = 10 }))
hl.bind(MOD .. " + SHIFT + 0",   hl.dsp.window.move({ workspace = 10 }))

-- Special workspace (scratchpad)
hl.bind(MOD .. " + S",           hl.dsp.workspace.toggle_special("magic"))
hl.bind(MOD .. " + SHIFT + S",   hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mouse wheel
hl.bind(MOD .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(MOD .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse drag
hl.bind(MOD .. " + mouse:272",   hl.dsp.window.drag(),   { mouse = true })
hl.bind(MOD .. " + mouse:273",   hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia: volume
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true, repeating = true })

-- Laptop multimedia: brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Laptop multimedia: media control (works on lock screen)
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Clamshell mode: disable/enable internal display when lid opens/closes
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable" && hyprctl keyword monitor "HDMI-A-1, 1920x1080@60, 0x0, 1"'),                                    { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1.5" && hyprctl keyword monitor "HDMI-A-1, 1920x1080@60, 1280x0, 1"'), { locked = true })
