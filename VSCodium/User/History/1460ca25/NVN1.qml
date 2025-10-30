import QtQuick
import Quickshell

Rectangle {
    id: popup
    
    required property var notification
    property bool isClosing: false
    
    signal closeRequested()
    
    Component.onCompleted: {
        console.log("🎨 NotificationPopup created for:", notification.summary, "height:", height)
    }
    
    onHeightChanged: {
        console.log("📐 NotificationPopup height changed to:", height, "for:", notification.summary)
    }
    
    width: 400
    height: contentColumn.height + 24
    radius: 12
    color: ThemeManager.bgBase
    border.width: 2
    border.color: {
        let urgency = notification.urgency || 1
        if (urgency === 0) return ThemeManager.accentGreen  // low
        if (urgency === 2) return ThemeManager.accentRed    // critical
        return ThemeManager.accentYellow  // normal
    }
    
    // Auto-dismiss timer (except for critical notifications)
    Timer {
        id: dismissTimer
        interval: {
            let urgency = notification.urgency || 1
            if (urgency === 2) return 0  // critical = no auto-dismiss
            if (urgency === 0) return 3000  // low = 3 seconds
            return 5000  // normal = 5 seconds
        }
        running: interval > 0 && !popup.isClosing
        onTriggered: {
            // Just hide the popup, don't remove from notification center
            popup.hide()
        }
    }
    
    // Hover to pause auto-dismiss
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        onEntered: {
            dismissTimer.stop()
        }
        
        onExited: {
            if (dismissTimer.interval > 0 && !popup.isClosing) {
                dismissTimer.restart()
            }
        }
        
        onClicked: function(mouse) {
            mouse.accepted = false  // Let child MouseAreas handle clicks
        }
    }
    
    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
        }
        spacing: 8
        
        // Header row with app info and close button
        Item {
            width: parent.width
            height: 28
            
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                // App icon
                Text {
                    text: notification.appIcon || "󰂚"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 20
                    color: {
                        let urgency = notification.urgency || 1
                        if (urgency === 0) return ThemeManager.accentGreen
                        if (urgency === 2) return ThemeManager.accentRed
                        return ThemeManager.accentYellow
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                // App name
                Text {
                    text: notification.appName || "Notification"
                    font.family: "MapleMono NF"
                    font.pixelSize: 11
                    color: ThemeManager.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Close button
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                radius: 6
                color: closeButtonArea.containsMouse ? ThemeManager.accentRed : ThemeManager.surface1
                
                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: ThemeManager.fgPrimary
                }
                
                MouseArea {
                    id: closeButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        popup.close()
                    }
                }
            }
        }
        
        // Summary (title)
        TextEdit {
            id: summaryText
            width: parent.width
            text: notification.summary || ""
            font.family: "MapleMono NF"
            font.pixelSize: 14
            font.weight: Font.Bold
            color: ThemeManager.fgPrimary
            wrapMode: TextEdit.Wrap
            visible: text !== ""
            readOnly: true
            selectByMouse: false
            selectByKeyboard: false
            activeFocusOnPress: false
        }
        
        // Body
        TextEdit {
            id: bodyText
            width: parent.width
            text: notification.body || ""
            font.family: "MapleMono NF"
            font.pixelSize: 12
            color: ThemeManager.fgSecondary
            wrapMode: TextEdit.Wrap
            visible: text !== ""
            readOnly: true
            selectByMouse: false
            selectByKeyboard: false
            activeFocusOnPress: false
        }
        
        // Action buttons
        Row {
            width: parent.width
            spacing: 8
            visible: notification.actions && notification.actions.length > 0
            
            Repeater {
                model: notification.actions || []
                
                Rectangle {
                    width: (parent.width - (notification.actions.length - 1) * parent.spacing) / notification.actions.length
                    height: 32
                    radius: 6
                    color: actionButtonArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                    border.width: 1
                    border.color: ThemeManager.accentBlue
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData.text || "Action"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: actionButtonArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                    }
                    
                    MouseArea {
                        id: actionButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            console.log("🔘 Action clicked:", modelData.text)
                            if (modelData.invoke) {
                                modelData.invoke()
                            }
                            popup.close()
                        }
                    }
                }
            }
        }
    }
    
    // Fade-in animation
    opacity: 0
    NumberAnimation on opacity {
        id: fadeIn
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutCubic
        running: true
    }
    
    // Slide-out animation (slide to the right when closing)
    NumberAnimation on x {
        id: slideOut
        from: 0
        to: 500
        duration: 200
        easing.type: Easing.InCubic
        running: false
        property bool shouldDismiss: false
        
        onFinished: {
            if (shouldDismiss) {
                popup.closeRequested()
            }
        }
    }
    
    // Fade out animation
    NumberAnimation on opacity {
        id: fadeOut
        from: 1.0
        to: 0.0
        duration: 200
        running: false
    }
    
    function hide() {
        // Just hide the popup visually, don't remove from notification center
        popup.isClosing = true
        dismissTimer.stop()
        slideOut.shouldDismiss = false
        slideOut.running = true
        fadeOut.running = true
    }
    
    function close() {
        // Close and remove from notification center
        popup.isClosing = true
        dismissTimer.stop()
        slideOut.shouldDismiss = true
        slideOut.running = true
        fadeOut.running = true
    }
}

