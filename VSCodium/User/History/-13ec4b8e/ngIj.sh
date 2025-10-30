#!/bin/bash
# Mako notification controls - helper script

case "$1" in
    dismiss|d)
        makoctl dismiss
        echo "All notifications dismissed"
        ;;
    restore|r)
        makoctl restore
        echo "Last notification restored"
        ;;
    dnd-on)
        makoctl mode -a dnd
        echo "Do Not Disturb enabled"
        ;;
    dnd-off)
        makoctl mode -r dnd
        echo "Do Not Disturb disabled"
        ;;
    reload)
        makoctl reload
        echo "Mako configuration reloaded"
        ;;
    list|l)
        makoctl list
        ;;
    history|h)
        makoctl history
        ;;
    test)
        notify-send "Mako Test" "This is a test notification from mako" -u normal
        ;;
    *)
        echo "Mako Notification Control"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  dismiss, d      - Dismiss all notifications"
        echo "  restore, r      - Restore last dismissed notification"
        echo "  dnd-on          - Enable Do Not Disturb mode"
        echo "  dnd-off         - Disable Do Not Disturb mode"
        echo "  reload          - Reload mako configuration"
        echo "  list, l         - List current notifications"
        echo "  history, h      - Show notification history"
        echo "  test            - Send a test notification"
        echo ""
        ;;
esac
