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
                    // HARDCODED TEST: 24-hour format, NO seconds
                    console.log("CalendarWidget Timer - updating time (HARDCODED: 24hr, no seconds)")
                    
                    let now = new Date()
                    let hours = now.getHours().toString().padStart(2, '0')  // 24-hour format
                    let minutes = now.getMinutes().toString().padStart(2, '0')
                    
                    // NO seconds, NO AM/PM for 24-hour format
                    timeText.text = `${hours}:${minutes}`
                    periodText.text = ""  // No AM/PM in 24-hour format
                    
                    console.log("Time set to:", timeText.text)
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
                    width: parent.width
                    columns: 3
                    columnSpacing: 8
                    
                    // Friday
                    Column {
                        spacing: 6
                        
                        Text {
                            text: "Fri"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "☀️"
                            font.pixelSize: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "75°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: "58°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
                    
                    // Saturday
                    Column {
                        spacing: 6
                        
                        Text {
                            text: "Sat"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "🌤️"
                            font.pixelSize: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "78°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: "61°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
                    
                    // Sunday
                    Column {
                        spacing: 6
                        
                        Text {
                            text: "Sun"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "⛅"
                            font.pixelSize: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "71°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: "55°"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
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
    
    // HARDCODED TEST: Fetch weather for 40,-89 in Celsius
    Timer {
        interval: 5000  // Update every 5 seconds for testing
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            console.log("CalendarWidget - fetching weather (HARDCODED: 40,-89, Celsius)")
            weatherProcess.running = true
        }
    }
    
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/40,-89?m&format=%c|%t|%C|%h|%w'"]
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
