import QtQuick

// "+" button appended to the dock's pinned app list, opens the app picker
// used to pin new applications.
Item {
    id: addButton

    property int iconSize: 48
    signal clicked()

    width: iconSize
    height: iconSize

    property bool hovered: addArea.containsMouse

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: addButton.hovered ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, addButton.hovered ? 0.25 : 0.12)
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: "+"
        font.pixelSize: addButton.iconSize * 0.5
        font.weight: Font.Light
        color: ThemeManager.fgSecondary
    }

    MouseArea {
        id: addArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: addButton.clicked()
    }
}
