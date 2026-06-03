-- ======================
-- Input Configuration
-- ======================
-- Replaces: input.conf

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- 3-finger swipe gesture: switch workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device sensitivity override
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
