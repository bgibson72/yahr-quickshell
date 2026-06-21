import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: clipboardManager
    
    width: 60
    height: 35
    color: "transparent"
    
    signal toggleClipboard()
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("🎨 Toggling clipboard panel")
            clipboardManager.toggleClipboard()
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: 50
            height: parent.height - 8
            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
            radius: 6
            border.width: mouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.18)

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 200 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰨸"  // Clipboard icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: ThemeManager.accentYellow
            }
        }
    }
}
