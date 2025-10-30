// AdvancedExamples.qml
// 
// This file contains examples of advanced features you can now implement
// with Quickshell that were difficult or impossible with Waybar
//
// These are NOT included in the default configuration but serve as
// examples for features you might want to add.

import QtQuick
import QtQuick.Layouts
import Quickshell
import QtCharts

// EXAMPLE 1: Animated System Monitor with Graphs
// ================================================
Item {
    id: systemMonitor
    width: 200
    height: 100
    
    ChartView {
        anchors.fill: parent
        antialiasing: true
        backgroundColor: "#292e42"
        
        // CPU Usage Line Chart
        LineSeries {
            id: cpuSeries
            name: "CPU"
            color: "#7aa2f7"
            width: 2
        }
        
        // Memory Usage Line Chart
        LineSeries {
            id: memSeries
            name: "Memory"
            color: "#9ece6a"
            width: 2
        }
        
        // Update every second
        Timer {
            interval: 1000
            running: true
            repeat: true
            property int counter: 0
            
            onTriggered: {
                // Get CPU usage
                let cpuProc = Process.exec("sh", ["-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"])
                cpuProc.finished.connect(() => {
                    let cpu = parseFloat(cpuProc.stdout.trim())
                    cpuSeries.append(counter, cpu)
                })
                
                // Get Memory usage
                let memProc = Process.exec("sh", ["-c", "free | grep Mem | awk '{print ($3/$2) * 100.0}'"])
                memProc.finished.connect(() => {
                    let mem = parseFloat(memProc.stdout.trim())
                    memSeries.append(counter, mem)
                })
                
                counter++
                
                // Keep only last 60 data points
                if (cpuSeries.count > 60) {
                    cpuSeries.remove(0)
                    memSeries.remove(0)
                }
            }
        }
    }
}

// EXAMPLE 2: Interactive Calendar Popup
// ======================================
Popup {
    id: calendarPopup
    width: 300
    height: 350
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        border.color: "#7aa2f7"
        border.width: 2
        radius: 8
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            
            // Month/Year Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "◀"
                    color: "#c0caf5"
                    font.pixelSize: 16
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Previous month logic
                        }
                    }
                }
                
                Text {
                    Layout.fillWidth: true
                    text: new Date().toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
                    color: "#c0caf5"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    text: "▶"
                    color: "#c0caf5"
                    font.pixelSize: 16
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Next month logic
                        }
                    }
                }
            }
            
            // Calendar Grid (simplified example)
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                
                // Day headers
                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    Text {
                        text: modelData
                        color: "#f9e2af"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                // Days (would need proper calendar logic)
                // This is just a visual example
            }
        }
    }
}

// EXAMPLE 3: Workspace Previews on Hover
// =======================================
Item {
    id: workspacePreview
    width: 200
    height: 150
    
    // Screenshot of workspace
    Image {
        anchors.fill: parent
        source: "image://hyprland/workspace/1"  // Conceptual - would need implementation
        fillMode: Image.PreserveAspectFit
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#7aa2f7"
            border.width: 2
            radius: 8
        }
    }
    
    // Window count badge
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        width: 30
        height: 30
        color: "#7aa2f7"
        radius: 15
        
        Text {
            anchors.centerIn: parent
            text: "3"  // Window count
            color: "#1a1b26"
            font.bold: true
        }
    }
}

// EXAMPLE 4: Animated Notification Center
// ========================================
Item {
    id: notificationCenter
    width: 350
    height: 500
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        border.color: "#7aa2f7"
        border.width: 2
        radius: 8
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            
            // Header
            Text {
                text: "Notifications"
                font.pixelSize: 18
                font.bold: true
                color: "#c0caf5"
            }
            
            // Notification list
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                clip: true
                
                model: ListModel {
                    // Notification items would go here
                }
                
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 80
                    color: "#292e42"
                    radius: 8
                    
                    // Slide in animation
                    NumberAnimation on x {
                        from: -width
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        // Icon
                        Text {
                            text: "🔔"
                            font.pixelSize: 24
                        }
                        
                        // Content
                        ColumnLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Notification Title"
                                color: "#c0caf5"
                                font.bold: true
                            }
                            
                            Text {
                                text: "Notification body text..."
                                color: "#a9b1d6"
                                font.pixelSize: 11
                            }
                        }
                        
                        // Close button
                        Text {
                            text: "✕"
                            color: "#f7768e"
                            font.pixelSize: 16
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Remove notification
                                }
                            }
                        }
                    }
                }
            }
            
            // Clear all button
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#f7768e"
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: "#1a1b26"
                    font.bold: true
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Clear all notifications
                    }
                }
            }
        }
    }
}

// EXAMPLE 5: Weather Widget with Icons and Animations
// ====================================================
Item {
    id: weatherWidget
    width: 150
    height: 42
    
    property string condition: "sunny"
    property int temperature: 72
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        color: "#292e42"
        radius: 8
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            
            // Animated weather icon
            Text {
                text: {
                    switch(weatherWidget.condition) {
                        case "sunny": return "☀️"
                        case "cloudy": return "☁️"
                        case "rainy": return "🌧️"
                        case "snowy": return "❄️"
                        default: return "🌤️"
                    }
                }
                font.pixelSize: 20
                
                // Rotation animation for sun
                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 10000
                    loops: Animation.Infinite
                    running: weatherWidget.condition === "sunny"
                }
            }
            
            Text {
                text: weatherWidget.temperature + "°F"
                color: "#c0caf5"
                font.pixelSize: 14
            }
        }
    }
    
    Timer {
        interval: 600000  // 10 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            // Fetch weather from API
            // let proc = Process.exec("curl", ["wttr.in/?format=%t"])
            // Parse and update temperature
        }
    }
}

// EXAMPLE 6: Volume Slider Popup
// ===============================
Popup {
    id: volumeSlider
    width: 200
    height: 100
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        border.color: "#7aa2f7"
        border.width: 2
        radius: 8
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            
            Text {
                text: "Volume"
                color: "#c0caf5"
                font.bold: true
            }
            
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: 50
                
                onValueChanged: {
                    Process.execute("pactl", ["set-sink-volume", "@DEFAULT_SINK@", value + "%"])
                }
                
                background: Rectangle {
                    color: "#292e42"
                    radius: 4
                }
                
                handle: Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: "#7aa2f7"
                }
            }
            
            Text {
                text: Math.round(parent.children[1].value) + "%"
                color: "#c0caf5"
            }
        }
    }
}

/*
 * HOW TO USE THESE EXAMPLES:
 * 
 * 1. Copy the example you want into its own .qml file
 * 2. Import it in your Bar.qml or shell.qml
 * 3. Customize colors, sizes, and behavior to match your theme
 * 4. Connect to system services using Process.exec() or Qt APIs
 * 
 * These examples show the power of Quickshell:
 * - Real-time data visualization
 * - Smooth animations
 * - Complex interactive UI
 * - Popup windows and overlays
 * - Custom widgets limited only by your imagination
 * 
 * None of these would be possible (or would be very hacky) in Waybar!
 */
