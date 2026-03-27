import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: powerButton
    width: 64
    height: 64
    radius: 32
    color: mouseArea.containsPress ? Qt.rgba(buttonFg.r, buttonFg.g, buttonFg.b, 0.25) :
           mouseArea.containsMouse ? Qt.rgba(buttonFg.r, buttonFg.g, buttonFg.b, 0.15) :
                                     Qt.rgba(buttonBg.r, buttonBg.g, buttonBg.b, 0.35)
    border.width: 1
    border.color: Qt.rgba(buttonFg.r, buttonFg.g, buttonFg.b, mouseArea.containsMouse ? 0.35 : 0.18)

    property string icon: ""
    property alias text: toolTip.text
    property color buttonBg: "#313244"
    property color buttonFg: "#cdd6f4"
    signal clicked()
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    Text {
        anchors.centerIn: parent
        text: getIconText()
        font.family: "MapleMono NF"
        font.pixelSize: 24
        color: mouseArea.containsPress ? Qt.darker(buttonFg, 1.2) : buttonFg
        
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
