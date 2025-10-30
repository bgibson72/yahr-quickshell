import QtQuick
import QtQuick.Controls
import Quickshell

MouseArea {
    id: archButton
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: archText.width + 16
        height: parent.height - 10
        
        color: archButton.containsMouse ? ThemeManager.accentPurple : ThemeManager.accentBlue
        radius: 6
        opacity: 1.0
        
        Text {
            id: archText
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: "#1a1b26"  // Solid dark color for contrast
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        Quickshell.execDetached("wofi", ["--show", "drun"])
    }
}
