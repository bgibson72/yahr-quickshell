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
                    if (staticWorkspaceButton.hasAttention) {
                        return ThemeManager.accentRed
                    } else if (staticWorkspaceButton.hyprWorkspace && staticWorkspaceButton.hyprWorkspace.toplevels.length > 0) {
                        return ThemeManager.fgPrimary
                    } else {
                        return ThemeManager.fgTertiary
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && ws
            Rectangle {
                anchors.top: workspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: workspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                visible: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && (ws.focused || ws.active || staticWorkspaceButton.hasAttention)) {
                        return true)) {
                        return true
                    }
                    // Fallback: check if this workspace ID matches the focused workspace
                    if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
                        return Hyprland.focusedMonitor.activeWorkspace.id === staticWorkspaceButton.workspaceId
                    }
                    return false
                }
                
                color
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
                id: dynamicWorkspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                
                color: {
                    if (dynamicWorkspaceButton.hasAttention) {
                        // Bright red background when urgent
                        return Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.3)
                    } else if (dynamicWorkspaceButton.containsMouse) {
                        return Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1)
                    } else {
                        return "transparent"
                    }
                }
                
                radius: 6
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Text {
                id: dynamicWorkspaceText
                anchorsdynamicWorkspaceButton.containsMouse ? 
                    Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1) : 
                    "transparent"
                
                radius: 6ehavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Rectangle {
                anchors.top: dynamicWorkspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: dynamicWorkspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                visible: dynamicWorkspaceButton.modelData.focused || dynamicWorkspaceButton.modelData.active || dynamicWorkspaceButton.hasAttention
                
                color: dynamicWorkspaceButton.hasAttention ? ThemeManager.accentRed : ThemeManager.fgPrimary
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
                    if (dynamicWorkspaceButton.modelData.toplevels.length > 0) {kspaceButton.modelData.name])
            }
        }
                
                color
