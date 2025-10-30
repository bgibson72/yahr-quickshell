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
        anchors.fill: parent
        color: "transparent"
        
        Text {
            id: iconText
            anchors.centerIn: parent
            text: iconButton.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
            color: iconButton.containsMouse ? ThemeManager.accentBlue : ThemeManager.fgPrimary
            
            Component.onCompleted: {
                console.log("IconButton text:", iconButton.icon, "length:", iconButton.icon.length)
            }
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    

}
