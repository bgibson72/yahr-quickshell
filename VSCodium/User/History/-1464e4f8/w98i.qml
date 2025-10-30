import QtQuick
import Quickshell

Rectangle {
    id: archButton
    
    width: 60
    height: 35
    
    color: mouseArea.containsMouse ? "#9d7cd8" : "#7aa2f7"
    radius: 6
    
    Text {
        anchors.centerIn: parent
        text: "󰣇"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 20
        color: "#1a1b26"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            console.log("SIMPLE ARCH BUTTON CLICKED!")
            Quickshell.execDetached("wofi", ["--show", "drun"])
        }
        
        onEntered: console.log("ENTERED ARCH BUTTON")
        onExited: console.log("EXITED ARCH BUTTON")
    }
    
    Behavior on color {
        ColorAnimation { duration: 200 }
    }
}
