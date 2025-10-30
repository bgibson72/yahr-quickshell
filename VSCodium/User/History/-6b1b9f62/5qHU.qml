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
            
            Layout.preferredWidth: 40
            Layout.preferredHeight: parent.height
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            Rectangle {
                anchors.fill: parent
                color: workspaceButton.containsMouse ? ThemeManager.surface0 : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: workspaceButton.workspaceId
                    font.family: "MapleMono NF"
                    font.pixelSize: ThemeManager.fontSizeWorkspace
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
