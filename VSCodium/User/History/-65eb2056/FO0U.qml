import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: screenshotWindow
    
    property var screen_
    screen: screen_
    
    visible: false
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: (screen.height - 250) / 2
        left: (screen.width - 480) / 2
        right: (screen.width - 480) / 2
    }
    
    implicitWidth: 480
    implicitHeight: 250
    
    color: "transparent"
    mask: Region { item: background }
    exclusiveZone: 0
    
    WlrLayershell.layer: WlrLayer.Overlay
    
    property int delaySeconds: 0
    property string saveLocation: "~/Pictures/Screenshots"
    property bool copyToClipboard: false
    property bool saveToDisk: true
    
    signal closeRequested()
    
    // Load settings from settings.json
    Component.onCompleted: {
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
                    if (settings.screenshot) {
                        delaySeconds = settings.screenshot.defaultDelay || 0
                        saveToDisk = settings.screenshot.saveToDisk !== false
                        copyToClipboard = settings.screenshot.copyToClipboard === true
                        saveLocation = settings.screenshot.saveLocation || "~/Pictures/Screenshots"
                        console.log("Screenshot settings loaded - delay:", delaySeconds, "save:", saveToDisk, "copy:", copyToClipboard)
                    }
                } catch (e) {
                    console.error("Failed to load screenshot settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: screenshotProcess
        running: false
    }
    
    function takeScreenshot(mode) {
        console.log("Taking screenshot - mode:", mode, "delay:", delaySeconds, "save:", saveToDisk, "copy:", copyToClipboard)
        
        // Build command arguments for helper script
        var scriptPath = "/home/bryan/.config/quickshell/take-screenshot.sh"
        var args = [
            mode,
            delaySeconds.toString(),
            saveToDisk ? "true" : "false",
            copyToClipboard ? "true" : "false",
            saveLocation
        ]
        
        console.log("Executing:", scriptPath, args.join(" "))
        
        // Set up and run the process
        screenshotProcess.command = [scriptPath].concat(args)
        screenshotProcess.running = true
        
        // Close widget after a small delay to let the process start
        Qt.callLater(() => {
            closeRequested()
        })
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: ThemeManager.bgBase
        radius: 16
        border.width: 3
        border.color: ThemeManager.accentBlue
        antialiasing: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Title
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "Screenshot"
                    font.family: "MapleMono NF"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: ThemeManager.fgPrimary
                }
                
                // Close button
                Rectangle {
                    width: 28
                    height: 28
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 6
                    color: closeMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: "Maple Mono NF"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: closeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgSecondary
                    }
                    
                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: closeRequested()
                    }
                }
            }
            
            // Main content card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: ThemeManager.surface1
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    
                    // Capture Mode Section
                    Column {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Select Capture Mode"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 12
                            
                            // Workspace button
                            Rectangle {
                                width: (parent.width - 24) / 3
                                height: 100
                                color: workspaceMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface0
                                radius: 8
                                border.width: workspaceMouseArea.containsMouse ? 2 : 0
                                border.color: ThemeManager.accentBlue
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰍹"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 32
                                        color: workspaceMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Workspace"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: workspaceMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: workspaceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screenshotWindow.takeScreenshot("output")
                                }
                            }
                            
                            // Window button
                            Rectangle {
                                width: (parent.width - 24) / 3
                                height: 100
                                color: windowMouseArea.containsMouse ? ThemeManager.accentGreen : ThemeManager.surface0
                                radius: 8
                                border.width: windowMouseArea.containsMouse ? 2 : 0
                                border.color: ThemeManager.accentGreen
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰖲"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 32
                                        color: windowMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentGreen
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Window"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: windowMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: windowMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screenshotWindow.takeScreenshot("window")
                                }
                            }
                            
                            // Selection button
                            Rectangle {
                                width: (parent.width - 24) / 3
                                height: 100
                                color: regionMouseArea.containsMouse ? ThemeManager.accentPurple : ThemeManager.surface0
                                radius: 8
                                border.width: regionMouseArea.containsMouse ? 2 : 0
                                border.color: ThemeManager.accentPurple
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰆟"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 32
                                        color: regionMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentPurple
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Selection"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: regionMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: regionMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screenshotWindow.takeScreenshot("region")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Keyboard handler for ESC key
    Shortcut {
        sequence: "Escape"
        onActivated: screenshotWindow.closeRequested()
    }
}
