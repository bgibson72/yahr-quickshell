#!/bin/bash
# Consolidated IPC watcher for Quickshell
# Watches multiple socket files efficiently using inotify

# Use inotifywait if available (more efficient), otherwise fall back to polling
if command -v inotifywait &> /dev/null; then
    # Efficient inotify-based watching
    while true; do
        # Wait for any of the socket files to be created
        inotifywait -qq -e create -e moved_to /tmp/ 2>/dev/null | while read -r path action file; do
            case "$file" in
                quickshell-themeswitcher.sock)
                    echo "themeswitcher:toggle"
                    ;;
                quickshell-applauncher.sock)
                    echo "applauncher:toggle"
                    ;;
                quickshell-calendar.sock)
                    echo "calendar:toggle"
                    ;;
                quickshell-powermenu.sock)
                    echo "powermenu:toggle"
                    ;;
                quickshell-screenshot.sock)
                    echo "screenshot:toggle"
                    ;;
                quickshell-settings.sock)
                    echo "settings:toggle"
                    ;;
                quickshell-clipboard.sock)
                    echo "clipboard:toggle"
                    ;;
            esac
        done
    done
else
    # Fallback: Optimized polling with single loop
    while true; do
        for sock in themeswitcher applauncher calendar powermenu screenshot settings clipboard; do
            file="/tmp/quickshell-${sock}.sock"
            if [ -f "$file" ]; then
                echo "${sock}:toggle"
                # Wait for file to be removed
                while [ -f "$file" ]; do
                    sleep 0.05
                done
            fi
        done
        sleep 0.1
    done
fi
