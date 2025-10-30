import Quickshellimport Quickshell

import Quickshell.Services.Notificationsimport Quickshell.Services.Notifications

import QtQuickimport Quickshell.Io

import QtQuick

QtObject {

    id: rootQtObject {

    id: root

    property var notifications: []

    property bool dndEnabled: false    property list<QtObject> notifications: []

    property bool dndEnabled: false

    signal notificationsChanged()

    // NotificationServer implements the freedesktop notification spec

    // NotificationServer implements the freedesktop notification spec    property NotificationServer server: NotificationServer {

    property NotificationServer server: NotificationServer {        id: server

        keepOnReload: false  // Important: false not true!

        actionsSupported: true        keepOnReload: true

        bodyHyperlinksSupported: true        actionsSupported: true

        bodyImagesSupported: true        bodyHyperlinksSupported: true

        bodyMarkupSupported: true        bodyImagesSupported: true

        imageSupported: true        bodyMarkupSupported: true

        persistenceSupported: true        imageSupported: true

        persistenceSupported: true

        onNotification: notif => {

            console.log("📩 Received notification:", notif.summary, "from", notif.appName)        onNotification: notif => {

                        console.log("New notification:", notif.summary, notif.body)

            // CRITICAL: Must set tracked before doing anything else            

            notif.tracked = true            // Track the notification

            notif.tracked = true

            // Create wrapper object

            const wrapper = {            // Create a notification object

                notification: notif,            const notifObj = notificationComponent.createObject(root, {

                id: notif.id,                notification: notif,

                summary: notif.summary || "",                id: notif.id,

                body: notif.body || "",                summary: notif.summary || "",

                appName: notif.appName || "Notification",                body: notif.body || "",

                appIcon: notif.appIcon || "",                appName: notif.appName || "Notification",

                urgency: notif.urgency || 1,                appIcon: notif.appIcon || "",

                time: new Date(),                urgency: notif.urgency,

                closed: false,                actions: notif.actions || [],

                                time: new Date()

                close: function() {            })

                    this.closed = true

                    if (this.notification) {            // Add to list

                        this.notification.dismiss()            root.notifications = [notifObj, ...root.notifications]

                    }            console.log("Total notifications:", root.notifications.length)

                    // Remove from array        }

                    root.notifications = root.notifications.filter(n => n.id !== this.id)    }

                    root.notificationsChanged()

                }    property Component notificationComponent: Component {

            }        QtObject {

            id: notifItem

            // Add to beginning of array            

            root.notifications = [wrapper, ...root.notifications]            property var notification

            console.log("📊 Total notifications:", root.notifications.length)            property int id

            root.notificationsChanged()            property string summary

        }            property string body

    }            property string appName

            property string appIcon

    function dismissNotification(notifId) {            property int urgency

        console.log("Dismissing notification:", notifId)            property var actions

        const notif = notifications.find(n => n.id === notifId)            property date time

        if (notif) {            property bool closed: false

            notif.close()

        }            function close() {

    }                closed = true

                if (notification) {

    function clearAllNotifications() {                    notification.close(NotificationCloseReason.DismissedByUser)

        console.log("Clearing all notifications")                }

        // Work backwards to avoid index issues                // Remove from list

        for (let i = notifications.length - 1; i >= 0; i--) {                root.notifications = root.notifications.filter(n => n !== notifItem)

            notifications[i].close()                notifItem.destroy()

        }            }

    }

            function invoke(actionId) {

    function toggleDnd() {                if (notification && actions) {

        dndEnabled = !dndEnabled                    notification.invokeAction(actionId)

        console.log("DND mode:", dndEnabled ? "enabled" : "disabled")                }

    }            }

        }

    Component.onCompleted: {    }

        console.log("✅ NotificationService initialized")

    }    function clearAll() {

}        console.log("Clearing all notifications")

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

    Component.onCompleted: {
        console.log("NotificationService initialized, server:", server)
    }
}
