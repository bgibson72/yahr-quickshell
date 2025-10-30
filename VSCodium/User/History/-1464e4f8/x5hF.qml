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
        width: Math.max(archText.implicitWidth + 16, 40)  // Minimum 40px width
        height: parent.height - 10
        
        color: "red"  // Debug: solid red to see if rectangle appears
        border.color: "white"
        border.width: 2
        radius: 6
        
        Text {
            id: archText
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: "white"
        }
    }
    
    onClicked: {
        Quickshell.execDetached("wofi", ["--show", "drun"])
    }
}
