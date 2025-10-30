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
                time: new Date().toISOString(),
                timestamp: Date.now(),
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
            
            // Show popup if not in DND mode
            if (!root.dndEnabled) {
                root.showPopup(wrapper)
            }
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
    
    function showPopup(notification) {
        // Popups will be created by shell.qml in a separate layer
        console.log("💬 Popup requested for:", notification.summary)
    }
    
    function saveNotifications() {
        const data = {
            dndEnabled: dndEnabled,
            notifications: notifications.map(n => ({
                id: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                appIcon: n.appIcon,
                urgency: n.urgency,
                time: n.time,
                timestamp: n.timestamp,
                closed: n.closed
            }))
        }
        
        const json = JSON.stringify(data, null, 2)
        
        // Ensure directory exists
        const dir = storageFile.substring(0, storageFile.lastIndexOf('/'))
        
        // Write to file using a Process
        const writeProcess = Qt.createQmlObject(`
            import Quickshell
            import Quickshell.Io
            Process {
                running: true
                command: ["sh", "-c", "mkdir -p '${dir}' && echo '${json.replace(/'/g, "'\\''")}' > '${storageFile}'"]
            }
        `, root)
        
        console.log("💾 Saved", notifications.length, "notifications to", storageFile)
    }
    
    function loadNotifications() {
        const readProcess = Qt.createQmlObject(`
            import Quickshell
            import Quickshell.Io
            Process {
                running: true
                command: ["cat", "${storageFile}"]
            }
        `, root)
        
        readProcess.onExited.connect((code, status) => {
            if (code === 0 && readProcess.stdout) {
                try {
                    const data = JSON.parse(readProcess.stdout)
                    
                    // Restore DND state
                    if (data.dndEnabled !== undefined) {
                        root.dndEnabled = data.dndEnabled
                    }
                    
                    // Restore notifications (but without the live notification objects)
                    if (data.notifications && Array.isArray(data.notifications)) {
                        root.notifications = data.notifications.map(n => ({
                            ...n,
                            notification: null,  // No live notification object
                            close: function() {
                                this.closed = true
                                root.notifications = root.notifications.filter(item => item.id !== this.id)
                            }
                        }))
                        console.log("📂 Loaded", root.notifications.length, "notifications from", storageFile)
                    }
                } catch (e) {
                    console.log("⚠️  Failed to parse notifications:", e)
                }
            } else {
                console.log("📂 No saved notifications found (first run)")
            }
        })
    }

    Component.onCompleted: {
        console.log("✅ NotificationService initialized")
        loadNotifications()
    }
}
