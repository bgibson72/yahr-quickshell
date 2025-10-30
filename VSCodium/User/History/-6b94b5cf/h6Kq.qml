import QtQuick
import Quickshell

MouseArea {
    id: batteryArea
    
    property int batteryLevel: 0
    property bool charging: false
    property bool plugged: false
    
    width: batteryText.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 10
        color: batteryArea.containsMouse ? "#33467c" : "#292e42"
        radius: 0
        
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 8
            radius: 8
            color: parent.color
        }
        
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
                font.pixelSize: 16
                color: {
                    if (batteryArea.charging || batteryArea.plugged) return "#9ece6a"
                    else if (batteryArea.batteryLevel <= 15) return "#f7768e"
                    else if (batteryArea.batteryLevel <= 30) return "#e0af68"
                    else return "#9ece6a"
                }
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            Text {
                text: (batteryArea.charging || batteryArea.plugged) ? batteryArea.batteryLevel + "%" : ""
                font.family: "MapleMono NF"
                font.pixelSize: 12
                color: "#9ece6a"
                anchors.verticalCenter: parent.verticalCenter
                visible: batteryArea.charging || batteryArea.plugged
            }
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            // Check battery status
            let proc = Process.exec("sh", ["-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1"])
            proc.finished.connect(() => {
                batteryArea.batteryLevel = parseInt(proc.stdout.trim()) || 0
            })
            
            let statusProc = Process.exec("sh", ["-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"])
            statusProc.finished.connect(() => {
                let status = statusProc.stdout.trim()
                batteryArea.charging = status === "Charging"
                batteryArea.plugged = status === "Full" || status === "Not charging"
            })
        }
    }
}
