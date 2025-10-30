import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell
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
        top: (screen.height - 460) / 2
        left: (screen.width - 480) / 2
        right: (screen.width - 480) / 2
    }
    
    implicitWidth: 480
    implicitHeight: 460
    
    color: "transparent"
    mask: Region { item: background }
    exclusiveZone: 0
    
    WlrLayershell.layer: WlrLayer.Overlay
    
    property int delaySeconds: 0
    property string saveLocation: "/home/bryan/Pictures/Screenshots"
    property bool copyToClipboard: true
    property bool saveToDisk: true
    
    signal closeRequested()
    
    function takeScreenshot(mode) {
        console.log("Taking screenshot - mode:", mode, "delay:", delaySeconds, "save:", saveToDisk, "copy:", copyToClipboard)
        
        // Build command
        var cmd = "hyprshot -m " + mode
        
        // Add output folder if saving
        if (saveToDisk) {
            cmd += " -o " + saveLocation
        }
        
        // Add clipboard-only if not saving
        if (!saveToDisk && copyToClipboard) {
            cmd += " --clipboard-only"
        }
        
        // Add delay for region mode or user delay
        var totalDelay = delaySeconds
        if (mode === "region") {
            totalDelay += 0.5
        }
        
        if (totalDelay > 0) {
            cmd = "sleep " + totalDelay + " && " + cmd
        }
        
        console.log("Executing command:", cmd)
        
        // Request close from parent
        closeRequested()
        
        // Execute command
        Qt.callLater(() => {
            Quickshell.Process.exec("/bin/bash", ["-c", cmd])
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
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                text: "Screenshot"
                font.family: "MapleMono NF"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: ThemeManager.fgPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            // Main content card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: ThemeManager.surface1
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // Capture Mode Section
                    Column {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108
                        spacing: 8
                        
                        Text {
                            text: "Capture Mode"
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            // Workspace button
                            Rectangle {
                                width: (parent.width - 16) / 3
                                height: 80
                                color: workspaceMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface0
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰍹"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 28
                                        color: workspaceMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Workspace"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: workspaceMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
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
                                width: (parent.width - 16) / 3
                                height: 80
                                color: windowMouseArea.containsMouse ? ThemeManager.accentGreen : ThemeManager.surface0
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰖲"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 28
                                        color: windowMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentGreen
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Window"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: windowMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
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
                                width: (parent.width - 16) / 3
                                height: 80
                                color: regionMouseArea.containsMouse ? ThemeManager.accentPurple : ThemeManager.surface0
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰆟"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 28
                                        color: regionMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentPurple
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Selection"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: regionMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
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
                    
                    // Output Options Section
                    Column {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        spacing: 8
                        
                        Text {
                            text: "Output Options"
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 12
                            
                            // Copy to Clipboard checkbox
                            Rectangle {
                                width: (parent.width - 12) / 2
                                height: 40
                                color: copyCheckArea.containsMouse ? ThemeManager.surface0 : "transparent"
                                radius: 8
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: screenshotWindow.copyToClipboard ? ThemeManager.accentBlue : ThemeManager.surface0
                                        border.color: screenshotWindow.copyToClipboard ? ThemeManager.accentBlue : ThemeManager.border1
                                        border.width: 2
                                        radius: 5
                                        
                                        Text {
                                            visible: screenshotWindow.copyToClipboard
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: ThemeManager.bgBase
                                        }
                                    }
                                    
                                    Text {
                                        text: "Copy to Clipboard"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: copyCheckArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screenshotWindow.copyToClipboard = !screenshotWindow.copyToClipboard
                                }
                            }
                            
                            // Save to Disk checkbox
                            Rectangle {
                                width: (parent.width - 12) / 2
                                height: 40
                                color: saveCheckArea.containsMouse ? ThemeManager.surface0 : "transparent"
                                radius: 8
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: screenshotWindow.saveToDisk ? ThemeManager.accentGreen : ThemeManager.surface0
                                        border.color: screenshotWindow.saveToDisk ? ThemeManager.accentGreen : ThemeManager.border1
                                        border.width: 2
                                        radius: 5
                                        
                                        Text {
                                            visible: screenshotWindow.saveToDisk
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: ThemeManager.bgBase
                                        }
                                    }
                                    
                                    Text {
                                        text: "Save to Disk"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: saveCheckArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screenshotWindow.saveToDisk = !screenshotWindow.saveToDisk
                                }
                            }
                        }
                    }
                    
                    // Delay Section
                    Column {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        spacing: 8
                        
                        Text {
                            text: "Delay"
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            Rectangle {
                                width: 120
                                height: 40
                                color: ThemeManager.surface0
                                radius: 8
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        color: decreaseMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
                                        radius: 6
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "−"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            color: decreaseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        }
                                        
                                        MouseArea {
                                            id: decreaseMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (screenshotWindow.delaySeconds > 0) screenshotWindow.delaySeconds--
                                        }
                                    }
                                    
                                    Text {
                                        width: 40
                                        height: 32
                                        text: screenshotWindow.delaySeconds.toString() + "s"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        color: increaseMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
                                        radius: 6
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            color: increaseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        }
                                        
                                        MouseArea {
                                            id: increaseMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (screenshotWindow.delaySeconds < 10) screenshotWindow.delaySeconds++
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                height: 40
                                text: "seconds before capture"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgTertiary
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // Save Location Section (only visible when saving to disk)
                    Column {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        spacing: 8
                        visible: screenshotWindow.saveToDisk
                        
                        Text {
                            text: "Save Location"
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: ThemeManager.fgSecondary
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            // Location display
                            Rectangle {
                                width: parent.width - 120
                                height: 40
                                color: ThemeManager.surface0
                                radius: 8
                                
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: screenshotWindow.saveLocation
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgPrimary
                                    elide: Text.ElideMiddle
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            // Browse button
                            Rectangle {
                                width: 112
                                height: 40
                                color: browseMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface0
                                radius: 8
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    
                                    Text {
                                        text: "󰉋"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: browseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: "Browse"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: browseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: browseMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: fileDialog.open()
                                }
                            }
                        }
                    }
                    
                    // Spacer to push hint to bottom
                    Item {
                        Layout.fillHeight: true
                    }
                    
                    // Hint
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 4
                        text: "Press ESC to close"
                        font.family: "MapleMono NF"
                        font.pixelSize: 10
                        color: ThemeManager.fgTertiary
                    }
                }
            }
        }
    }
    
    // File dialog
    FolderDialog {
        id: fileDialog
        title: "Choose Screenshot Save Location"
        currentFolder: "file://" + screenshotWindow.saveLocation
        
        onAccepted: {
            var path = selectedFolder.toString()
            // Remove file:// prefix
            if (path.startsWith("file://")) {
                path = path.substring(7)
            }
            screenshotWindow.saveLocation = path
        }
    }
    
    // Keyboard handler for ESC key
    Shortcut {
        sequence: "Escape"
        onActivated: screenshotWindow.closeRequested()
    }
}
