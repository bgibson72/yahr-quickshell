import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: workspaceBar
    spacing: 4

    property int minWorkspaces: 4

    property int displayCount: {
        let max = workspaceBar.minWorkspaces
        // Always show the currently active workspace, even if empty
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
            let activeId = Hyprland.focusedMonitor.activeWorkspace.id
            if (activeId > max) max = activeId
        }
        // Also keep any workspace with windows, even if not currently active
        for (var i = 0; i < Hyprland.workspaces.length; i++) {
            let ws = Hyprland.workspaces[i]
            if (ws.id > max && ws.toplevels.length > 0) {
                max = ws.id
            }
        }
        return max
    }

    Repeater {
        model: workspaceBar.displayCount

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
            property bool isCurrentWorkspace: {
                let ws = hyprWorkspace
                if (ws && (ws.focused || ws.active)) return true
                if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
                    return Hyprland.focusedMonitor.activeWorkspace.id === workspaceId
                }
                return false
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
                radius: 6

                color: {
                    if (staticWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                    if (staticWorkspaceButton.containsMouse) return Qt.rgba(1, 1, 1, 0.10)
                    return "transparent"
                }
                border.width: staticWorkspaceButton.isCurrentWorkspace || staticWorkspaceButton.containsMouse ? 1 : 0
                border.color: staticWorkspaceButton.isCurrentWorkspace
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                    : Qt.rgba(1, 1, 1, 0.18)

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
                text: ThemeManager.workspaceStyle === "dots" ? "\uf444" : staticWorkspaceButton.workspaceId.toString()
                font.family: ThemeManager.workspaceStyle === "dots" ? "Symbols Nerd Font" : ThemeManager.uiFont
                font.pixelSize: ThemeManager.workspaceStyle === "dots" ? 12 : 13
                font.bold: ThemeManager.workspaceStyle !== "dots" && staticWorkspaceButton.isCurrentWorkspace
                textFormat: Text.PlainText

                color: {
                    let ws = staticWorkspaceButton.hyprWorkspace
                    if (ws && ws.urgent) return ThemeManager.accentRed
                    if (staticWorkspaceButton.isCurrentWorkspace) return ThemeManager.fgPrimary
                    if (ws && ws.toplevels.length > 0) return ThemeManager.fgPrimary
                    return ThemeManager.fgTertiary
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            onClicked: {
                console.log("Workspace", staticWorkspaceButton.workspaceId, "clicked")
                Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + staticWorkspaceButton.workspaceId + "})"])
            }
        }
    }
}
