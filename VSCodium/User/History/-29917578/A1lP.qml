import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    width: content.width
    height: 40
    
    property int notificationCount: 0
    property bool hasNotifications: notificationCount > 0
    
    // Process to get notification count from SwayNC
    Process {
        id: countProcess
        command: ["swaync-client", "-c"]
        
        onStarted: running = true
        onExited: running = false
        
        stdout: SplitParser {
            onRead: data => {
                let count = parseInt(data.trim())
                if (!isNaN(count)) {
                    root.notificationCount = count
                }
            }
        }
    }
    
    // Timer to update notification count periodically
    Timer {
        interval: 2000  // Update every 2 seconds
        running: true
        repeat: true
        onTriggered: countProcess.start()
    }
    
    // Initialize count on component load
    Component.onCompleted: {
        countProcess.start()
    }
    
    Rectangle {
        id: content
        anchors.centerIn: parent
        width: bellIcon.width + (badge.visible ? badge.width + 4 : 0) + 16
        height: parent.height
        color: mouseArea.containsMouse ? Qt.rgba(
            ThemeManager.surface0.r,
            ThemeManager.surface0.g,
            ThemeManager.surface0.b,
            0.3
        ) : "transparent"
        radius: 8
        
        Row {
            anchors.centerIn: parent
            spacing: 4
            
            Item {
                width: bellIcon.width
                height: bellIcon.height
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    id: bellIcon
                    text: root.hasNotifications ? "󰂚" : "󰂜"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: ThemeManager.fontSizeIcon
                    color: root.hasNotifications ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                    anchors.centerIn: parent
                }
            }
            
            Rectangle {
                id: badge
                visible: root.hasNotifications && root.notificationCount > 0
                width: badgeText.width + 8
                height: 18
                radius: 9
                color: ThemeManager.accentRed
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    id: badgeText
                    text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    font.bold: true
                    color: ThemeManager.bgBase
                    anchors.centerIn: parent
                }
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                toggleProcess.start()
            }
        }
        
        // Process to toggle notification center
        Process {
            id: toggleProcess
            command: ["swaync-client", "-t"]
            running: false
        }
    }
    
    // Tooltip
    Rectangle {
        visible: mouseArea.containsMouse
        width: tooltipText.width + 16
        height: tooltipText.height + 12
        color: ThemeManager.surface0
        border.color: ThemeManager.border0
        border.width: 1
        radius: 6
        x: content.x + (content.width - width) / 2
        y: -height - 8
        
        Text {
            id: tooltipText
            text: root.hasNotifications 
                ? `${root.notificationCount} notification${root.notificationCount !== 1 ? 's' : ''}`
                : "No notifications"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: ThemeManager.fontSizeSmall
            color: ThemeManager.fgPrimary
            anchors.centerIn: parent
        }
    }
}
