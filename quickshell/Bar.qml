import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Item {
    id: bar
    
    property bool transparentBackground: false
    property bool enableBlur: false
    property string position: "top"  // "top" or "bottom"
    
    signal toggleClipboard()
    signal toggleControlCenter()
    
    // Load bar settings
    Process {
        id: barSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                barSettingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.bar) {
                        if (settings.bar.transparentBackground !== undefined) {
                            bar.transparentBackground = settings.bar.transparentBackground
                        }
                        if (settings.bar.position !== undefined) {
                            bar.position = settings.bar.position
                        }
                    }
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        bar.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {
                    console.log("🎨 Error parsing bar settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Auto-reload settings every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            barSettingsLoader.running = true
        }
    }
    
    // Background rectangle
    Rectangle {
        id: background
        anchors.fill: parent
        color: bar.transparentBackground ? "transparent" : ThemeManager.bgBaseAlpha
        z: -1
    }
    
    property alias clockComponent: clockComponent
    property alias archComponent: archComponent
    property alias powerComponent: powerComponent
    property alias settingsButtonComponent: quickAccessDrawer.settingsButton
    
    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        ArchButton {
            id: archComponent
        }
        WorkspaceBar {}
        Separator {}
        QuickAccessDrawer {
            id: quickAccessDrawer
        }
    }
    
    // CENTER SECTION - Absolutely centered
    Clock {
        id: clockComponent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    // CENTER-RIGHT SECTION - Media Player
    MediaPlayer {
        anchors.left: clockComponent.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    
    // RIGHT SECTION
    Item {
        anchors.right: parent.right
        anchors.rightMargin: -2
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: rightRow.width
        
        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            
            ClipboardManager {
                id: clipboardComponent
                onToggleClipboard: {
                    bar.toggleClipboard()
                }
            }
            Updates {}
            SystemTray {
                id: systemTrayComponent
                onToggleControlCenter: {
                    bar.toggleControlCenter()
                }
            }
            PowerButton {
                id: powerComponent
            }
        }
    }
}
