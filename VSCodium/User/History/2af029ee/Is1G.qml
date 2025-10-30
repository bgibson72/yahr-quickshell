import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    property list<QtObject> notifications: []
    property bool dndEnabled: false

    // NotificationServer implements the freedesktop notification spec
    property NotificationServer server: NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            console.log("New notification:", notif.summary, notif.body)
            
            // Track the notification
            notif.tracked = true

            // Create a notification object
            const notifObj = notificationComponent.createObject(root, {
                notification: notif,
                id: notif.id,
                summary: notif.summary || "",
                body: notif.body || "",
                appName: notif.appName || "Notification",
                appIcon: notif.appIcon || "",
                urgency: notif.urgency,
                actions: notif.actions || [],
                time: new Date()
            })

            // Add to list
            root.notifications = [notifObj, ...root.notifications]
            console.log("Total notifications:", root.notifications.length)
        }
    }

    Component {
        id: notificationComponent

        QtObject {
            id: notifItem
            
            property var notification
            property int id
            property string summary
            property string body
            property string appName
            property string appIcon
            property int urgency
            property var actions
            property date time
            property bool closed: false

            function close() {
                closed = true
                if (notification) {
                    notification.close(NotificationCloseReason.DismissedByUser)
                }
                // Remove from list
                root.notifications = root.notifications.filter(n => n !== notifItem)
                notifItem.destroy()
            }

            function invoke(actionId) {
                if (notification && actions) {
                    notification.invokeAction(actionId)
                }
            }
        }
    }

    function clearAll() {
        console.log("Clearing all notifications")
        for (const notif of notifications.slice()) {
            notif.close()
        }
    }

    function dismissNotification(notifId) {
        console.log("Dismissing notification:", notifId)
        const notif = notifications.find(n => n.id === notifId)
        if (notif) {
            notif.close()
        }
    }
}
