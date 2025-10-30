import QtQuick
import Quickshell

MouseArea {
    id: batteryArea
    
    property int batteryLevel: 100
    property bool charging: false
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: batteryText.width + 16
        height: parent.height - 10
        
        color: batteryArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Row {
            id: batteryText
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: {
                    let level = batteryArea.batteryLevel
                    if (level >= 95) return "󰁹"
                    else if (level >= 90) return "󰂂"
                    else if (level >= 80) return "󰂁"
                    else if (level >= 70) return "󰂀"
                    else if (level >= 60) return "󰁿"
                    else if (level >= 50) return "󰁾"
                    else if (level >= 40) return "󰁽"
                    else if (level >= 30) return "󰁼"
                    else if (level >= 20) return "󰁻"
                    else if (level >= 10) return "󰁺"
                    else return "󰂃"
                }
                font.family: "Symbols Nerd Font"
                font.pixelSize: ThemeManager.fontSizeIcon
                color: {
                    if (batteryArea.charging) return ThemeManager.accentGreen
                    else if (batteryArea.batteryLevel <= 15) return ThemeManager.accentRed
                    else if (batteryArea.batteryLevel <= 30) return ThemeManager.accentYellow
                    else return ThemeManager.accentGreen
                }
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Text {
                text: batteryArea.charging ? batteryArea.batteryLevel + "%" : ""
                font.family: "MapleMono NF"
                font.pixelSize: 12
                color: ThemeManager.accentGreen
                anchors.verticalCenter: parent.verticalCenter
                visible: batteryArea.charging
            }
        }
    }
}
