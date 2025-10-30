import QtQuick
import QtQuick.Controls
import Quickshell

Rectangle {
    id: root
    
    property int notificationCount: NotificationService.notifications.length
    property bool hasNotifications: notificationCount > 0
    property bool dndMode: NotificationService.dndEnabled
    
    signal clicked()
    
    width: contentRect.width + 20
    height: 35
    
    color: "transparent"
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Notification indicator clicked - opening notification center")
            root.clicked()
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
                    text: root.dndMode ? "󰂛" : (root.hasNotifications ? "󰂚" : "󰂜")
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: root.dndMode ? ThemeManager.accentRed : (root.hasNotifications ? ThemeManager.accentYellow : ThemeManager.accentBlue)
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
    }
}
