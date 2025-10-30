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
            
            color: {
                if (mouseArea.pressed) return Qt.darker(ThemeManager.accentMaroon, 1.3)
                else if (mouseArea.containsMouse) return ThemeManager.accentMaroon
                else return ThemeManager.accentRed
            }
            radius: 6
            
            // Scale effect - smaller when pressed
            scale: mouseArea.pressed ? 0.92 : 1.0
            
            // Subtle opacity change when pressed
            opacity: mouseArea.pressed ? 0.8 : 1.0
            
            Text {
                id: powerText
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: ThemeManager.bgBase
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }
}
