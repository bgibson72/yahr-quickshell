#!/bin/bash

# Screenshot helper script for Quickshell
# Arguments: mode delay saveToDisk copyToClipboard saveLocation

# Ensure proper environment for Wayland
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-Hyprland}"

MODE="$1"
DELAY="$2"
SAVE_TO_DISK="$3"
COPY_TO_CLIPBOARD="$4"
SAVE_LOCATION="$5"

echo "[Screenshot] Mode: $MODE, Delay: $DELAY, Save: $SAVE_TO_DISK, Copy: $COPY_TO_CLIPBOARD, Location: $SAVE_LOCATION" >> /tmp/quickshell-screenshot.log
echo "[Screenshot] Environment: WAYLAND_DISPLAY=$WAYLAND_DISPLAY, XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP" >> /tmp/quickshell-screenshot.log

# Build hyprshot command
CMD="hyprshot -m $MODE"

# Add output folder if saving to disk
if [ "$SAVE_TO_DISK" = "true" ]; then
    CMD="$CMD -o $SAVE_LOCATION"
fi

# Add clipboard-only flag if only copying (not saving)
if [ "$SAVE_TO_DISK" = "false" ] && [ "$COPY_TO_CLIPBOARD" = "true" ]; then
    CMD="$CMD --clipboard-only"
fi

# Add delay for region mode
if [ "$MODE" = "region" ]; then
    DELAY=$(echo "$DELAY + 0.5" | bc)
fi

# Add delay for window mode to ensure widget closes and focus returns
if [ "$MODE" = "window" ]; then
    DELAY=$(echo "$DELAY + 1.0" | bc)
fi

# Execute with delay if needed
if [ "$DELAY" != "0" ] && [ -n "$DELAY" ]; then
    echo "[Screenshot] Executing with delay: sleep $DELAY && $CMD" >> /tmp/quickshell-screenshot.log
    nohup sh -c "sleep $DELAY && $CMD" >/dev/null 2>&1 </dev/null &
else
    echo "[Screenshot] Executing: $CMD" >> /tmp/quickshell-screenshot.log
    nohup sh -c "$CMD" >/dev/null 2>&1 </dev/null &
fi

echo "[Screenshot] Process launched in background with PID $!" >> /tmp/quickshell-screenshot.log
exit 0
