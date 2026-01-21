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
            height: 32
            color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
            radius: 6
            
            Behavior on color {
                ColorAnimation { duration: 200 }
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
