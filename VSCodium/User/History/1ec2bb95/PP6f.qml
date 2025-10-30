import QtQuick
import Quickshell

Rectangle {
    id: settingsButton
    width: 48
    height: 42
    radius: 8
    color: mouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
    
    signal clicked()
    
    Text {
        anchors.centerIn: parent
        text: ""  // settings/gear icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: 20
        color: mouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
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
