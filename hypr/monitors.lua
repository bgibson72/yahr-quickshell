-- ======================
-- Monitor Configuration
-- ======================
-- Replaces: monitors.conf
--
-- Auto-detect all connected monitors. Add explicit entries below
-- if you want to set a specific resolution, refresh rate, or position.
-- Examples (uncomment and edit as needed):
--   hl.monitor({ output = "eDP-1",     mode = "1920x1080@144", position = "0x0",      scale = 1.5   })
--   hl.monitor({ output = "HDMI-A-1",  mode = "1920x1080@60",  position = "1280x0",   scale = 1     })
--   hl.monitor({ output = "DP-1",      mode = "2560x1440@165", position = "0x0",      scale = 1     })

hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "auto", scale = 1 })
