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
                text: staticWorkspaceButton.workspaceId.toString()
                font.family: "Sen"
                font.pixelSize: 13
                font.bold: staticWorkspaceButton.isCurrentWorkspace
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

            property bool isCurrentWorkspace: modelData.focused || modelData.active

            visible: modelData.id >= 5 && (modelData.toplevels.length > 0 || modelData.active || modelData.focused)

            width: visible ? 40 : 0
            height: 32
            opacity: visible ? 1.0 : 0.0

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10

            Rectangle {
                id: dynamicWorkspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                radius: 6

                color: {
                    if (dynamicWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                    if (dynamicWorkspaceButton.containsMouse) return Qt.rgba(1, 1, 1, 0.10)
                    return "transparent"
                }
                border.width: dynamicWorkspaceButton.isCurrentWorkspace || dynamicWorkspaceButton.containsMouse ? 1 : 0
                border.color: dynamicWorkspaceButton.isCurrentWorkspace
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
                id: dynamicWorkspaceText
                anchors.centerIn: dynamicWorkspaceRect
                text: dynamicWorkspaceButton.modelData.id.toString()
                font.family: "Sen"
                font.pixelSize: 13
                font.bold: dynamicWorkspaceButton.isCurrentWorkspace
                textFormat: Text.PlainText

                color: {
                    if (dynamicWorkspaceButton.modelData.urgent) return ThemeManager.accentRed
                    if (dynamicWorkspaceButton.isCurrentWorkspace) return ThemeManager.fgPrimary
                    if (dynamicWorkspaceButton.modelData.toplevels.length > 0) return ThemeManager.fgPrimary
                    return ThemeManager.fgTertiary
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
