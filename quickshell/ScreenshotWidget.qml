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
    
    property bool enableBlur: false
    
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
    
    // Reload settings when window becomes visible
    onVisibleChanged: {
        if (visible) {
            console.log("Screenshot widget opened, loading settings...")
            settingsLoader.running = true
        }
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
                        console.log("Screenshot settings loaded - delay:", delaySeconds, "saveToDisk:", saveToDisk, "copyToClipboard:", copyToClipboard, "location:", saveLocation)
                    }
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        screenshotWindow.enableBlur = settings.general.enableBlur
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
        
        // Monitor process completion to handle cancellations
        onRunningChanged: {
            if (!running && !screenshotWindow.visible) {
                // If process stopped and widget is hidden, close it properly
                closeRequested()
            }
        }
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
        
        // For interactive modes (window/region), close widget immediately, then start process
        if (mode === "window" || mode === "region") {
            // Close widget immediately so it doesn't interfere with screenshot
            closeRequested()
            
            // Delay process start to let widget fully disappear
            delayedStartTimer.mode = mode
            delayedStartTimer.scriptPath = scriptPath
            delayedStartTimer.args = args
            delayedStartTimer.start()
        } else {
            // For output mode, start immediately and close after
            screenshotProcess.command = [scriptPath].concat(args)
            screenshotProcess.running = true
            closeTimer.start()
        }
    }
    
    Timer {
        id: closeTimer
        interval: 100  // Small delay before closing to let process start
        repeat: false
        onTriggered: closeRequested()
    }
    
    Timer {
        id: delayedStartTimer
        interval: 100  // Wait for widget to fully hide before starting interactive screenshot
        repeat: false
        
        property string mode: ""
        property string scriptPath: ""
        property var args: []
        
        onTriggered: {
            screenshotProcess.command = [scriptPath].concat(args)
            screenshotProcess.running = true
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
        radius: 16
        border.width: 1
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
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
                    font.family: "Sen"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: ThemeManager.fgPrimary
                }
                
                // Close button
                Rectangle {
                    width: 32
                    height: 32
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 6
                    color: closeMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.30) : "transparent"
                    border.width: closeMouseArea.containsMouse ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: "Sen"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: ThemeManager.fgSecondary
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
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.10)
                
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
                            font.family: "Sen"
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
                                color: workspaceMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : Qt.rgba(1, 1, 1, 0.07)
                                radius: 8
                                border.width: 1
                                border.color: workspaceMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.6) : Qt.rgba(1, 1, 1, 0.10)

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
                                        color: ThemeManager.accentBlue
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Workspace"
                                        font.family: "Sen"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
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
                                color: windowMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.25) : Qt.rgba(1, 1, 1, 0.07)
                                radius: 8
                                border.width: 1
                                border.color: windowMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.6) : Qt.rgba(1, 1, 1, 0.10)

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
                                        color: ThemeManager.accentGreen
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Window"
                                        font.family: "Sen"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
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
                                color: regionMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.25) : Qt.rgba(1, 1, 1, 0.07)
                                radius: 8
                                border.width: 1
                                border.color: regionMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.6) : Qt.rgba(1, 1, 1, 0.10)

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
                                        color: ThemeManager.accentPurple
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Selection"
                                        font.family: "Sen"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
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

        // Top specular highlight
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.07) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
            }
            z: 10
        }

        // Bottom fade
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.12) }
            }
            z: 10
        }
    }

    // Keyboard handler for ESC key
    Shortcut {
        sequence: "Escape"
        onActivated: screenshotWindow.closeRequested()
    }
}
