import QtQuick
import Quickshell

MouseArea {
    id: powerButton
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: powerText.width + 16
        height: parent.height - 10
        
        color: powerButton.containsMouse ? ThemeManager.accentMaroon : ThemeManager.accentRed
        radius: 6
        opacity: 1.0
        
        Text {
            id: powerText
            anchors.centerIn: parent
            text: "󰐥"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 18
            color: "#1a1b26"  // Solid dark color for contrast
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        Quickshell.execDetached(Quickshell.env("HOME") + "/.config/waybar/scripts/powermenu.sh")
    }
}
