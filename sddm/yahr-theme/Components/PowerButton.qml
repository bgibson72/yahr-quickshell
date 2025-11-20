import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: powerButton
    width: 64
    height: 64
    radius: 32
    color: mouseArea.containsPress ? Qt.lighter("#1e2030", 1.3) :
           mouseArea.containsMouse ? Qt.lighter("#1e2030", 1.2) : "#1e2030"
    opacity: 0.95
    
    property string icon: ""
    property alias text: toolTip.text
    signal clicked()
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Text {
        anchors.centerIn: parent
        text: getIconText()
        font.family: "MapleMono NF"
        font.pixelSize: 24
        color: mouseArea.containsPress ? Qt.darker("#d9d7ce", 1.2) : "#d9d7ce"
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: powerButton.clicked()
    }
    
    ToolTip {
        id: toolTip
        visible: mouseArea.containsMouse
        delay: 500
    }
    
    function getIconText() {
        switch(icon) {
            case "suspend":
                return "󰒲" // nf-md-power_sleep
            case "reboot":
                return "󰜉" // nf-md-restart
            case "shutdown":
                return "󰐥" // nf-md-power
            default:
                return "?"
        }
    }
}
