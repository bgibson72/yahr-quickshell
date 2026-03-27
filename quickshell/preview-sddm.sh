#!/bin/bash
# Preview SDDM theme in test mode without logging out.
# Launches the greeter in a window on the current session, then auto-takes
# a screenshot after it finishes rendering.
#
# Keybind: Super+Shift+L  (configured in hypr/keybinds.conf)
# Screenshot saved to: ~/Pictures/Screenshots/sddm-preview-<timestamp>.png

SDDM_THEME="/usr/share/sddm/themes/yahr-theme"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Verify the theme directory exists
if [[ ! -d "$SDDM_THEME" ]]; then
    notify-send "SDDM Preview" "Theme not found: $SDDM_THEME" --urgency=critical
    exit 1
fi

# Verify the greeter binary exists
if ! command -v sddm-greeter-qt6 &>/dev/null; then
    notify-send "SDDM Preview" "sddm-greeter-qt6 not found – is SDDM installed?" --urgency=critical
    exit 1
fi

notify-send "SDDM Preview" "Launching login screen preview…"

# Launch greeter in test mode (runs as a regular window on the current session)
sddm-greeter-qt6 --test-mode --theme "$SDDM_THEME" &
GREETER_PID=$!

# Wait for the window to fully render before screenshotting
sleep 3

# Take a full-screen screenshot with grim
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCREENSHOT_FILE="$SCREENSHOT_DIR/sddm-preview-$TIMESTAMP.png"

if grim "$SCREENSHOT_FILE" 2>/dev/null; then
    # Copy to clipboard if wl-copy is available
    wl-copy < "$SCREENSHOT_FILE" 2>/dev/null || true
    notify-send "SDDM Preview" "Screenshot saved to:\n$SCREENSHOT_FILE" --icon=camera-photo
else
    notify-send "SDDM Preview" "Screenshot failed – grim returned an error" --urgency=normal
fi
