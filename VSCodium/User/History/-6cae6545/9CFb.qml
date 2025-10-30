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
        width: 50
        height: 32
        
        color: powerButton.containsMouse ? ThemeManager.accentMaroon : ThemeManager.accentRed
        radius: 6
        
        Text {
            id: powerText
            anchors.centerIn: parent
            text: "󰐥"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 18
            color: ThemeManager.bgBase
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        console.log("Power button clicked!")
        Quickshell.execDetached(["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/scripts/powermenu.sh"])
    }
}
