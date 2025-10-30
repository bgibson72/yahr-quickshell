import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: systemTray
    
    property string networkType: "ethernet"
    property int signalStrength: 100  // 0-100 for wifi signal strength
    property real uploadSpeed: 0.0  // KB/s
    property real downloadSpeed: 0.0  // KB/s
    property int volume: 50
    property bool muted: false
    property int batteryLevel: 100
    property bool charging: false
    
    // Settings for showing details
    property bool showBatteryDetails: false
    property bool showVolumeDetails: false
    property bool showNetworkDetails: false
    
    onShowBatteryDetailsChanged: console.log("🔧 SystemTray showBatteryDetails changed to:", showBatteryDetails)
    onShowVolumeDetailsChanged: console.log("🔧 SystemTray showVolumeDetails changed to:", showVolumeDetails)
    onShowNetworkDetailsChanged: console.log("🔧 SystemTray showNetworkDetails changed to:", showNetworkDetails)
    
    width: trayRow.width + 20
    height: 35
    
    color: "transparent"
    
    Component.onCompleted: {
        updateVolume()
        updateBattery()
        updateNetwork()
        updateNetworkTraffic()
        loadSettings()
    }
    
    // Load settings
    function loadSettings() {
        settingsLoader.running = true
    }
    
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                settingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.systemTray) {
                        systemTray.showBatteryDetails = settings.systemTray.showBatteryDetails === true
                        systemTray.showVolumeDetails = settings.systemTray.showVolumeDetails === true
                        systemTray.showNetworkDetails = settings.systemTray.showNetworkDetails === true
                        console.log("SystemTray settings loaded - battery:", systemTray.showBatteryDetails, "volume:", systemTray.showVolumeDetails, "network:", systemTray.showNetworkDetails)
                    }
                } catch (e) {
                    console.error("Failed to parse settings for SystemTray:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
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
            width: systemTray.showNetworkDetails ? 140 : 35
            height: 32
            
            scale: networkMouseArea.pressed ? 0.92 : 1.0
            opacity: networkMouseArea.pressed ? 0.8 : 1.0
            
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            
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
            
            Row {
                anchors.centerIn: parent
                spacing: 6
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (systemTray.networkType === "wifi") {
                            // Signal strength icons for wifi
                            if (systemTray.signalStrength >= 80) return "󰤨"  // Excellent
                            else if (systemTray.signalStrength >= 60) return "󰤥"  // Good
                            else if (systemTray.signalStrength >= 40) return "󰤢"  // Fair
                            else if (systemTray.signalStrength >= 20) return "󰤟"  // Weak
                            else return "󰤯"  // No signal
                        }
                        else if (systemTray.networkType === "ethernet") return "󰈀"
                        else return "󰌙"  // Disconnected
                    }
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: ThemeManager.accentBlue
                }
                
                Text {
                    id: networkDetailsText
                    anchors.verticalCenter: parent.verticalCenter
                    text: "↓" + systemTray.downloadSpeed.toFixed(1) + " ↑" + systemTray.uploadSpeed.toFixed(1)
                    font.family: "MapleMono NF"
                    font.pixelSize: 10
                    color: ThemeManager.fgPrimary
                    visible: systemTray.showNetworkDetails
                    opacity: systemTray.showNetworkDetails ? 1.0 : 0.0
                    
                    Component.onCompleted: console.log("🌐 Network details text created, visible:", visible, "opacity:", opacity)
                    onVisibleChanged: console.log("🌐 Network details visible changed to:", visible)
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
        
        // Audio Icon - clickable
        Item {
            width: systemTray.showVolumeDetails ? 85 : 35
            height: 32
            
            scale: audioMouseArea.pressed ? 0.92 : 1.0
            opacity: audioMouseArea.pressed ? 0.8 : 1.0
            
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            
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
            
            Row {
                anchors.centerIn: parent
                spacing: 6
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (systemTray.muted) return "󰝟"
                        else if (systemTray.volume >= 66) return "󰕾"
                        else if (systemTray.volume >= 33) return "󰖀"
                        else return "󰕿"
                    }
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: ThemeManager.accentBlue
                }
                
                Text {
                    id: volumeDetailsText
                    anchors.verticalCenter: parent.verticalCenter
                    text: systemTray.muted ? "Muted" : systemTray.volume + "%"
                    font.family: "MapleMono NF"
                    font.pixelSize: 11
                    color: ThemeManager.fgPrimary
                    visible: systemTray.showVolumeDetails
                    opacity: systemTray.showVolumeDetails ? 1.0 : 0.0
                    
                    Component.onCompleted: console.log("🔊 Volume details text created, visible:", visible, "opacity:", opacity)
                    onVisibleChanged: console.log("🔊 Volume details visible changed to:", visible)
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
        
        // Battery Icon - clickable to show details
        Item {
            id: batteryItem
            width: systemTray.showBatteryDetails ? 120 : 35  // Expand to show full details
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
                    console.log("Battery icon clicked - toggle disabled, use settings")
                }
            }
            
            Row {
                id: batteryRow
                anchors.centerIn: parent
                spacing: 6
                
                Text {
                    text: {
                        let level = systemTray.batteryLevel
                        if (systemTray.charging) return "󰂄"  // Charging icon
                        else if (level >= 95) return "󰁹"
                        else if (level >= 90) return "󰂂"
                        else if (level >= 80) return "󰂁"
                        else if (level >= 70) return "󰂀"
                        else if (level >= 60) return "󰁿"
                        else if (level >= 50) return "󰁾"
                        else if (level >= 40) return "󰁽"
                        else if (level >= 30) return "󰁼"
                        else if (level >= 20) return "󰁻"
                        else if (level >= 10) return "󰁺"
                        else return "󰂃"  // Low battery icon
                    }
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: ThemeManager.accentBlue
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: systemTray.batteryLevel + "% " + (systemTray.charging ? "AC" : "BAT")
                    font.family: "MapleMono NF"
                    font.pixelSize: 12
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                    visible: systemTray.showBatteryDetails
                    opacity: systemTray.showBatteryDetails ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
    }
    
    // Volume monitoring
    function updateVolume() {
        volumeProcess.running = true
    }
    
    Process {
        id: volumeProcess
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                systemTray.volume = parseInt(data.trim()) || 0
                console.log("Volume level:", systemTray.volume)
            }
        }
    }
    
    Process {
        id: muteProcess
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                systemTray.muted = (data.trim() === "1")
                console.log("Mute status:", data.trim(), "muted:", systemTray.muted)
            }
        }
        
        onExited: {
            // After getting mute status, also update volume
            volumeProcess.running = true
        }
    }
    
    Timer {
        interval: 2000  // Check every 2 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            muteProcess.running = true
        }
    }
    
    // Battery monitoring
    function updateBattery() {
        batteryProcess.running = true
    }
    
    Process {
        id: batteryProcess
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo 100"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                systemTray.batteryLevel = parseInt(data.trim()) || 100
            }
        }
        
        onExited: {
            chargingProcess.running = true
        }
    }
    
    Process {
        id: chargingProcess
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | grep -q Charging && echo 1 || echo 0"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                systemTray.charging = (data.trim() === "1")
            }
        }
    }
    
    Timer {
        interval: 5000  // Check every 5 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            batteryProcess.running = true
        }
    }
    
    // Network monitoring
    function updateNetwork() {
        networkTypeProcess.running = true
    }
    
    Process {
        id: networkTypeProcess
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE connection show --active | grep ':activated' | head -1 | cut -d: -f1"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                var type = data.trim().toLowerCase()
                console.log("Network type detected:", type)
                
                if (type.includes("802-11-wireless") || type.includes("wireless") || type.includes("wifi")) {
                    systemTray.networkType = "wifi"
                    // If wifi, also get signal strength
                    signalStrengthProcess.running = true
                } else if (type.includes("802-3-ethernet") || type.includes("ethernet")) {
                    systemTray.networkType = "ethernet"
                    systemTray.signalStrength = 100  // Full for ethernet
                } else if (type === "") {
                    systemTray.networkType = "disconnected"
                    systemTray.signalStrength = 0
                } else {
                    // Unknown type, treat as ethernet
                    systemTray.networkType = "ethernet"
                    systemTray.signalStrength = 100
                }
            }
        }
    }
    
    Process {
        id: signalStrengthProcess
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SIGNAL dev wifi | grep '^yes' | cut -d: -f2"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                var signal = parseInt(data.trim()) || 0
                systemTray.signalStrength = signal
                console.log("WiFi signal strength:", signal)
            }
        }
    }
    
    Timer {
        interval: 3000  // Check network every 3 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            networkTypeProcess.running = true
        }
    }
    
    // Network traffic monitoring
    property real lastRxBytes: 0
    property real lastTxBytes: 0
    property real lastTrafficCheck: 0
    
    function updateNetworkTraffic() {
        trafficProcess.running = true
    }
    
    Process {
        id: trafficProcess
        command: ["sh", "-c", `
            interface=$(ip route | grep default | awk '{print $5}' | head -1)
            if [ -n "$interface" ]; then
                rx=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
                tx=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
                echo "$rx $tx"
            else
                echo "0 0"
            fi
        `]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(" ")
                if (parts.length >= 2) {
                    var rxBytes = parseFloat(parts[0])
                    var txBytes = parseFloat(parts[1])
                    var currentTime = Date.now()
                    
                    if (systemTray.lastTrafficCheck > 0) {
                        var timeDiff = (currentTime - systemTray.lastTrafficCheck) / 1000.0  // seconds
                        if (timeDiff > 0) {
                            // Calculate speeds in KB/s
                            var rxDiff = (rxBytes - systemTray.lastRxBytes) / 1024.0
                            var txDiff = (txBytes - systemTray.lastTxBytes) / 1024.0
                            
                            systemTray.downloadSpeed = rxDiff / timeDiff
                            systemTray.uploadSpeed = txDiff / timeDiff
                        }
                    }
                    
                    systemTray.lastRxBytes = rxBytes
                    systemTray.lastTxBytes = txBytes
                    systemTray.lastTrafficCheck = currentTime
                }
            }
        }
    }
    
    Timer {
        interval: 2000  // Update traffic every 2 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            updateNetworkTraffic()
        }
    }
}