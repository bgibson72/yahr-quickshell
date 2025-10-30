import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    property int notificationCount: 0
    property bool hasNotifications: notificationCount > 0
    
    width: contentRect.width + 20
    height: 35
    
    color: "transparent"
    
    // Process to get notification count from mako
    Process {
        id: countProcess
        command: ["sh", "-c", "makoctl list | grep -c '\"id\":'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Read notification count:", data)
                let count = parseInt(data.trim())
                console.log("Parsed notification count:", count)
                if (!isNaN(count)) {
                    root.notificationCount = count
                } else {
                    root.notificationCount = 0
                }
            }
        }
    }
    
    // Timer to update notification count periodically
    Timer {
        interval: 2000  // Update every 2 seconds
        running: true
        repeat: true
        onTriggered: countProcess.running = true
    }
    
    // Initialize count on component load
    Component.onCompleted: {
        countProcess.running = true
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Notification indicator clicked - dismissing all notifications")
            dismissProcess.running = true
        }
        
        Rectangle {
            id: contentRect
            anchors.centerIn: parent
            width: 60  // Wider for icon + number
            height: 32
            
            color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
            radius: 6
        
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Row {
                id: notificationRow
                anchors.centerIn: parent
                spacing: 6
                
                Text {
                    id: bellIcon
                    text: root.hasNotifications ? "󰂚" : "󰂜"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: root.hasNotifications ? ThemeManager.accentYellow : ThemeManager.accentBlue
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                
                Text {
                    id: countText
                    text: root.notificationCount.toString()
                    font.family: "MapleMono NF"
                    font.pixelSize: 13
                    color: root.hasNotifications ? ThemeManager.accentYellow : ThemeManager.accentBlue
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
            }
        }
        
        // Process to toggle notification center
        Process {
            id: toggleProcess
            command: ["swaync-client", "-t"]
            running: false
        }
    }
}
