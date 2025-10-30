import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var notifications: []
    property bool dndEnabled: false
    property var activePopups: []
    
    // Persistence
    property string storageFile: `${Qt.platform.os === "linux" ? 
        (Quickshell.env("XDG_STATE_HOME") || `${Quickshell.env("HOME")}/.local/state`) : 
        Quickshell.env("HOME")}/.local/state/quickshell/notifications.json`
    
    // Save timer to batch writes
    Timer {
        id: saveTimer
        interval: 500
        onTriggered: saveNotifications()
    }

    onNotificationsChanged: {
        console.log("🔔 Notifications array changed, count:", notifications.length)
        saveTimer.restart()
    }
    
    onDndEnabledChanged: {
        saveTimer.restart()
    }

    NotificationServer {
        id: server
        
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            console.log("📩 Received notification:", notif.summary, "from", notif.appName)
            
            notif.tracked = true

            // Process summary and body for better display
            let summary = notif.summary || ""
            let body = notif.body || ""
            
            // Handle screenshot notifications with long file paths
            if (notif.appName === "Hyprshot" || summary.includes("Screenshot saved") || summary.includes("/Pictures/Screenshots/")) {
                // Extract filename from path if present
                const pathMatch = summary.match(/(?:~\/|\/home\/[^\/]+\/)(.+)/)
                if (pathMatch) {
                    const fullPath = pathMatch[0]
                    const fileName = fullPath.split('/').pop()
                    const dirPath = fullPath.substring(0, fullPath.lastIndexOf('/'))
                    
                    // Set cleaner title based on context
                    summary = "Screenshot Saved"
                    body = `File: ${fileName}\nLocation: ${dirPath}`
                }
            }

            const wrapper = {
                notification: notif,
                id: notif.id,
                summary: summary,
                body: body,
                appName: notif.appName || "Notification",
                appIcon: notif.appIcon || "",
                urgency: notif.urgency || 1,
                time: new Date().toISOString(),
                timestamp: Date.now(),
                closed: false,
                actions: notif.actions ? notif.actions.map(a => ({
                    identifier: a.identifier,
                    text: a.text,
                    invoke: () => a.invoke()
                })) : [],
                
                close: function() {
                    console.log("🔒 Closing notification wrapper:", this.id)
                    this.closed = true
                    if (this.notification && !this.notification.closed) {
                        this.notification.dismiss()
                    }
                }
            }

            root.notifications = [wrapper, ...root.notifications]
            console.log("📊 Total notifications:", root.notifications.length)
            
            // Show popup if not in DND mode
            if (!root.dndEnabled) {
                root.showPopup(wrapper)
            }
        }
    }

    function dismissNotification(notifId) {
        console.log("🗑️ Dismissing notification:", notifId)
        const notif = notifications.find(n => n.id === notifId)
        if (notif) {
            // Try to dismiss the underlying notification object if it exists
            try {
                if (notif.notification && typeof notif.notification.dismiss === 'function') {
                    notif.notification.dismiss()
                }
            } catch (e) {
                console.log("⚠️ Could not dismiss notification object:", e)
            }
            // Filter out the notification and assign to trigger property change
            notifications = notifications.filter(n => n.id !== notifId)
            console.log("✅ Notification dismissed. Remaining:", notifications.length)
        } else {
            console.log("⚠️ Notification not found:", notifId)
        }
    }

    function clearAllNotifications() {
        console.log("🗑️ Clearing all notifications, count:", notifications.length)
        // Dismiss all active notifications
        for (let i = 0; i < notifications.length; i++) {
            try {
                if (notifications[i].notification && typeof notifications[i].notification.dismiss === 'function') {
                    notifications[i].notification.dismiss()
                }
            } catch (e) {
                console.log("⚠️ Could not dismiss notification:", e)
            }
        }
        // Clear the array
        notifications = []
        console.log("✅ All notifications cleared")
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled
        console.log("DND mode:", dndEnabled ? "enabled" : "disabled")
    }
    
    function showPopup(notification) {
        // Popups will be created by shell.qml in a separate layer
        console.log("💬 Popup requested for:", notification.summary)
    }
    
    function saveNotifications() {
        // TODO: Implement proper file-based persistence
        // For now, just log
        console.log("💾 Would save", notifications.length, "notifications")
    }
    
    function loadNotifications() {
        // TODO: Implement proper file loading
        console.log("📂 Would load notifications")
    }

    Component.onCompleted: {
        console.log("✅ NotificationService initialized")
        loadNotifications()
    }
}
