import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: systemTray
    
    property string networkType: "ethernet"
    property int volume: 50
    property bool muted: false
    property int batteryLevel: 100
    property bool charging: false
    property bool batteryDetailsShown: false
    
    width: trayRow.width + 20
    height: 42
    
    color: "transparent"
    
    Component.onCompleted: {
        updateVolume()
        updateBattery()
    }
    
    // Shared background for all tray icons
    Rectangle {
        anchors.fill: parent
        color: ThemeManager.surface0
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 8
        
        // Network Icon - clickable
        Item {
            width: 35
            height: 32
            
            scale: networkMouseArea.pressed ? 0.92 : 1.0
            opacity: networkMouseArea.pressed ? 0.8 : 1.0
            
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
            
            MouseArea {
                id: networkMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    console.log("Network icon clicked - launching nmtui")
                    Quickshell.execDetached(["kitty", "--class", "kitty-nmtui", "-e", "nmtui"])
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: {
                    if (systemTray.networkType === "wifi") return "󰤨"
                    else if (systemTray.networkType === "ethernet") return "󰈀"
                    else return "󰌙"
                }
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: {
                    if (systemTray.networkType === "wifi") return ThemeManager.accentGreen
                    else if (systemTray.networkType === "ethernet") return ThemeManager.accentBlue
                    else return ThemeManager.accentRed
                }
            }
        }
        
        // Audio Icon - clickable
        Item {
            width: 35
            height: 32
            
            scale: audioMouseArea.pressed ? 0.92 : 1.0
            opacity: audioMouseArea.pressed ? 0.8 : 1.0
            
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
            
            MouseArea {
                id: audioMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    console.log("Audio icon clicked - launching pavucontrol")
                    Quickshell.execDetached(["pavucontrol"])
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: {
                    if (systemTray.muted) return "󰝟"
                    else if (systemTray.volume >= 66) return "󰕾"
                    else if (systemTray.volume >= 33) return "󰖀"
                    else return "󰕿"
                }
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: systemTray.muted ? ThemeManager.border0 : ThemeManager.accentYellow
            }
        }
        
        // Battery Icon - clickable to show details
        Item {
            id: batteryItem
            width: systemTray.batteryDetailsShown ? 120 : 35  // Expand to show full details
            height: 32
            
            scale: batteryMouseArea.pressed ? 0.92 : 1.0
            opacity: batteryMouseArea.pressed ? 0.8 : 1.0
            
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            
            MouseArea {
                id: batteryMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    console.log("Battery icon clicked - toggling details")
                    systemTray.batteryDetailsShown = !systemTray.batteryDetailsShown
                }
            }
            
            Row {
                id: batteryRow
                anchors.centerIn: parent
                spacing: 6
                
                Text {
                    text: {
                        let level = systemTray.batteryLevel
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
                        if (systemTray.charging) return ThemeManager.accentGreen
                        else if (systemTray.batteryLevel >= 50) return ThemeManager.accentGreen
                        else if (systemTray.batteryLevel >= 20) return ThemeManager.accentYellow
                        else return ThemeManager.accentRed
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: systemTray.batteryLevel + "% " + (systemTray.charging ? "AC" : "BAT")
                    font.family: "MapleMono NF"
                    font.pixelSize: 12
                    color: systemTray.charging ? ThemeManager.accentGreen : ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                    visible: systemTray.batteryDetailsShown
                    opacity: systemTray.batteryDetailsShown ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
    }
}