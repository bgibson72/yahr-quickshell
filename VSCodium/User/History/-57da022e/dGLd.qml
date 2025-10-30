import QtQuick
import Quickshell
import Quickshell.Io

MouseArea {
    id: networkArea
    
    property string connectionType: "ethernet"
    
    width: 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        color: networkArea.containsMouse ? "#33467c" : "#292e42"
        radius: 0
        
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 8
            radius: 8
            color: parent.color
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            anchors.centerIn: parent
            text: {
                if (networkArea.connectionType === "wifi") return "󰤨"
                else if (networkArea.connectionType === "ethernet") return "󰈀"
                else return "󰌙"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: {
                if (networkArea.connectionType === "wifi") return "#9ece6a"
                else if (networkArea.connectionType === "ethernet") return "#7aa2f7"
                else return "#f7768e"
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
