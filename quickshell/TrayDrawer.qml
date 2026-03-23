import QtQuick
import Quickshell

Item {
    id: trayDrawer

    property bool expanded: false

    signal toggleClipboard()
    signal toggleControlCenter()

    height: 35
    width: contentArea.width + (contentArea.width > 0 ? 4 : 0) + 32

    // Content area — clipping container, anchored left of the toggle button
    Item {
        id: contentArea
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: trayDrawer.expanded ? contentRow.width : 0
        clip: true

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Row {
            id: contentRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            ClipboardManager {
                onToggleClipboard: trayDrawer.toggleClipboard()
            }
            Updates {}
            SystemTray {
                onToggleControlCenter: trayDrawer.toggleControlCenter()
            }
        }
    }

    // Toggle button — always visible on the right
    Rectangle {
        id: toggleBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: 6

        color: toggleMouse.pressed
            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.45)
            : toggleMouse.containsMouse
                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                : Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.20)

        border.width: toggleMouse.containsMouse || toggleMouse.pressed ? 1 : 0
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: trayDrawer.expanded ? "\uf054" : "\uf053"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: ThemeManager.fgPrimary
        }

        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: trayDrawer.expanded = !trayDrawer.expanded
        }
    }
}
