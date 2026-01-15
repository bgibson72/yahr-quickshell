import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 540
    height: 432
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property bool enableBlur: false
    
    signal requestClose()
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    // Load blur setting
    onIsVisibleChanged: {
        if (isVisible) {
            blurSettingsLoader.running = true
        }
    }
    
    Process {
        id: blurSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                blurSettingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        root.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Column {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 16
        
        // Top Row: Calendar and Weather
        Row {
            width: parent.width
            height: 270
            spacing: 16
            
            // Calendar Section
            Rectangle {
                width: (parent.width - 16) * 0.6
                height: parent.height
                color: ThemeManager.surface1
                radius: 12
                
                Column {
                    anchors {
                        fill: parent
                        margins: 16
                    }
                    spacing: 8
                    
                    // Month/Year Header
                    Text {
                        width: parent.width
                        text: {
                            const now = new Date()
                            const monthNames = ["January", "February", "March", "April", "May", "June",
                                              "July", "August", "September", "October", "November", "December"]
                            return monthNames[now.getMonth()] + " " + now.getFullYear()
                        }
                        font.family: "MapleMono NF"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Calendar Grid
                    Grid {
                        width: parent.width
                        columns: 7
                        columnSpacing: 4
                        rowSpacing: 4
                        
                        // Day headers
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                            
                            Text {
                                text: modelData
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                                width: (parent.parent.width - 24) / 7
                                height: 22
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        // Calendar days
                        Repeater {
                            model: 35
                            
                            Rectangle {
                                width: (parent.parent.width - 24) / 7
                                height: 28
                                radius: 6
                                
                                property var now: new Date()
                                property int currentDay: now.getDate()
                                property int currentMonth: now.getMonth()
                                property int currentYear: now.getFullYear()
                                property var firstDay: new Date(currentYear, currentMonth, 1)
                                property int startOffset: firstDay.getDay()
                                property int dayNumber: index - startOffset + 1
                                property var lastDay: new Date(currentYear, currentMonth + 1, 0)
                                property int daysInMonth: lastDay.getDate()
                                property bool isCurrentDay: dayNumber === currentDay
                                property bool isValidDay: dayNumber >= 1 && dayNumber <= daysInMonth
                                
                                color: {
                                    if (isValidDay && isCurrentDay) return ThemeManager.accentBlue
                                    return "transparent"
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.isValidDay ? parent.dayNumber : ""
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 13
                                    color: {
                                        if (parent.isValidDay && parent.isCurrentDay) return ThemeManager.bgBase
                                        if (!parent.isValidDay) return ThemeManager.border0
                                        return ThemeManager.fgPrimary
                                    }
                                    font.weight: parent.isValidDay && parent.isCurrentDay ? Font.Bold : Font.Normal
                                }
                            }
                        }
                    }
                }
            }
            
            // Right Side: Clock and Weather stacked
            Column {
                width: (parent.width - 16) * 0.4
                height: parent.height
                spacing: 12
                
                // Clock Section (top)
                Rectangle {
                    id: clockSection
                    width: parent.width
                    height: 80
                    color: ThemeManager.surface1
                    radius: 12
                    
                    Row {
                        anchors.centerIn: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        
                        Text {
                            id: timeText
                            font.family: "MapleMono NF"
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            color: ThemeManager.accentBlue
                            text: "10:42:18"
                        }
                        
                        Text {
                            id: periodText
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                            text: "AM"
                            anchors.verticalCenter: parent.verticalCenter
                            visible: text !== ""
                        }
                    }
                    
                    property bool use24Hour: true
                    property bool showSeconds: false
                    
                    Timer {
                        interval: 1000
                        running: root.isVisible
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: timeSettingsLoader.running = true
                    }
                    
                    Timer {
                        id: clockTimer
                        interval: 1000
                        running: root.isVisible
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: clockSection.updateTimeDisplay()
                    }
                    
                    function updateTimeDisplay() {
                        let now = new Date()
                        let hours = now.getHours()
                        let minutes = now.getMinutes().toString().padStart(2, '0')
                        let seconds = now.getSeconds().toString().padStart(2, '0')
                        
                        if (clockSection.use24Hour) {
                            timeText.text = clockSection.showSeconds 
                                ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                                : `${hours.toString().padStart(2, '0')}:${minutes}`
                            periodText.text = ""
                        } else {
                            let period = hours >= 12 ? 'PM' : 'AM'
                            hours = hours % 12
                            hours = hours ? hours : 12
                            timeText.text = clockSection.showSeconds 
                                ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                                : `${hours.toString().padStart(2, '0')}:${minutes}`
                            periodText.text = period
                        }
                    }
                    
                    Process {
                        id: timeSettingsLoader
                        running: false
                        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
                        property string buffer: ""
                        
                        stdout: SplitParser {
                            onRead: data => { timeSettingsLoader.buffer += data + "\n" }
                        }
                        
                        onRunningChanged: {
                            if (!running && buffer !== "") {
                                try {
                                    const settings = JSON.parse(buffer)
                                    if (settings.general) {
                                        clockSection.use24Hour = settings.general.clockFormat24hr === true
                                        clockSection.showSeconds = settings.general.showSeconds === true
                                    }
                                    clockSection.updateTimeDisplay()
                                } catch (e) {
                                    clockSection.use24Hour = true
                                    clockSection.showSeconds = false
                                    clockSection.updateTimeDisplay()
                                }
                                buffer = ""
                            } else if (running) {
                                buffer = ""
                            }
                        }
                    }
                }
                
                // Weather Section (bottom, taller)
                Rectangle {
                    width: parent.width
                    height: 178
                    color: ThemeManager.surface1
                    radius: 12
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    // Icon and Temperature
                    Row {
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            id: weatherIcon
                            text: "⛅"
                            font.family: "Noto Color Emoji"
                            font.pixelSize: 52
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            id: temperatureText
                            text: "..."
                            font.family: "MapleMono NF"
                            font.pixelSize: 36
                            font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    // Condition
                    Text {
                        id: conditionText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Sunny"
                        font.family: "MapleMono NF"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                    }
                    
                    // Details
                    Row {
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            id: humidityText
                            text: "💧 47%"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            color: ThemeManager.fgSecondary
                        }
                        
                        Text {
                            id: windText
                            text: "💨 4mph"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
            }
        }
        }
        
        // Bottom: System Gauges
        Rectangle {
            width: parent.width
            height: 106
            color: ThemeManager.surface1
            radius: 12
            
            Row {
                spacing: 40
                anchors.centerIn: parent
                
                // CPU Gauge
                Item {
                    width: 84
                    height: 84
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Canvas {
                            id: cpuCanvas
                            width: 70
                            height: 70
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            property real percentage: 0
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = 28
                                
                                // Background circle
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                                ctx.strokeStyle = ThemeManager.surface0
                                ctx.lineWidth = 6
                                ctx.stroke()
                                
                                // Progress arc
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
                                       -Math.PI / 2 + (percentage / 100) * 2 * Math.PI)
                                ctx.strokeStyle = percentage > 80 ? ThemeManager.accentRed : ThemeManager.accentBlue
                                ctx.lineWidth = 6
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: Math.round(cpuCanvas.percentage) + "%"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "CPU"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // RAM Gauge
                Item {
                    width: 84
                    height: 84
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Canvas {
                            id: ramCanvas
                            width: 70
                            height: 70
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            property real percentage: 0
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = 28
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                                ctx.strokeStyle = ThemeManager.surface0
                                ctx.lineWidth = 6
                                ctx.stroke()
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
                                       -Math.PI / 2 + (percentage / 100) * 2 * Math.PI)
                                ctx.strokeStyle = percentage > 80 ? ThemeManager.accentRed : ThemeManager.accentBlue
                                ctx.lineWidth = 6
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: Math.round(ramCanvas.percentage) + "%"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "RAM"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // Disk Gauge
                Item {
                    width: 84
                    height: 84
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Canvas {
                            id: diskCanvas
                            width: 70
                            height: 70
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            property real percentage: 0
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = 28
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                                ctx.strokeStyle = ThemeManager.surface0
                                ctx.lineWidth = 6
                                ctx.stroke()
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
                                       -Math.PI / 2 + (percentage / 100) * 2 * Math.PI)
                                ctx.strokeStyle = percentage > 80 ? ThemeManager.accentRed : ThemeManager.accentBlue
                                ctx.lineWidth = 6
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: Math.round(diskCanvas.percentage) + "%"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Disk"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
            }
        }
    }
    
    // System stats update timer
    Timer {
        interval: 2000
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuStatsProcess.running = true
            ramStatsProcess.running = true
            diskStatsProcess.running = true
        }
    }
    
    // CPU stats
    Process {
        id: cpuStatsProcess
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                cpuCanvas.percentage = parseFloat(data.trim()) || 0
                cpuCanvas.requestPaint()
            }
        }
    }
    
    // RAM stats
    Process {
        id: ramStatsProcess
        command: ["sh", "-c", "free | grep Mem | awk '{print ($3/$2) * 100.0}'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                ramCanvas.percentage = parseFloat(data.trim()) || 0
                ramCanvas.requestPaint()
            }
        }
    }
    
    // Disk stats
    Process {
        id: diskStatsProcess
        command: ["sh", "-c", "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                diskCanvas.percentage = parseFloat(data.trim()) || 0
                diskCanvas.requestPaint()
            }
        }
    }
    
    // Weather update timer
    Timer {
        interval: 300000
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: settingsLoader.running = true
    }
    
    // Load weather settings
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { settingsLoader.buffer += data + "\n" }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    let latitude = ""
                    let longitude = ""
                    let useFahrenheit = true
                    
                    if (settings.general) {
                        latitude = settings.general.weatherLatitude || ""
                        longitude = settings.general.weatherLongitude || ""
                        useFahrenheit = settings.general.useFahrenheit !== false
                    }
                    
                    const tempUnit = useFahrenheit ? "u" : "m"
                    let location = (latitude && longitude) ? `${latitude},${longitude}` : ""
                    let weatherCmd = `curl -s "wttr.in/${location}?${tempUnit}&format=%c|%t|%C|%h|%w"`
                    
                    weatherProcess.command = ["sh", "-c", weatherCmd]
                    weatherProcess.running = true
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Fetch weather
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t|%C|%h|%w'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split('|')
                if (parts.length >= 5) {
                    weatherIcon.text = (parts[0] || "🌡️").trim()
                    let temp = (parts[1] || "N/A").trim()
                    temperatureText.text = temp.replace(/^\+/, "").trim()
                    conditionText.text = (parts[2] || "Unknown").trim()
                    humidityText.text = "💧 " + (parts[3] || "--").trim()
                    windText.text = "💨 " + (parts[4] || "--").trim()
                }
            }
        }
    }
}
