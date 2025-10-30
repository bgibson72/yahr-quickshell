import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        top: (screen.height - 280) / 2
        left: (screen.width - 400) / 2
        right: (screen.width - 400) / 2
    }
    
    width: 400
    height: 280
    
    color: "transparent"
    mask: Region { item: background }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: ThemeManager.bgBase
        border.color: ThemeManager.accentBlue
        border.width: 2
        radius: 12
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Screenshot"
                font.pixelSize: 18
                font.bold: true
                color: ThemeManager.fgPrimary
            }
            
            // Screenshot buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                spacing: 10
                
                // Workspace button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: workspaceMouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                    border.color: ThemeManager.border1
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰍹"
                            font.pixelSize: 32
                            font.family: "Symbols Nerd Font"
                            color: ThemeManager.accentBlue
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Workspace"
                            font.pixelSize: 12
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    MouseArea {
                        id: workspaceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            screenshotWindow.visible = false
                            Qt.callLater(() => {
                                Process.exec("/usr/bin/hyprshot", ["-m", "output", "-o", Qt.resolvedUrl("~/Pictures/Screenshots").replace("file://", "")])
                            })
                        }
                    }
                }
                
                // Window button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: windowMouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                    border.color: ThemeManager.border1
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰖲"
                            font.pixelSize: 32
                            font.family: "Symbols Nerd Font"
                            color: ThemeManager.accentGreen
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Window"
                            font.pixelSize: 12
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    MouseArea {
                        id: windowMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            screenshotWindow.visible = false
                            Qt.callLater(() => {
                                Process.exec("/usr/bin/hyprshot", ["-m", "window", "-o", Qt.resolvedUrl("~/Pictures/Screenshots").replace("file://", "")])
                            })
                        }
                    }
                }
                
                // Region button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: regionMouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                    border.color: ThemeManager.border1
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰆟"
                            font.pixelSize: 32
                            font.family: "Symbols Nerd Font"
                            color: ThemeManager.accentPurple
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Selection"
                            font.pixelSize: 12
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    MouseArea {
                        id: regionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            screenshotWindow.visible = false
                            Qt.callLater(() => {
                                Process.exec("/usr/bin/hyprshot", ["-m", "region", "-o", Qt.resolvedUrl("~/Pictures/Screenshots").replace("file://", "")])
                            })
                        }
                    }
                }
            }
            
            // Options
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                // Delay
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "Delay (seconds):"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 100
                        height: 30
                        color: ThemeManager.surface0
                        border.color: ThemeManager.border1
                        border.width: 1
                        radius: 4
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            spacing: 0
                            
                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.fillHeight: true
                                color: decreaseMouseArea.containsMouse ? ThemeManager.surface1 : "transparent"
                                radius: 3
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "−"
                                    font.pixelSize: 16
                                    color: ThemeManager.fgPrimary
                                }
                                
                                MouseArea {
                                    id: decreaseMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (delayValue.value > 0) delayValue.value--
                                }
                            }
                            
                            Text {
                                id: delayValue
                                property int value: 0
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: value.toString()
                                font.pixelSize: 14
                                color: ThemeManager.fgPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.fillHeight: true
                                color: increaseMouseArea.containsMouse ? ThemeManager.surface1 : "transparent"
                                radius: 3
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.pixelSize: 16
                                    color: ThemeManager.fgPrimary
                                }
                                
                                MouseArea {
                                    id: increaseMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (delayValue.value < 10) delayValue.value++
                                }
                            }
                        }
                    }
                }
                
                // Save location
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "Save to:"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: "~/Pictures/Screenshots"
                        font.pixelSize: 11
                        color: ThemeManager.fgTertiary
                        elide: Text.ElideMiddle
                    }
                }
            }
            
            // Close button hint
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Press ESC to close"
                font.pixelSize: 10
                color: ThemeManager.fgTertiary
            }
        }
    }
    
    // Keyboard handler for ESC key
    Shortcut {
        sequence: "Escape"
        onActivated: screenshotWindow.visible = false
    }
    
    // Click outside to close
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: screenshotWindow.visible = false
    }
}
