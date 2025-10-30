import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: workspaceBar
    spacing: 4
    
    Repeater {
        model: Hyprland.workspaces
        
        MouseArea {
            id: workspaceButton
            
            required property var modelData  // HyprlandWorkspace object
            
            Layout.preferredWidth: 40
            Layout.preferredHeight: parent.height
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10  // Ensure it's above other elements
            
            Rectangle {
                id: workspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                
                // No background colors - always transparent with subtle hover
                color: workspaceButton.containsMouse ? 
                    Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1) : 
                    "transparent"
                
                radius: 6
                
            }
            
            Text {
                id: workspaceText
                anchors.centerIn: workspaceRect
                    text: modelData.id
                    font.family: "MapleMono NF"
                    font.pixelSize: 13
                    
                    // Simple text colors
                    color: {
                        if (modelData.urgent) {
                            return ThemeManager.accentRed  // Red text for urgent
                        } else if (modelData.toplevels.length > 0) {
                            return ThemeManager.fgPrimary  // Normal text for occupied
                        } else {
                            return ThemeManager.fgTertiary  // Dim text for empty
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            
            // Bottom underline indicator - positioned below text
            Rectangle {
                anchors.top: workspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: workspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                // Show underline for active or urgent workspaces
                visible: modelData.focused || modelData.active || modelData.urgent
                
                // Color: red for urgent, normal text color for active
                color: modelData.urgent ? ThemeManager.accentRed : ThemeManager.fgPrimary
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            onClicked: {
                console.log("Workspace", modelData.id, "clicked")
                console.log("Workspace name:", modelData.name)
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", modelData.name])
            }
        }
    }
}
