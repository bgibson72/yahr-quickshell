#!/bin/bash

# Screenshot helper script for Quickshell
# Arguments: mode delay saveToDisk copyToClipboard saveLocation

MODE="$1"
DELAY="$2"
SAVE_TO_DISK="$3"
COPY_TO_CLIPBOARD="$4"
SAVE_LOCATION="$5"

echo "Screenshot script called:"
echo "  Mode: $MODE"
echo "  Delay: $DELAY"
echo "  Save to disk: $SAVE_TO_DISK"
echo "  Copy to clipboard: $COPY_TO_CLIPBOARD"
echo "  Save location: $SAVE_LOCATION"

# Apply delay if specified
if [ "$DELAY" != "0" ] && [ -n "$DELAY" ]; then
    echo "Waiting ${DELAY} seconds..."
    sleep "$DELAY"
fi

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

echo "Executing: $CMD"

# Execute command and capture output
OUTPUT=$($CMD 2>&1)
EXIT_CODE=$?

# Check if screenshot was successful
if [ $EXIT_CODE -eq 0 ]; then
    # Extract filename from output if present
    FILENAME=$(echo "$OUTPUT" | grep -oP '(?<=saved to ).*' | head -1)
    
    if [ -n "$FILENAME" ]; then
        # Get just the filename without path
        BASENAME=$(basename "$FILENAME")
        
        # Send custom notification with better title
        if [ "$MODE" = "region" ]; then
            MODE_TEXT="Region Screenshot"
        elif [ "$MODE" = "window" ]; then
            MODE_TEXT="Window Screenshot"
        elif [ "$MODE" = "output" ]; then
            MODE_TEXT="Screen Screenshot"
        else
            MODE_TEXT="Screenshot"
        fi
        
        # Send notification
        notify-send "$MODE_TEXT" "Saved as: $BASENAME\nLocation: $(dirname "$FILENAME")" \
            --icon=camera-photo \
            --app-name="Screenshot" \
            --urgency=low
    fi
else
    # Screenshot failed
    notify-send "Screenshot Failed" "An error occurred while taking the screenshot" \
        --icon=dialog-error \
        --app-name="Screenshot" \
        --urgency=critical
fi

exit $EXIT_CODE
