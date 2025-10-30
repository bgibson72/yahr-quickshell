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
        color: iconButton.containsMouse ? 
            Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1) : 
            "transparent"
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
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
