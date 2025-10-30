import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    required property var notificationService
    property bool dndEnabled: false
    property bool transparentBackground: false
    
    Component.onCompleted: {
        console.log("🔔 Bar: notificationService is:", notificationService)
    }
    
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
                    if (settings.bar && settings.bar.transparentBackground !== undefined) {
                        root.transparentBackground = settings.bar.transparentBackground
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
        anchors.fill: parent
        color: root.transparentBackground ? "transparent" : ThemeManager.bgBaseAlpha
        z: -1
    }
    
    property alias clockComponent: clockComponent
    property alias archComponent: archComponent
    property alias powerComponent: powerComponent
    property alias settingsButtonComponent: quickAccessDrawer.settingsButton
    property alias notificationComponent: notificationComponent
    
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
            
            Updates {}
            SystemTray {}
            NotificationIndicator {
                id: notificationComponent
                notificationService: root.notificationService
                onClicked: {
                    // Will be handled by Connections in shell.qml
                }
            }
            PowerButton {
                id: powerComponent
            }
        }
    }
}
