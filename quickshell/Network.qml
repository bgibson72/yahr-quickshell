import QtQuick
import Quickshell
import Quickshell.Io

MouseArea {
    id: networkArea
    
    property string connectionType: "ethernet"
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: 40
        height: 32
        
        color: networkArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            id: networkText
            anchors.centerIn: parent
            text: {
                if (networkArea.connectionType === "wifi") return "󰤨"
                else if (networkArea.connectionType === "ethernet") return "󰈀"
                else return "󰌙"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: {
                if (networkArea.connectionType === "wifi") return ThemeManager.accentGreen
                else if (networkArea.connectionType === "ethernet") return ThemeManager.accentBlue
                else return ThemeManager.accentRed
            }
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    
    onClicked: {
        Quickshell.execDetached("nm-connection-editor")
    }
}
