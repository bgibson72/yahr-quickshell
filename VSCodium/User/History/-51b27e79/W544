#!/bin/bash
# Toggle app launcher widget
# Uses file-based IPC since Quickshell IPC calls don't work reliably

SOCKET="/tmp/quickshell-applauncher.sock"

# Create file briefly to signal toggle, then remove it
touch "$SOCKET"
sleep 0.2
rm -f "$SOCKET"
