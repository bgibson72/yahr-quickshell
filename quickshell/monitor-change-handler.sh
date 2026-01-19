#!/bin/bash
# Monitor change handler for quickshell
# Restarts quickshell when monitors are added, removed, or changed

LOG_FILE="/tmp/quickshell-monitor-handler.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

restart_quickshell() {
    log "Monitor change detected, restarting quickshell..."
    killall quickshell
    sleep 0.5
    quickshell &
    log "Quickshell restarted"
}

log "Monitor change handler started"

# Store initial monitor configuration
PREV_MONITORS=$(hyprctl monitors -j | jq -r 'map(.name) | sort | join(",")')

# Poll for monitor changes every 2 seconds
while true; do
    sleep 2
    CURRENT_MONITORS=$(hyprctl monitors -j | jq -r 'map(.name) | sort | join(",")')
    
    if [ "$PREV_MONITORS" != "$CURRENT_MONITORS" ]; then
        log "Monitor configuration changed: $PREV_MONITORS -> $CURRENT_MONITORS"
        restart_quickshell
        PREV_MONITORS="$CURRENT_MONITORS"
    fi
done
