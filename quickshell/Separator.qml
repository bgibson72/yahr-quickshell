import QtQuick

Item {
    width: 20
    height: 35
    
    Text {
        anchors.centerIn: parent
        text: "|"
        font.family: ThemeManager.uiFont
        font.pixelSize: 13
        color: Qt.rgba(1, 1, 1, 0.18)
    }
}
