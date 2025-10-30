import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: workspaceBar
    spacing: 4
    
    // Always show workspaces 1-4
    Repeater {
        model: 4
        
        MouseArea {
            id: staticWorkspaceButton
            
            property int workspaceId: index + 1
            property var hyprWorkspace: {
                // Find matching workspace from Hyprland
                for (let i = 0; i < Hyprland.workspaces.length; i++) {
                    if (Hyprland.workspaces[i].id === workspaceId) {
                        return Hyprland.workspaces[i]
                    }
                }
                return null
            }
            
            width: 40
            height: 32
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10
            
            Rectangle {
                id: workspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                
                color: staticWorkspaceButton.containsMouse ? 
                    Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1) : 
                    "transparent"
                
                radius: 6
            }
            
            Text {
                id: workspaceText
                anchors.centerIn: workspaceRect
                text: staticWorkspaceButton.workspaceId
                font.family: "MapleMono NF"
                font.pixelSize: 13
                
                color: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && ws.urgent) {
                        return ThemeManager.accentRed
                    } else if (ws && ws.toplevels.length > 0) {
                        return ThemeManager.fgPrimary
                    } else {
                        return ThemeManager.fgTertiary
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Rectangle {
                anchors.top: workspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: workspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                visible: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    return ws && (ws.focused || ws.active || ws.urgent)
                }
                
                color: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    return (ws && ws.urgent) ? ThemeManager.accentRed : ThemeManager.fgPrimary
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            onClicked: {
                console.log("Workspace", staticWorkspaceButton.workspaceId, "clicked")
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", staticWorkspaceButton.workspaceId.toString()])
            }
        }
    }
    
    // Show workspaces 5+ only when in use
    Repeater {
        model: Hyprland.workspaces
        
        MouseArea {
            id: dynamicWorkspaceButton
            
            required property var modelData
            
            visible: modelData.id >= 5 && (modelData.toplevels.length > 0 || modelData.active || modelData.focused)
            
            width: visible ? 40 : 0
            height: 32
            
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
