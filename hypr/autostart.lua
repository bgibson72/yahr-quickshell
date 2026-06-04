-- ======================
-- Autostart Programs
-- ======================
-- Replaces: autostart.conf

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("sleep 0.25 && awww-daemon")
    hl.exec_cmd("sleep 0.25 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("sleep 1.5 && bash -c 'wp=$(cat ~/.config/quickshell/last-wallpaper 2>/dev/null); [ -n \"$wp\" ] && [ -f \"$wp\" ] && awww img \"$wp\"'")
    hl.exec_cmd("sleep 0.5 && mako")
    hl.exec_cmd("sleep 0.5 && hypridle")
    hl.exec_cmd("sleep 1 && wl-paste --watch cliphist store")
    hl.exec_cmd("sleep 1 && ~/.config/quickshell/monitor-change-handler.sh")
    -- Re-apply user Hyprland appearance settings (overrides theme defaults)
    hl.exec_cmd("sleep 2 && bash ~/.config/quickshell/apply-hypr-settings.sh")
end)
