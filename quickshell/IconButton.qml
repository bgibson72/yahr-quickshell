import QtQuick

MouseArea {
    id: iconButton
    
    property string icon: ""
    property string tooltip: ""
    
    width: 32
    height: 32
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    enabled: true
    z: 10
    
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 4
        height: parent.height - 8
        color: iconButton.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
        radius: 6
        border.width: iconButton.containsMouse ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.18)

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        Behavior on border.width {
            NumberAnimation { duration: 200 }
        }
        
        Text {
            id: iconText
            anchors.centerIn: parent
            text: iconButton.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
            color: ThemeManager.fgPrimary
            
            Component.onCompleted: {
                console.log("IconButton text:", iconButton.icon, "length:", iconButton.icon.length)
            }
        }
    }
    

}
