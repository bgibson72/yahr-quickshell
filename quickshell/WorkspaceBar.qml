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
                    Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.2) : 
                    "transparent"
                
                radius: 6
                
                // Add a subtle glow effect on hover
                border.width: staticWorkspaceButton.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
            }
            
            Text {
                id: workspaceText
                anchors.centerIn: workspaceRect
                text: staticWorkspaceButton.workspaceId.toString()
                font.family: "MapleMono NF"
                font.pixelSize: 13
                textFormat: Text.PlainText
                
                property bool isCurrentWorkspace: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && (ws.focused || ws.active)) {
                        console.log("Workspace", staticWorkspaceButton.workspaceId, "is active")
                        return true
                    }
                    // Fallback check
                    if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
                        return Hyprland.focusedMonitor.activeWorkspace.id === staticWorkspaceButton.workspaceId
                    }
                    return false
                }
                
                scale: isCurrentWorkspace ? 1.5 : 1.0
                font.bold: isCurrentWorkspace
                
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
                
                Behavior on scale {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBounce
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Rectangle {
                id: staticIndicator
                anchors.top: workspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: workspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                property bool isActive: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && (ws.focused || ws.active || ws.urgent)) {
                        return true
                    }
                    // Fallback: check if this workspace ID matches the focused workspace
                    if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
                        return Hyprland.focusedMonitor.activeWorkspace.id === staticWorkspaceButton.workspaceId
                    }
                    return false
                }
                
                opacity: isActive ? 1.0 : 0.0
                scale: isActive ? 1.0 : 0.5
                
                transform: Translate {
                    y: staticIndicator.isActive ? 0 : -5
                }
                
                color: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    return (ws && ws.urgent) ? ThemeManager.accentRed : ThemeManager.fgPrimary
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.3
                    }
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
            opacity: visible ? 1.0 : 0.0
            
            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10  // Ensure it's above other elements
            
            Rectangle {
                id: dynamicWorkspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                
                color: dynamicWorkspaceButton.containsMouse ? 
                    Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.2) : 
                    "transparent"
                
                radius: 6
                
                border.width: dynamicWorkspaceButton.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
            }
            
            Text {
                id: dynamicWorkspaceText
                anchors.centerIn: dynamicWorkspaceRect
                text: dynamicWorkspaceButton.modelData.id.toString()
                font.family: "MapleMono NF"
                font.pixelSize: 13
                textFormat: Text.PlainText
                
                property bool isCurrentWorkspace: dynamicWorkspaceButton.modelData.focused || dynamicWorkspaceButton.modelData.active
                
                scale: isCurrentWorkspace ? 1.5 : 1.0
                font.bold: isCurrentWorkspace
                
                color: {
                    if (dynamicWorkspaceButton.modelData.urgent) {
                        return ThemeManager.accentRed
                    } else if (dynamicWorkspaceButton.modelData.toplevels.length > 0) {
                        return ThemeManager.fgPrimary
                    } else {
                        return ThemeManager.fgTertiary
                    }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBounce
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Rectangle {
                id: dynamicIndicator
                anchors.top: dynamicWorkspaceText.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: dynamicWorkspaceText.horizontalCenter
                width: 30
                height: 2
                radius: 1
                
                property bool isActive: dynamicWorkspaceButton.modelData.focused || dynamicWorkspaceButton.modelData.active || dynamicWorkspaceButton.modelData.urgent
                
                opacity: isActive ? 1.0 : 0.0
                scale: isActive ? 1.0 : 0.5
                
                transform: Translate {
                    y: dynamicIndicator.isActive ? 0 : -5
                }
                
                color: dynamicWorkspaceButton.modelData.urgent ? ThemeManager.accentRed : ThemeManager.fgPrimary
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.3
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            onClicked: {
                console.log("Workspace", dynamicWorkspaceButton.modelData.id, "clicked")
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", dynamicWorkspaceButton.modelData.name])
            }
        }
    }
}
