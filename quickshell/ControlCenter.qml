import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 420
    height: 790
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    clip: true
    
    property bool isVisible: false
    signal requestClose()
    
    // Properties from system
    property string networkType: "wifi"
    property int signalStrength: 100
    property string networkName: "Unknown"
    property string downloadRate: "0 KB/s"
    property string uploadRate: "0 KB/s"
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property real lastRxBytes: 0
    property real lastTxBytes: 0
    property real lastTrafficCheck: 0
    property int volume: 50
    property bool muted: false
    property int batteryLevel: 100
    property bool charging: false
    property bool acOnline: false
    property string batteryTimeRemaining: ""
    property bool bluetoothEnabled: false
    property var bluetoothDevices: []
    property int brightness: 50
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Header
        Item {
            width: parent.width
            height: 44
            
            Text {
                id: gearIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "⚙️"
                font.pixelSize: 24
            }
            
            Text {
                anchors.left: gearIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "Control Center"
                font.family: "MapleMono NF"
                font.pixelSize: 20
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
            }
            
            // Close button
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                radius: 8
                color: closeMouseArea.containsMouse ? Qt.darker(ThemeManager.accentRed, 1.2) : ThemeManager.accentRed
                z: 1000
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    propagateComposedEvents: false
                    onClicked: {
                        console.log("Close button clicked")
                        root.requestClose()
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 18
                    color: ThemeManager.bgBase
                }
            }
        }
        
        // WiFi Section
        Rectangle {
            width: parent.width
            height: 140
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Item {
                    width: parent.width
                    height: 44
                    
                    Row {
                        width: parent.width - 60
                        spacing: 12
                        
                        Text {
                            text: {
                                if (root.networkType === "wifi") {
                                    if (root.signalStrength >= 80) return "󰤨"
                                    else if (root.signalStrength >= 60) return "󰤥"
                                    else if (root.signalStrength >= 40) return "󰤢"
                                    else if (root.signalStrength >= 20) return "󰤟"
                                    else return "󰤯"
                                } else if (root.networkType === "ethernet") {
                                    return "󰈀"
                                } else {
                                    return "󰌙"
                                }
                            }
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 28
                            color: ThemeManager.accentGreen
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: root.networkType === "wifi" ? "Wi-Fi" : root.networkType === "ethernet" ? "Ethernet" : "Disconnected"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: root.networkName
                                font.family: "MapleMono NF"
                                font.pixelSize: 13
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
                    
                    // Wi-Fi toggle - positioned absolutely in top right
                    Rectangle {
                        width: 48
                        height: 24
                        radius: 12
                        color: root.networkType === "wifi" ? ThemeManager.accentGreen : ThemeManager.surface0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: ThemeManager.fgPrimary
                            x: root.networkType === "wifi" ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Behavior on x { NumberAnimation { duration: 200 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.networkType === "wifi") {
                                    wifiDisableProcess.running = true
                                } else {
                                    wifiEnableProcess.running = true
                                }
                            }
                        }
                    }
                }
                
                // Network stats row
                Row {
                    width: parent.width
                    spacing: 16
                    
                    Text {
                        text: root.networkType === "wifi" ? root.signalStrength + "%" : ""
                        font.family: "MapleMono NF"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: ThemeManager.accentBlue
                        visible: root.networkType === "wifi"
                    }
                    
                    Text {
                        text: "↓ " + root.downloadRate
                        font.family: "MapleMono NF"
                        font.pixelSize: 11
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        text: "↑ " + root.uploadRate
                        font.family: "MapleMono NF"
                        font.pixelSize: 11
                        color: ThemeManager.fgSecondary
                    }
                }
                
                // Network settings button
                Rectangle {
                    width: parent.width
                    height: 32
                    color: netSettingsMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                    radius: 8
                    
                    MouseArea {
                        id: netSettingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Opening network settings")
                            // Add window rule for centering, then launch
                            Quickshell.execDetached(["hyprctl", "dispatch", "exec", "[float;center;size 800 600] nm-connection-editor"])
                            root.requestClose()
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Network Settings"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        color: ThemeManager.fgPrimary
                    }
                }
            }
        }
        
        // Audio Section
        Rectangle {
            width: parent.width
            height: 136
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: root.muted ? "󰝟" : root.volume >= 70 ? "󰕾" : root.volume >= 30 ? "󰖀" : "󰕿"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 28
                        color: root.muted ? ThemeManager.fgTertiary : ThemeManager.accentBlue
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "Volume"
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                        }
                        
                        Text {
                            text: root.muted ? "Muted" : root.volume + "%"
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // Volume slider
                Rectangle {
                    width: parent.width
                    height: 8
                    color: ThemeManager.surface0
                    radius: 4
                    
                    Rectangle {
                        width: parent.width * (root.volume / 100)
                        height: parent.height
                        color: root.muted ? ThemeManager.fgTertiary : ThemeManager.accentBlue
                        radius: 4
                    }
                }
                
                // Volume controls
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 32
                        color: volDownMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                        radius: 8
                        
                        MouseArea {
                            id: volDownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volumeDownProcess.running = true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            font.pixelSize: 20
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 32
                        color: volMuteMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                        radius: 8
                        
                        MouseArea {
                            id: volMuteMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volumeMuteProcess.running = true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.muted ? "󰝟" : "󰖁"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 32
                        color: volUpMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                        radius: 8
                        
                        MouseArea {
                            id: volUpMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volumeUpProcess.running = true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 20
                            color: ThemeManager.fgPrimary
                        }
                    }
                }
            }
        }
        
        // Bluetooth Section
        Rectangle {
            width: parent.width
            height: Math.max(116, 80 + (bluetoothDevicesColumn.children.length * 28))
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Item {
                    width: parent.width
                    height: 44
                    
                    Row {
                        width: parent.width - 60
                        spacing: 12
                        
                        Text {
                            text: "󰂯"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 28
                            color: root.bluetoothEnabled ? ThemeManager.accentBlue : ThemeManager.fgTertiary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "Bluetooth"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: root.bluetoothEnabled ? (root.bluetoothDevices.length > 0 ? root.bluetoothDevices.length + " device(s) connected" : "No devices connected") : "Off"
                                font.family: "MapleMono NF"
                                font.pixelSize: 13
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
                    
                    // Bluetooth toggle - positioned absolutely in top right
                    Rectangle {
                        width: 48
                        height: 24
                        radius: 12
                        color: root.bluetoothEnabled ? ThemeManager.accentBlue : ThemeManager.surface0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: ThemeManager.fgPrimary
                            x: root.bluetoothEnabled ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Behavior on x { NumberAnimation { duration: 200 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.bluetoothEnabled) {
                                    bluetoothDisableProcess.running = true
                                } else {
                                    bluetoothEnableProcess.running = true
                                }
                            }
                        }
                    }
                }
                
                // Connected devices list
                Column {
                    id: bluetoothDevicesColumn
                    width: parent.width
                    spacing: 4
                    visible: root.bluetoothDevices.length > 0
                    
                    Repeater {
                        model: root.bluetoothDevices
                        delegate: Text {
                            text: "  • " + modelData
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // Bluetooth manager button
                Rectangle {
                    width: parent.width
                    height: 32
                    color: btSettingsMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                    radius: 8
                    
                    MouseArea {
                        id: btSettingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Opening Bluetooth manager")
                            Quickshell.execDetached(["blueman-manager"])
                            root.requestClose()
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Bluetooth Settings"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        color: ThemeManager.fgPrimary
                    }
                }
            }
        }
        
        // Brightness Section
        Rectangle {
            width: parent.width
            height: 136
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: root.brightness >= 70 ? "󰃠" : root.brightness >= 40 ? "󰃟" : "󰃞"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 28
                        color: ThemeManager.accentYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "Brightness"
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                        }
                        
                        Text {
                            text: root.brightness + "%"
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // Brightness slider
                Rectangle {
                    width: parent.width
                    height: 8
                    color: ThemeManager.surface0
                    radius: 4
                    
                    Rectangle {
                        width: parent.width * (root.brightness / 100)
                        height: parent.height
                        color: ThemeManager.accentYellow
                        radius: 4
                    }
                }
                
                // Brightness controls
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 32
                        color: brightDownMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                        radius: 8
                        
                        MouseArea {
                            id: brightDownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                brightnessDownProcess.running = true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            font.pixelSize: 20
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 32
                        color: brightUpMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface0
                        radius: 8
                        
                        MouseArea {
                            id: brightUpMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                brightnessUpProcess.running = true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 20
                            color: ThemeManager.fgPrimary
                        }
                    }
                }
            }
        }
        
        // Battery/Power Section
        Rectangle {
            width: parent.width
            height: 116
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: {
                            if (root.acOnline && root.batteryLevel >= 99) return "󱐥"  // AC adapter icon
                            if (root.charging) return "󰂄"  // Charging
                            if (root.batteryLevel >= 90) return "󰁹"
                            if (root.batteryLevel >= 80) return "󰂂"
                            if (root.batteryLevel >= 70) return "󰂁"
                            if (root.batteryLevel >= 60) return "󰂀"
                            if (root.batteryLevel >= 50) return "󰁿"
                            if (root.batteryLevel >= 40) return "󰁾"
                            if (root.batteryLevel >= 30) return "󰁽"
                            if (root.batteryLevel >= 20) return "󰁼"
                            if (root.batteryLevel >= 10) return "󰁻"
                            return "󰁺"
                        }
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 28
                        color: root.acOnline ? ThemeManager.accentGreen :
                               root.charging ? ThemeManager.accentGreen : 
                               root.batteryLevel <= 20 ? ThemeManager.accentRed : ThemeManager.accentYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Column {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Row {
                            spacing: 8
                            
                            Text {
                                text: {
                                    if (root.acOnline && root.batteryLevel >= 99) return "AC Power"
                                    if (root.charging) return "Charging"
                                    return "Battery"
                                }
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                text: root.batteryLevel + "%"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // Battery time info
                        Text {
                            text: root.batteryTimeRemaining
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            color: ThemeManager.fgSecondary
                            visible: root.batteryTimeRemaining !== ""
                        }
                        
                        // Battery bar
                        Rectangle {
                            width: 240
                            height: 8
                            color: ThemeManager.surface0
                            radius: 4
                            
                            Rectangle {
                                width: parent.width * (root.batteryLevel / 100)
                                height: parent.height
                                color: root.acOnline ? ThemeManager.accentGreen :
                                       root.charging ? ThemeManager.accentGreen :
                                       root.batteryLevel <= 20 ? ThemeManager.accentRed : ThemeManager.accentYellow
                                radius: 4
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Volume control processes
    Process {
        id: volumeUpProcess
        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ +5%"]
        onRunningChanged: if (!running) volumeUpdateTimer.restart()
    }
    
    Process {
        id: volumeDownProcess
        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ -5%"]
        onRunningChanged: if (!running) volumeUpdateTimer.restart()
    }
    
    Process {
        id: volumeMuteProcess
        running: false
        command: ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
        onRunningChanged: if (!running) volumeUpdateTimer.restart()
    }
    
    // Delay timer for volume updates after button clicks
    Timer {
        id: volumeUpdateTimer
        interval: 100
        repeat: false
        onTriggered: updateVolume()
    }
    
    // Update functions
    Timer {
        interval: 1000
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("ControlCenter Timer triggered - isVisible:", root.isVisible)
            updateVolume()
            updateBattery()
            updateNetwork()
            updateBluetooth()
            updateBrightness()
        }
    }
    
    function updateVolume() {
        volumeLevelProcess.running = true
    }
    
    Process {
        id: volumeLevelProcess
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                root.volume = parseInt(data.trim()) || 0
            }
        }
        
        onExited: {
            // After getting volume, check mute status
            volumeMuteStatusProcess.running = true
        }
    }
    
    Process {
        id: volumeMuteStatusProcess
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                root.muted = (data.trim() === "1")
            }
        }
    }
    
    function updateBattery() {
        console.log("ControlCenter updateBattery called")
        batteryCheckProcess.running = true
    }
    
    Process {
        id: batteryCheckProcess
        command: ["sh", "-c", `
            BAT_PATH=$(echo /sys/class/power_supply/BAT* 2>/dev/null | awk '{print $1}')
            if [ -n "$BAT_PATH" ] && [ -d "$BAT_PATH" ]; then
                LEVEL=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo 100)
                STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")
                
                AC_ONLINE=0
                for ac_path in /sys/class/power_supply/AC* /sys/class/power_supply/ACAD /sys/class/power_supply/ADP*; do
                    if [ -f "$ac_path/online" ]; then
                        AC_ONLINE=$(cat "$ac_path/online" 2>/dev/null || echo 0)
                        break
                    fi
                done
                
                echo "$LEVEL|$STATUS|$AC_ONLINE"
            else
                echo "100|Unknown|0"
            fi
        `]
        running: false
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { batteryCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let parts = buffer.trim().split('|')
                console.log("ControlCenter battery check:", parts.length, "parts:", JSON.stringify(parts))
                if (parts.length >= 3) {
                    root.batteryLevel = parseInt(parts[0]) || 100
                    root.charging = parts[1].includes("Charging")
                    root.acOnline = parts[2] === "1"
                    console.log("ControlCenter battery - Level:", root.batteryLevel, "Charging:", root.charging, "AC:", root.acOnline)
                    
                    // Calculate time remaining/until full
                    if (root.charging || !root.acOnline) {
                        batteryTimeProcess.running = true
                    } else if (root.acOnline && root.batteryLevel >= 99) {
                        root.batteryTimeRemaining = "Fully charged"
                    } else {
                        root.batteryTimeRemaining = ""
                    }
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: batteryTimeProcess
        command: ["sh", "-c", `
            BAT_PATH=$(echo /sys/class/power_supply/BAT* 2>/dev/null | awk '{print $1}')
            if [ -n "$BAT_PATH" ] && [ -d "$BAT_PATH" ]; then
                STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")
                
                if [ -f "$BAT_PATH/current_now" ] && [ -f "$BAT_PATH/charge_now" ]; then
                    CURRENT=$(cat "$BAT_PATH/current_now" 2>/dev/null || echo 0)
                    CHARGE=$(cat "$BAT_PATH/charge_now" 2>/dev/null || echo 0)
                    FULL=$(cat "$BAT_PATH/charge_full" 2>/dev/null || echo $CHARGE)
                    
                    if [ "$CURRENT" -gt 0 ] 2>/dev/null; then
                        if echo "$STATUS" | grep -q "Charging"; then
                            TIME_H=$(( ($FULL - $CHARGE) / $CURRENT ))
                            TIME_M=$(( (($FULL - $CHARGE) * 60 / $CURRENT) % 60 ))
                            echo "${TIME_H}h ${TIME_M}m until fully charged"
                        elif echo "$STATUS" | grep -q "Discharging"; then
                            TIME_H=$(( $CHARGE / $CURRENT ))
                            TIME_M=$(( ($CHARGE * 60 / $CURRENT) % 60 ))
                            echo "${TIME_H}h ${TIME_M}m remaining"
                        fi
                    fi
                fi
            fi
        `]
        running: false
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { batteryTimeProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.batteryTimeRemaining = buffer.trim()
                console.log("ControlCenter battery time:", root.batteryTimeRemaining)
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    function updateNetwork() {
        networkCheckProcess.running = true
    }
    
    Process {
        id: networkCheckProcess
        running: false
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,DEVICE,NAME connection show --active | head -1"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { networkCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let line = buffer.trim()
                if (line) {
                    let parts = line.split(':')
                    if (parts.length >= 4) {
                        root.networkType = parts[0].includes("wireless") || parts[0].includes("wifi") ? "wifi" : "ethernet"
                        root.networkName = parts[3] || "Connected"
                        
                        if (root.networkType === "wifi") {
                            signalCheckProcess.running = true
                        }
                    }
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: signalCheckProcess
        running: false
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d':' -f2"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { signalCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.signalStrength = parseInt(buffer.trim()) || 100
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
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
                    
                    if (root.lastTrafficCheck > 0) {
                        var timeDiff = (currentTime - root.lastTrafficCheck) / 1000.0  // seconds
                        if (timeDiff > 0) {
                            // Calculate speeds in KB/s
                            var rxDiff = (rxBytes - root.lastRxBytes) / 1024.0
                            var txDiff = (txBytes - root.lastTxBytes) / 1024.0
                            
                            root.downloadSpeed = rxDiff / timeDiff
                            root.uploadSpeed = txDiff / timeDiff
                            
                            // Format as KB/s or MB/s
                            if (root.downloadSpeed >= 1024) {
                                root.downloadRate = (root.downloadSpeed / 1024).toFixed(1) + " MB/s"
                            } else {
                                root.downloadRate = Math.round(root.downloadSpeed) + " KB/s"
                            }
                            
                            if (root.uploadSpeed >= 1024) {
                                root.uploadRate = (root.uploadSpeed / 1024).toFixed(1) + " MB/s"
                            } else {
                                root.uploadRate = Math.round(root.uploadSpeed) + " KB/s"
                            }
                        }
                    }
                    
                    root.lastRxBytes = rxBytes
                    root.lastTxBytes = txBytes
                    root.lastTrafficCheck = currentTime
                }
            }
        }
    }
    
    Timer {
        id: trafficTimer
        interval: 2000  // Update traffic every 2 seconds
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            trafficProcess.running = true
        }
    }
    
    // Wi-Fi toggle processes
    Process {
        id: wifiEnableProcess
        running: false
        command: ["sh", "-c", "nmcli radio wifi on"]
        onRunningChanged: if (!running) Qt.callLater(updateNetwork)
    }
    
    Process {
        id: wifiDisableProcess
        running: false
        command: ["sh", "-c", "nmcli radio wifi off"]
        onRunningChanged: if (!running) Qt.callLater(updateNetwork)
    }
    
    // Bluetooth functions
    function updateBluetooth() {
        bluetoothStatusProcess.running = true
    }
    
    Process {
        id: bluetoothStatusProcess
        running: false
        command: ["sh", "-c", "rfkill list bluetooth | grep 'Soft blocked:' | head -n1 | awk '{print $3}'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { bluetoothStatusProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                // rfkill returns "no" when NOT blocked (i.e., when enabled)
                root.bluetoothEnabled = buffer.trim() === "no"
                buffer = ""
                
                // If bluetooth is on, get connected devices
                if (root.bluetoothEnabled) {
                    bluetoothDevicesProcess.running = true
                } else {
                    root.bluetoothDevices = []
                }
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: bluetoothDevicesProcess
        running: false
        command: ["sh", "-c", "bluetoothctl devices Connected | awk '{$1=$2=\"\"; print substr($0,3)}'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { bluetoothDevicesProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let lines = buffer.trim().split('\n').filter(line => line.length > 0)
                root.bluetoothDevices = lines
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: bluetoothEnableProcess
        running: false
        command: ["sh", "-c", "rfkill unblock bluetooth"]
        onRunningChanged: if (!running) Qt.callLater(updateBluetooth)
    }
    
    Process {
        id: bluetoothDisableProcess
        running: false
        command: ["sh", "-c", "rfkill block bluetooth"]
        onRunningChanged: if (!running) Qt.callLater(updateBluetooth)
    }
    
    // Brightness functions
    function updateBrightness() {
        brightnessLevelProcess.running = true
    }
    
    Process {
        id: brightnessLevelProcess
        running: false
        command: ["sh", "-c", "brightnessctl -m | cut -d',' -f4 | tr -d '%'"]
        
        stdout: SplitParser {
            onRead: data => {
                root.brightness = parseInt(data.trim()) || 50
            }
        }
    }
    
    Process {
        id: brightnessUpProcess
        running: false
        command: ["sh", "-c", "brightnessctl set +5%"]
        onRunningChanged: if (!running) brightnessUpdateTimer.restart()
    }
    
    Process {
        id: brightnessDownProcess
        running: false
        command: ["sh", "-c", "brightnessctl set 5%-"]
        onRunningChanged: if (!running) brightnessUpdateTimer.restart()
    }
    
    // Delay timer for brightness updates after button clicks
    Timer {
        id: brightnessUpdateTimer
        interval: 100
        repeat: false
        onTriggered: updateBrightness()
    }
}
