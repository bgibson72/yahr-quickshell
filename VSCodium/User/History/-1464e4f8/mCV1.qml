import QtQuick
import QtQuick.Controls
import Quickshell

MouseArea {
    id: archButton
    
    width: 50
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 5
        
        color: archButton.containsMouse ? "#9d7cd8" : "#7aa2f7"
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 24
            color: "#1a1b26"
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        Quickshell.execDetached("wofi", ["--show", "drun"])
    }
}
