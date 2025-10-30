import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: workspaceBar
    spacing: 0
    
    Repeater {
        model: 5  // persistent workspaces
        
        MouseArea {
            id: workspaceButton
            
            required property int index
            property int workspaceId: index + 1
            property bool isActive: HyprlandFocusedMonitor.activeWorkspace?.id === workspaceId
            property bool hasWindows: {
                for (let i = 0; i < HyprlandWorkspaces.count; i++) {
                    let ws = HyprlandWorkspaces.values[i]
                    if (ws.id === workspaceId && ws.windows.length > 0) {
                        return true
                    }
                }
                return false
            }
            
            Layout.preferredWidth: 40
            Layout.preferredHeight: parent.height
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            Rectangle {
                anchors.fill: parent
                color: workspaceButton.containsMouse ? "#292e42" : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: workspaceButton.workspaceId
                    font.family: "MapleMono NF"
                    font.pixelSize: 16
                    color: workspaceButton.isActive ? "#7aa2f7" : 
                           workspaceButton.hasWindows ? "#c0caf5" : "#a9b1d6"
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 16
                    height: 2
                    color: "#7aa2f7"
                    visible: workspaceButton.isActive
                }
            }
            
            onClicked: {
                Hyprland.dispatch("workspace", workspaceButton.workspaceId.toString())
            }
        }
    }
}
