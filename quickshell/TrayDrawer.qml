import QtQuick
import Quickshell

Item {
    id: trayDrawer

    property bool showTray: true

    signal toggleClipboard()
    signal toggleControlCenter()

    height: 35
    width: contentRow.width
    visible: trayDrawer.showTray

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
