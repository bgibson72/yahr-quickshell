import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: workspaceBar
    spacing: 0
    
    Repeater {
        model: 5  // persistent workspaces
        
        MouseArea {
            id: workspaceButton
            
            required property int index
            property int workspaceId: index + 1
            
            Layout.preferredWidth: 35
            Layout.preferredHeight: parent.height
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            Rectangle {
                anchors.centerIn: parent
                width: 30
                height: parent.height - 10
                color: workspaceButton.containsMouse ? ThemeManager.surface0 : "transparent"
                radius: 6
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: workspaceButton.workspaceId
                    font.family: "MapleMono NF"
                    font.pixelSize: 13
                    color: ThemeManager.fgSecondary
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
            
            onClicked: {
                Quickshell.execDetached("hyprctl", ["dispatch", "workspace", workspaceButton.workspaceId.toString()])
            }
        }
    }
}
