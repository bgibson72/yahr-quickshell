import QtQuick
import Quickshell

Rectangle {
    id: root
    
    required property var notificationService
    
    color: ThemeManager.bgBase
    radius: 12
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property bool dndEnabled: notificationService ? notificationService.dndEnabled : false
    property var notifications: notificationService ? notificationService.notifications : []
    
    onNotificationsChanged: {
        console.log("🔔 NotificationCenter: notifications changed, count:", notifications.length)
    }
    
    Component.onCompleted: {
        console.log("🔔 NotificationCenter initialized with", notifications.length, "notifications")
        console.log("🔔 notificationService:", notificationService)
    }
    
    signal requestClose()
    signal dndStateChanged(bool enabled)
    
    // ESC key to close
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    // Main content
    Column {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 12
        
        // Header with title and controls
        Row {
            width: parent.width
            height: 40
            spacing: 8
            
            Text {
                text: "Notifications"
                font.family: "MapleMono NF"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Item { 
                width: parent.width - 380  // Adjusted to fit all buttons
                height: 1
            }
            
            // DND Toggle
            Rectangle {
                width: 90
                height: 32
                radius: 6
                color: dndMouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                border.width: 1
                border.color: root.dndEnabled ? ThemeManager.accentRed : ThemeManager.border0
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Text {
                        text: root.dndEnabled ? "󰂛" : "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: root.dndEnabled ? ThemeManager.accentRed : ThemeManager.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "DND"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: root.dndEnabled ? ThemeManager.accentRed : ThemeManager.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: dndMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        notificationService.dndEnabled = !notificationService.dndEnabled
                        root.dndStateChanged(notificationService.dndEnabled)
                        console.log("DND toggled:", notificationService.dndEnabled)
                    }
                }
            }
            
            // Dismiss All button
            Rectangle {
                width: 90
                height: 32
                radius: 6
                color: dismissAllMouseArea.containsMouse ? ThemeManager.accentRed : ThemeManager.surface0
                border.width: 1
                border.color: ThemeManager.border0
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.family: "MapleMono NF"
                    font.pixelSize: 12
                    color: dismissAllMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgSecondary
                }
                
                MouseArea {
                    id: dismissAllMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("Dismissing all notifications")
                        notificationService.clearAll()
                    }
                }
            }
            
            // Close button
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: closeMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.family: "Maple Mono NF"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: closeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgSecondary
                }
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
            }
        }
        
        // Notifications list or empty state
        Rectangle {
            width: parent.width
            height: parent.parent.height - 40 - 12 - 32
            color: ThemeManager.surface0
            radius: 8
            
            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: notificationColumn.height
                clip: true
                
                Column {
                    id: notificationColumn
                    width: parent.width
                    spacing: 8
                    
                    Repeater {
                        model: root.notifications
                        
                        Rectangle {
                            width: notificationColumn.width
                            height: notificationContent.height + 24
                            radius: 8
                            color: ThemeManager.surface1
                            border.width: 2
                            border.color: {
                                let urgency = modelData.urgency || "normal"
                                if (urgency === "low") return ThemeManager.accentGreen
                                if (urgency === "critical") return ThemeManager.accentRed
                                return ThemeManager.accentYellow
                            }
                            
                            Column {
                                id: notificationContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 12
                                }
                                spacing: 8
                                
                                Row {
                                    width: parent.width
                                    spacing: 8
                                    
                                    // App icon (if available)
                                    Text {
                                        text: modelData.appIcon || "󰂚"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 20
                                        color: {
                                            let urgency = modelData.urgency || "normal"
                                            if (urgency === "low") return ThemeManager.accentGreen
                                            if (urgency === "critical") return ThemeManager.accentRed
                                            return ThemeManager.accentYellow
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Column {
                                        width: parent.width - 100
                                        spacing: 4
                                        
                                        // App name
                                        Text {
                                            text: modelData.appName || "Notification"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgSecondary
                                            elide: Text.ElideRight
                                        }
                                        
                                        // Summary (title)
                                        Text {
                                            width: parent.width
                                            text: modelData.summary || ""
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            color: ThemeManager.fgPrimary
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                    
                                    Item { width: 8; height: 1 }
                                    
                                    // Dismiss button
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 4
                                        color: dismissHover.containsMouse ? ThemeManager.accentRed : "transparent"
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            font.pixelSize: 14
                                            color: dismissHover.containsMouse ? ThemeManager.bgBase : ThemeManager.fgSecondary
                                        }
                                        
                                        MouseArea {
                                            id: dismissHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                console.log("Dismissing notification:", modelData.id)
                                                notificationService.dismissNotification(modelData.id)
                                            }
                                        }
                                    }
                                }
                                
                                // Body text (if available)
                                Text {
                                    width: parent.width
                                    text: modelData.body || ""
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.Wrap
                                    visible: modelData.body && modelData.body.length > 0
                                }
                            }
                        }
                    }
                }
            }
            
            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.notifications.length === 0
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂜"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 48
                    color: ThemeManager.fgSecondary
                    opacity: 0.5
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"
                    font.family: "MapleMono NF"
                    font.pixelSize: 14
                    color: ThemeManager.fgSecondary
                    opacity: 0.5
                }
            }
        }
    }
}
