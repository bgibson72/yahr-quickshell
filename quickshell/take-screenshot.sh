#!/bin/bash

# Screenshot helper script for Quickshell
# Arguments: mode delay saveToDisk copyToClipboard saveLocation

MODE="$1"
DELAY="$2"
SAVE_TO_DISK="$3"
COPY_TO_CLIPBOARD="$4"
SAVE_LOCATION="$5"

# Expand tilde in save location
SAVE_LOCATION="${SAVE_LOCATION/#\~/$HOME}"

echo "Screenshot script called:"
echo "  Mode: $MODE"
echo "  Delay: $DELAY"
echo "  Save to disk: $SAVE_TO_DISK"
echo "  Copy to clipboard: $COPY_TO_CLIPBOARD"
echo "  Save location: $SAVE_LOCATION"

# Give the widget time to close (important for region/window selection to work)
sleep 0.2

# Apply delay if specified
if [ "$DELAY" != "0" ] && [ -n "$DELAY" ]; then
    echo "Waiting ${DELAY} seconds..."
    sleep "$DELAY"
fi

# Build hyprshot command (without --silent so mako notifications work)
CMD="hyprshot -m $MODE"

# Add output folder if saving to disk
if [ "$SAVE_TO_DISK" = "true" ]; then
    CMD="$CMD -o $SAVE_LOCATION"
fi

# Add clipboard-only flag if only copying (not saving)
if [ "$SAVE_TO_DISK" = "false" ] && [ "$COPY_TO_CLIPBOARD" = "true" ]; then
    CMD="$CMD --clipboard-only"
fi

echo "Executing: $CMD"

# Execute command - hyprshot will handle notifications via mako
exec $CMD
