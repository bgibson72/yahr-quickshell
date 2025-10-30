import QtQuick
import Quickshell

Rectangle {
    id: settingsButton
    width: 32
    height: 32
    radius: 8
    color: "transparent"
    
    signal clicked()
    
    Text {
        anchors.centerIn: parent
        text: "\uf013"  // settings icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: ThemeManager.fontSizeIcon
        color: mouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.fgPrimary
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
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
