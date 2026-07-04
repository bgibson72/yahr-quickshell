import QtQuick

// A fixed (non-pinnable, non-removable) utility icon appended to the dock,
// used for things like opening the Settings widget or the Trash panel —
// distinct from the user's pinned-app icons.
Item {
    id: utilityButton

    property int iconSize: 48
    property string glyph: ""
    property string tooltip: ""
    property string dockPosition: "bottom"  // "top" | "bottom" | "left" | "right"
    signal clicked()

    width: iconSize
    height: iconSize

    property bool hovered: utilityArea.containsMouse

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: utilityButton.hovered ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    scale: utilityButton.hovered ? 1.12 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    Text {
        anchors.centerIn: parent
        text: utilityButton.glyph
        font.family: "Symbols Nerd Font"
        font.pixelSize: utilityButton.iconSize * 0.5
        color: ThemeManager.fgPrimary
    }

    // Tooltip (mirrors Dock.qml's pinned-item tooltip positioning)
    Rectangle {
        visible: utilityButton.hovered && utilityButton.tooltip !== ""
        color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.95)
        radius: 6
        width: tooltipText.implicitWidth + 16
        height: tooltipText.implicitHeight + 8
        anchors.horizontalCenter: parent.horizontalCenter
        y: utilityButton.dockPosition === "bottom" ? -height - 8
           : utilityButton.dockPosition === "top" ? parent.height + 8
           : 0
        x: utilityButton.dockPosition === "left" ? parent.width + 8
           : utilityButton.dockPosition === "right" ? -width - 8
           : (width - parent.width) / -2

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: utilityButton.tooltip
            font.family: ThemeManager.uiFont
            font.pixelSize: 11
            color: ThemeManager.fgPrimary
        }
    }

    MouseArea {
        id: utilityArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: utilityButton.clicked()
    }
}
