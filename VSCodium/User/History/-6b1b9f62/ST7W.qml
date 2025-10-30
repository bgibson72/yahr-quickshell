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
            
            Rectangle {
                id: workspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                
                // Advanced color logic for different states
                color: {
                    if (modelData.urgent) {
                        // Urgent workspace: red background
                        return workspaceButton.containsMouse ? 
                            Qt.lighter(ThemeManager.accentRed, 1.2) : ThemeManager.accentRed
                    } else if (modelData.focused) {
                        // Currently focused workspace: accent blue  
                        return workspaceButton.containsMouse ? 
                            Qt.lighter(ThemeManager.accentBlue, 1.2) : ThemeManager.accentBlue
                    } else if (modelData.active) {
                        // Active on monitor but not focused: surface1
                        return workspaceButton.containsMouse ? 
                            Qt.lighter(ThemeManager.surface1, 1.1) : ThemeManager.surface1
                    } else if (modelData.toplevels.length > 0) {
                        // Has windows but not active: surface0
                        return workspaceButton.containsMouse ? 
                            ThemeManager.surface1 : ThemeManager.surface0
                    } else {
                        // Empty workspace: transparent with hover
                        return workspaceButton.containsMouse ? 
                            ThemeManager.surface0 : "transparent"
                    }
                }
                
                radius: 6
                
                // Bottom border indicator for focused workspace
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    color: modelData.focused ? ThemeManager.fgPrimary : "transparent"
                    radius: 1
                    visible: modelData.focused
                }
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    font.family: "MapleMono NF"
                    font.pixelSize: 13
                    
                    // Text color based on state
                    color: {
                        if (modelData.urgent) {
                            return ThemeManager.bgBase  // Dark text on red background
                        } else if (modelData.focused || modelData.active) {
                            return ThemeManager.bgBase  // Dark text on colored backgrounds
                        } else if (modelData.toplevels.length > 0) {
                            return ThemeManager.fgPrimary  // Normal text for occupied
                        } else {
                            return ThemeManager.fgTertiary  // Dim text for empty
                        }
                    }
                    
                    font.bold: modelData.focused || modelData.urgent
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            onClicked: {
                console.log("Switching to workspace", modelData.id)
                modelData.activate()  // Use the built-in activate method
            }
        }
    }
}
