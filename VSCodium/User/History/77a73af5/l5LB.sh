#!/bin/bash

# Screenshot helper script for Quickshell
# Arguments: mode delay saveToDisk copyToClipboard saveLocation

MODE="$1"
DELAY="$2"
SAVE_TO_DISK="$3"
COPY_TO_CLIPBOARD="$4"
SAVE_LOCATION="$5"

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

# Add delay for region mode (0.5s becomes 1s when DELAY is 0)
if [ "$MODE" = "region" ] && [ "$DELAY" = "0" ]; then
    DELAY=1
elif [ "$MODE" = "region" ]; then
    DELAY=$((DELAY + 1))
fi

# Add delay for window mode (1s when DELAY is 0, otherwise add 1)
if [ "$MODE" = "window" ] && [ "$DELAY" = "0" ]; then
    DELAY=1
elif [ "$MODE" = "window" ]; then
    DELAY=$((DELAY + 1))
fi

# Execute with delay if needed
if [ "$DELAY" != "0" ] && [ -n "$DELAY" ]; then
    sleep "$DELAY"
fi

# Execute command directly - it will inherit our environment
exec $CMD
