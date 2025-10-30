import QtQuick
import Quickshell

Rectangle {
    id: powerButton
    
    width: contentRect.width + 20
    height: 42
    
    color: "transparent"
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Power button clicked!")
            const scriptPath = Quickshell.env("HOME") + "/.config/quickshell/scripts/powermenu.sh"
            console.log("Launching script:", scriptPath)
            Quickshell.execDetached(["bash", scriptPath])
        }
        
        Rectangle {
            id: contentRect
            anchors.centerIn: parent
            width: 50
            height: 32
            
            color: mouseArea.containsMouse ? ThemeManager.accentMaroon : ThemeManager.accentRed
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
    }
}
