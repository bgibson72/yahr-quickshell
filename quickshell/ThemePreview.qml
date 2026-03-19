import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Dynamic theme preview component
// Generates a visual preview from theme colors
Rectangle {
    id: themePreview
    
    property string themeName: ""
    property var themeColors: ({})
    property bool loaded: false
    
    width: 420
    height: 120
    radius: 6
    color: themeColors.bgBase || "#1e1e2e"
    border.width: 1
    border.color: themeColors.border0 || "#6c7086"
    clip: true
    
    // Load theme colors from .conf file
    Component.onCompleted: {
        if (themeName) {
            console.log("ThemePreview: Component completed for", themeName)
            Qt.callLater(loadThemeColors)
        }
    }
    
    onThemeNameChanged: {
        if (themeName) {
            console.log("ThemePreview: Theme name changed to", themeName)
            themeColors = {}
            loaded = false
            Qt.callLater(loadThemeColors)
        }
    }
    
    function loadThemeColors() {
        console.log("ThemePreview: Starting to load colors for", themeName)
        themeColorLoader.buffer = ""
        themeColorLoader.running = true
    }
    
    Process {
        id: themeColorLoader
        running: false
        command: ["sh", "-c", "grep -E '\\$(accent|fg|bg|surface|border).*=.*rgb\\(' ~/.config/hypr/themes/" + themeName + ".conf 2>/dev/null | grep -v 'Alpha'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                themeColorLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running) {
                console.log("ThemePreview: Process completed for", themeName, "Buffer length:", buffer.length)
                if (buffer !== "") {
                    parseThemeColors(buffer)
                } else {
                    console.log("ThemePreview: No colors loaded for", themeName, "- buffer empty")
                    themePreview.loaded = true
                }
                buffer = ""
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            console.log("ThemePreview: Process exited with code", exitCode, "for", themeName)
        }
    }
    
    function parseThemeColors(data) {
        const lines = data.split('\n')
        const colors = {}
        let colorCount = 0
        
        lines.forEach(line => {
            // Match: $varName = rgb(hexvalue)
            const match = line.match(/\$([a-zA-Z0-9_-]+)\s*=\s*rgb\(([a-fA-F0-9]+)\)/)
            if (match) {
                const varName = match[1]
                const hexColor = match[2]
                colors[varName] = "#" + hexColor
                colorCount++
            }
        })
        
        console.log("ThemePreview: Parsed", colorCount, "colors for", themeName)
        if (colorCount > 0) {
            console.log("ThemePreview: Sample colors - accent-blue:", colors["accent-blue"], 
                       "accent-green:", colors["accent-green"],
                       "bg-base:", colors["bg-base"])
        }
        
        themePreview.themeColors = colors
        themePreview.loaded = true
    }
    
    // Preview content
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        
        // Left side: Color swatches
        ColumnLayout {
            Layout.preferredWidth: 130
            Layout.fillHeight: true
            spacing: 4
            
            // Accent colors row
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                radius: 4
                color: themePreview.themeColors["bg-mantle"] || "#181825"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 2
                    
                    Repeater {
                        model: [
                            "accent-blue", "accent-purple", "accent-pink", 
                            "accent-red", "accent-yellow", "accent-green"
                        ]
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 2
                            color: themePreview.themeColors[modelData] || "#89b4fa"
                        }
                    }
                }
            }
            
            // Background gradient
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 4
                
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: themePreview.themeColors["bg-crust"] || "#11111b"
                    }
                    GradientStop { 
                        position: 0.5
                        color: themePreview.themeColors["bg-base"] || "#1e1e2e"
                    }
                    GradientStop { 
                        position: 1.0
                        color: themePreview.themeColors["surface-0"] || "#313244"
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "Background"
                    font.family: "Sen"
                    font.pixelSize: 9
                    color: themePreview.themeColors["fg-primary"] || "#cdd6f4"
                    opacity: 0.4
                }
            }
            
            // Text colors
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                radius: 4
                color: themePreview.themeColors["surface-1"] || "#45475a"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 2
                    
                    Repeater {
                        model: ["fg-primary", "fg-secondary", "fg-tertiary"]
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 2
                            color: themePreview.themeColors[modelData] || "#cdd6f4"
                        }
                    }
                }
            }
        }
        
        // Right side: Mini bar mockup
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: themePreview.themeColors["bg-base"] || "#1e1e2e"
            opacity: 0.95
            border.width: 1
            border.color: themePreview.themeColors["border-1"] || "#7f849c"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                // Workspace indicators
                Row {
                    spacing: 4
                    
                    Repeater {
                        model: 4
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: index === 0 ? 
                                (themePreview.themeColors["accent-blue"] || "#89b4fa") :
                                (themePreview.themeColors["surface-2"] || "#585b70")
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Icon indicators
                Row {
                    spacing: 6
                    
                    Repeater {
                        model: [
                            "accent-purple", "accent-yellow", 
                            "accent-green", "accent-pink"
                        ]
                        
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 4
                            color: themePreview.themeColors[modelData] || "#cba6f7"
                            opacity: 0.9
                        }
                    }
                }
            }
        }
    }
    
    // Loading indicator
    Text {
        anchors.centerIn: parent
        text: loaded ? "" : "Loading..."
        font.family: "Sen"
        font.pixelSize: 10
        color: themePreview.themeColors.fgTertiary || "#a6adc8"
        visible: !loaded
    }
}
