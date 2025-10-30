#!/bin/bash

# Screenshot helper script for Quickshell
# Arguments: mode delay saveToDisk copyToClipboard saveLocation

MODE="$1"
DELAY="$2"
SAVE_TO_DISK="$3"
COPY_TO_CLIPBOARD="$4"
SAVE_LOCATION="$5"

echo "[Screenshot] Mode: $MODE, Delay: $DELAY, Save: $SAVE_TO_DISK, Copy: $COPY_TO_CLIPBOARD, Location: $SAVE_LOCATION" >> /tmp/quickshell-screenshot.log

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

# Execute with delay if needed
if [ "$DELAY" != "0" ] && [ -n "$DELAY" ]; then
    echo "[Screenshot] Executing with delay: sleep $DELAY && $CMD" >> /tmp/quickshell-screenshot.log
    sleep "$DELAY"
    $CMD >> /tmp/quickshell-screenshot.log 2>&1
else
    echo "[Screenshot] Executing: $CMD" >> /tmp/quickshell-screenshot.log
    $CMD >> /tmp/quickshell-screenshot.log 2>&1
fi

echo "[Screenshot] Command completed with exit code: $?" >> /tmp/quickshell-screenshot.log
