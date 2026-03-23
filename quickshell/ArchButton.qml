import QtQuick
import Quickshell

Rectangle {
    id: archButton

    width: 40
    height: 35

    signal toggleLauncher()

    color: {
        if (mouseArea.pressed) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.45)
        if (mouseArea.containsMouse) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
        return "transparent"
    }

    radius: 6

    border.width: mouseArea.containsMouse || mouseArea.pressed ? 1 : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

    Text {
        anchors.centerIn: parent
        text: "󰣇"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 20
        color: mouseArea.containsMouse || mouseArea.pressed ? ThemeManager.fgPrimary : ThemeManager.accentBlue
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: archButton.toggleLauncher()
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }
}
