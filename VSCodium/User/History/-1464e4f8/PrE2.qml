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
        width: 50
        height: 32
        
        color: archButton.containsMouse ? ThemeManager.accentPurple : ThemeManager.accentBlue
        radius: 6
        
        Text {
            id: archText
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: "#1a1b26"
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        console.log("Arch button clicked!")
        Quickshell.execDetached("wofi", ["--show", "drun"])
    }
    
    onEntered: {
        console.log("Mouse entered Arch button")
    }
}
