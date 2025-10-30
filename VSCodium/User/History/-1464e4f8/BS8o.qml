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
        
        Text {
            id: archText
            anchors.centerIn: parent
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: ThemeManager.bgBase
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    onClicked: {
        Quickshell.execDetached("wofi", ["--show", "drun"])
    }
}
