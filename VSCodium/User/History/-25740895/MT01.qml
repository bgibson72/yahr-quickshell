import QtQuick

MouseArea {
    id: iconButton
    
    property string icon: ""
    property string tooltip: ""
    
    width: 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    enabled: true
    z: 10
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        Text {
            anchors.centerIn: parent
            text: iconButton.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
            color: iconButton.containsMouse ? ThemeManager.accentBlue : ThemeManager.fgPrimary
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    
    onPressed: {
        console.log("IconButton pressed:", icon, tooltip)
    }
    
    onClicked: {
        console.log("IconButton clicked:", icon, tooltip)
    }
}
