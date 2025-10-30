import QtQuick
import QtQuick.Controls
import Quickshell

MouseArea {
    id: archButton
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: 50
        height: 32
        
        // Visual states: normal, hover, pressed
        color: {
            if (archButton.pressed) return Qt.darker(ThemeManager.accentBlue, 1.3)
            else if (archButton.containsMouse) return ThemeManager.accentPurple
            else return ThemeManager.accentBlue
        }
        radius: 6
        
        // Scale effect when pressed
        scale: archButton.pressed ? 0.95 : 1.0
        
        Text {
            id: archText
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: "#1a1b26"
        }
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
    }
    
    onClicked: {
        console.log("Arch button clicked!")
        // Try multiple approaches to launch wofi
        Quickshell.execDetached("sh", ["-c", "wofi --show drun"])
    }
    
    onEntered: {
        console.log("Mouse entered Arch button - cursor should be pointer")
    }
    
    onPressed: {
        console.log("Arch button pressed!")
    }
    
    onReleased: {
        console.log("Arch button released!")
    }
}
