import QtQuick

MouseArea {
    id: iconButton
    
    property string icon: ""
    property string tooltip: ""
    
    width: 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        Text {
            anchors.centerIn: parent
            text: iconButton.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: iconButton.containsMouse ? "#7aa2f7" : "#c0caf5"
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
}
