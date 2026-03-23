import QtQuick
import Quickshell

Rectangle {
    id: powerButton

    width: 40
    height: 35

    signal togglePowerMenu()

    color: {
        if (mouseArea.pressed) return Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.45)
        if (mouseArea.containsMouse) return Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.30)
        return "transparent"
    }

    radius: 6

    border.width: mouseArea.containsMouse || mouseArea.pressed ? 1 : 0
    border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.55)

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 18
        color: mouseArea.containsMouse || mouseArea.pressed ? ThemeManager.fgPrimary : ThemeManager.accentRed
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            console.log("Power button clicked, opening power menu")
            powerButton.togglePowerMenu()
        }
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }
}
