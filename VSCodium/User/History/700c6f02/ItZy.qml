import QtQuick
import Quickshell
import Quickshell.Io

// Calendar widget - designed to fill parent window
Rectangle {
    id: root
    
    color: ThemeManager.bgBase
    radius: 12
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    
    signal requestClose()
    
    // ESC key to close
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    // Main content - use Column since Grid doesn't support colspan
    Column {
        anchors {
            fill: parent
            margins: 16
            bottomMargin: 20  // Extra bottom padding
        }
        spacing: 12
        
        // Time Section (full width)
        Rectangle {
            width: parent.width
            height: 80
            color: ThemeManager.surface1
            radius: 16
            
            Row {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    id: timeText
                    font.family: "MapleMono NF"
                    font.pixelSize: 48
                    font.weight: Font.Medium
                    color: ThemeManager.fgPrimary
                    text: "10:42:18"
                }
                
                Text {
                    id: periodText
                    font.family: "MapleMono NF"
                    font.pixelSize: 24
                    color: ThemeManager.fgSecondary
                    text: "AM"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Timer to update time
            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                
                onTriggered: {
                    timeSettingsLoader.running = true
                }
            }
            
            // Load time format settings
            Process {
                id: timeSettingsLoader
                running: false
                command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
                
                stdout: SplitParser {
                    onRead: data => {
                        try {
                            const settings = JSON.parse(data)
                            let use24Hour = true
                            let showSecs = false
                            
                            if (settings.general) {
                                use24Hour = settings.general.clockFormat24hr !== false
                                showSecs = settings.general.showSeconds === true
                            }
                            
                            let now = new Date()
                            let hours = now.getHours()
                            let minutes = now.getMinutes().toString().padStart(2, '0')
                            let seconds = now.getSeconds().toString().padStart(2, '0')
                            
                            if (use24Hour) {
                                timeText.text = showSecs 
                                    ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                                    : `${hours.toString().padStart(2, '0')}:${minutes}`
                                periodText.text = ""
                            } else {
                                let period = hours >= 12 ? 'PM' : 'AM'
                                hours = hours % 12
                                hours = hours ? hours : 12
                                timeText.text = showSecs 
                                    ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                                    : `${hours.toString().padStart(2, '0')}:${minutes}`
                                periodText.text = period
                            }
                        } catch (e) {
                            // Fallback to 24-hour, no seconds
                            let now = new Date()
                            let hours = now.getHours().toString().padStart(2, '0')
                            let minutes = now.getMinutes().toString().padStart(2, '0')
                            timeText.text = `${hours}:${minutes}`
                            periodText.text = ""
                        }
                    }
                }
            }
        }
        
        // Bottom row: Weather + Calendar side by side
        Row {
            width: parent.width
            height: parent.height - 80 - 12 - 2  // Leave minimal space at bottom
            spacing: 12
            
            // Weather Section
            Rectangle {
                width: 180
                height: parent.height
                color: ThemeManager.surface1
                radius: 16
            
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 16
                    rightMargin: 16
                }
                spacing: 12
                
                // Current Weather
                Column {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        id: weatherIcon
                        text: "⛅"
                        font.pixelSize: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        id: temperatureText
                        text: "Loading..."
                        font.family: "MapleMono NF"
                        font.pixelSize: 32
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        id: conditionText
                        text: "Fetching weather..."
                        font.family: "MapleMono NF"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                // Weather details
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        id: humidityText
                        text: "💧 --%"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        id: windText
                        text: "💨 --"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
                
                // Location info (if using custom coordinates)
                Text {
                    width: parent.width
                    text: "Weather for 40°N, 89°W"
                    font.family: "MapleMono NF"
                    font.pixelSize: 10
                    color: ThemeManager.border0
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            }
            
            // Calendar Section
            Rectangle {
                width: 310  // Wider to accommodate full grid
                height: parent.height
                color: ThemeManager.surface1
                radius: 16
                
                Column {
                    anchors {
                        fill: parent
                        margins: 16
                        bottomMargin: 12
                    }
                    spacing: 12
                    
                    // Calendar header
                    Row {
                    width: parent.width
                    spacing: 8
                    
                    Column {
                        Text {
                            text: "October"
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                        }
                        
                        Text {
                            text: "2025"
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgSecondary
                        }
                    }
                }
                
                // Calendar grid
                Grid {
                    columns: 7
                    columnSpacing: 6
                    rowSpacing: 6
                    
                    // Day headers
                    Repeater {
                        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                        
                        Text {
                            text: modelData
                            font.family: "MapleMono NF"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                            width: 34
                            height: 24
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // Calendar days (simplified for now - would need JS logic for actual dates)
                    Repeater {
                        model: 35
                        
                        Rectangle {
                            width: 34
                            height: 34
                            radius: 8
                            color: {
                                // Day 16 is today
                                if (index === 18) return ThemeManager.accentBlue
                                return "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    // This is simplified - would need proper date calculation
                                    let day = index - 2
                                    if (day < 1) return ""
                                    if (day > 31) return ""
                                    return day
                                }
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: {
                                    if (index === 18) return ThemeManager.bgBase
                                    if (index < 3 || index > 33) return ThemeManager.border0
                                    return ThemeManager.fgPrimary
                                }
                                font.weight: index === 18 ? Font.DemiBold : Font.Normal
                            }
                        }
                    }
                }
            }
        }
        }
    }
    
    // Timer to update weather periodically
    Timer {
        interval: 300000  // Update every 5 minutes
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            console.log("=== CalendarWidget Weather Timer Triggered ===")
            console.log("Widget visible:", root.isVisible)
            settingsLoader.running = true
        }
    }
    
    // Load settings and build weather command
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    const settings = JSON.parse(data)
                    let location = ""
                    let unit = "m"  // Default to Celsius/metric
                    
                    if (settings.general) {
                        // Get location
                        if (settings.general.weatherLatitude && settings.general.weatherLongitude) {
                            location = settings.general.weatherLatitude + "," + settings.general.weatherLongitude
                            console.log("Using weather location from settings:", location)
                        } else {
                            console.log("No location set, using auto-detect")
                        }
                        
                        // Get temperature unit (useFahrenheit defaults to true)
                        unit = (settings.general.useFahrenheit !== false) ? "u" : "m"
                        console.log("Using temperature unit:", unit === "u" ? "Fahrenheit" : "Celsius")
                    }
                    
                    weatherProcess.command = ["sh", "-c", `curl -s 'wttr.in/${location}?${unit}&format=%c|%t|%C|%h|%w'`]
                    weatherProcess.running = true
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                    // Fallback to auto-detect location and Fahrenheit
                    weatherProcess.command = ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t|%C|%h|%w'"]
                    weatherProcess.running = true
                }
            }
        }
    }
    
    // Fetch weather data
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t|%C|%h|%w'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Weather data received:", data)
                const parts = data.trim().split('|')
                if (parts.length >= 5) {
                    // Format: emoji|temp|condition|humidity|wind
                    weatherIcon.text = parts[0] || "🌡️"
                    temperatureText.text = parts[1] || "N/A"
                    conditionText.text = parts[2] || "Unknown"
                    humidityText.text = "💧 " + (parts[3] || "--")
                    windText.text = "💨 " + (parts[4] || "--")
                    console.log("Weather updated - Temp:", parts[1], "Condition:", parts[2], "Humidity:", parts[3], "Wind:", parts[4])
                }
            }
        }
    }
}
