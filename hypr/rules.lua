-- =============================
-- Window & Layer Rules
-- =============================
-- Replaces: rules.conf
-- Includes: hypremoji window rules (were sourced from hypremoji.conf)

-- ── Floating windows ────────────────────────────────────────────────
hl.window_rule({ match = { title = "^(.*Hyprshot.*)$"                }, float = true })
hl.window_rule({ match = { title = "^(.*Waypaper.*)$"                }, float = true })

-- pavucontrol (two class names used by different distros/versions)
hl.window_rule({ match = { class = "^(org%.pulseaudio%.pavucontrol)$" }, float = true, center = true, size = { 800, 600 } })
hl.window_rule({ match = { class = "^(pavucontrol)$"                  }, float = true, center = true, size = { 800, 600 } })

-- Bluetooth manager (two class names)
hl.window_rule({ match = { class = "^(blueman-manager)$"             }, float = true, center = true, size = { 800, 600 } })
hl.window_rule({ match = { class = "^(%.blueman-manager-wrapped)$"   }, float = true, center = true, size = { 800, 600 } })

-- Network manager TUI
hl.window_rule({ match = { class = "^(kitty-nmtui)$"                 }, float = true, center = true, size = { 800, 600 } })

-- Power manager settings
hl.window_rule({ match = { class = "^(xfce4-power-manager-settings)$"}, float = true, center = true, size = { 800, 600 } })

-- HyprEmoji picker (was sourced from hypremoji.conf)
hl.window_rule({ match = { title = "^(HyprEmoji)$"                   }, float = true, center = true, size = { 800, 600 } })

-- Pluck color picker
hl.window_rule({ match = { title = "^(Pluck - Color Palette Extractor)$" }, float = true, center = true })

-- ── Opacity ─────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^thunar$" }, opacity = "0.92 override 0.88 override" })
hl.window_rule({ match = { class = "^code$"   }, opacity = "0.92 override 0.88 override" })

-- ── Fullscreen / maximized ──────────────────────────────────────────
hl.window_rule({ match = { class = "^(feh)$"              }, fullscreen = true })

-- SDDM greeter test mode
hl.window_rule({ match = { class = "^(sddm-greeter-qt6)$" }, float = true, maximize = true })

-- ── Quickshell floating widgets ─────────────────────────────────────
-- Match floating Quickshell popup windows (calendar, settings, etc.)
hl.window_rule({ match = { class = "^(quickshell)$", float = true }, size = { 480, 460 } })
hl.window_rule({ match = { class = "^(quickshell)$", float = true }, move = "50% 50"    })
hl.window_rule({ match = { class = "^(quickshell)$", float = true }, animation = "slide" })

-- ── Layer rules ──────────────────────────────────────────────────────
-- Background blur for shell and notification layers
hl.layer_rule({ match = { namespace = "^quickshell" }, blur = true })
hl.layer_rule({ match = { namespace = "^mako"       }, blur = true })

-- ── Global rules ─────────────────────────────────────────────────────
-- Suppress maximize requests from all apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix XWayland drag-and-drop focus stealing
hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
