#!/bin/bash
# Quickshell widget toggle script

WIDGET="$1"
SOCKET="/tmp/quickshell-widget-${WIDGET}.sock"

# Send toggle signal via simple file-based IPC
if [ -f "$SOCKET" ]; then
    rm "$SOCKET"
else
    touch "$SOCKET"
fi
