import QtQuick
import Quickshell

MouseArea {
    id: powerButton
    
    width: 50
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 10
        anchors.rightMargin: 0
        
        color: powerButton.containsMouse ? ThemeManager.accentMaroon : ThemeManager.accentRed
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "󰐥"
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
            color: ThemeManager.bgBase
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        Quickshell.execDetached(Quickshell.env("HOME") + "/.config/waybar/scripts/powermenu.sh")
    }
}
