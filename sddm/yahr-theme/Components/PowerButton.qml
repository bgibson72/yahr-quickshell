import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: powerButton
    width: 64
    height: 64
    
    property string icon: ""
    property string text: ""
    
    ToolTip.visible: hovered
    ToolTip.text: text
    ToolTip.delay: 500
    
    contentItem: Text {
        text: getIconText()
        font.family: "MapleMono NF"
        font.pixelSize: 24
        color: powerButton.down ? Qt.darker("#d9d7ce", 1.2) : "#d9d7ce"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    background: Rectangle {
        radius: 32
        color: powerButton.down ? Qt.lighter("#1e2030", 1.3) :
               powerButton.hovered ? Qt.lighter("#1e2030", 1.2) : "#1e2030"
        opacity: 0.95
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
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
