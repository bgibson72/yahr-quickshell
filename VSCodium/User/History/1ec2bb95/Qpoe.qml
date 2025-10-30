import QtQuick
import Quickshell

Rectangle {
    id: settingsButton
    width: 32
    height: 32
    radius: 6
    color: mouseArea.containsMouse ? 
        Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1) : 
        "transparent"
    
    signal clicked()
    
    Behavior on color {
        ColorAnimation { duration: 200 }
    }
    
    Text {
        anchors.centerIn: parent
        text: "\uf013"  // settings icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: ThemeManager.fontSizeIcon
        color: ThemeManager.fgPrimary
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Settings button clicked")
            settingsButton.clicked()
        }
    }
}
