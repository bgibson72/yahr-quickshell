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

            const wrapper = {
                notification: notif,
                id: notif.id,
                summary: notif.summary || "",
                body: notif.body || "",
                appName: notif.appName || "Notification",
                appIcon: notif.appIcon || "",
                urgency: notif.urgency || 1,
                time: new Date(),
                closed: false,
                
                close: function() {
                    this.closed = true
                    if (this.notification) {
                        this.notification.dismiss()
                    }
                    root.notifications = root.notifications.filter(n => n.id !== this.id)
                }
            }

            root.notifications = [wrapper, ...root.notifications]
            console.log("📊 Total notifications:", root.notifications.length)
        }
    }

    function dismissNotification(notifId) {
        console.log("Dismissing notification:", notifId)
        const notif = notifications.find(n => n.id === notifId)
        if (notif) {
            notif.close()
        }
    }

    function clearAllNotifications() {
        console.log("Clearing all notifications")
        for (let i = notifications.length - 1; i >= 0; i--) {
            notifications[i].close()
        }
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled
        console.log("DND mode:", dndEnabled ? "enabled" : "disabled")
    }

    Component.onCompleted: {
        console.log("✅ NotificationService initialized")
    }
}
