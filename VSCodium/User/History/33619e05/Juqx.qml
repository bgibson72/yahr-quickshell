import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 400
    height: 600
    color: ThemeManager.surface0
    radius: 16
    
    property bool isVisible: false
    
    signal requestClose()
    
    focus: true
    
    // Close on Escape
    Keys.onEscapePressed: requestClose()
    
    // Process to load apps
    Process {
        id: appLoader
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/list-apps.sh"]
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n')
                for (const line of lines) {
                    if (line.trim().length === 0) continue
                    
                    const parts = line.split('|')
                    if (parts.length >= 4) {
                        appListModel.append({
                            appName: parts[0],
                            appDescription: parts[1],
                            appIcon: parts[2],
                            appCommand: parts[3]
                        })
                    }
                }
                console.log("Loaded", appListModel.count, "applications")
            }
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        // Header
        Text {
            width: parent.width
            height: 36
            text: "Applications"
            font.family: "MapleMono NF"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: ThemeManager.fgPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        // Apps list
        Rectangle {
            width: parent.width
            height: parent.height - 44
            color: ThemeManager.surface1
            radius: 12
            
            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                clip: true
                
                model: ListModel {
                    id: appListModel
                    // Apps will be loaded dynamically from the script
                }
                
                delegate: Rectangle {
                    width: listView.width
                    height: 48
                    color: mouseArea.containsMouse ? ThemeManager.accent : "transparent"
                    radius: 10
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        spacing: 12
                        
                        Item {
                            width: 36
                            height: 36
                            
                            Image {
                                id: appIconImage
                                anchors.fill: parent
                                sourceSize.width: 36
                                sourceSize.height: 36
                                smooth: true
                                fillMode: Image.PreserveAspectFit
                                
                                source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                visible: status === Image.Ready
                            }
                            
                            // Fallback icon if image fails to load
                            Rectangle {
                                anchors.fill: parent
                                color: ThemeManager.surface2
                                radius: 8
                                visible: !appIconImage.visible
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"  // default app icon
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 22
                                    color: ThemeManager.fgPrimary
                                }
                            }
                        }
                        
                        Text {
                            width: parent.width - 60
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.appName
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            launchApp(model.appCommand)
                        }
                    }
                }
            }
        }
    }
    
    function launchApp(command) {
        console.log("Launching app:", command)
        // Close the launcher first
        root.requestClose()
        
        // Use a small delay before launching to ensure the window closes properly
        Qt.callLater(() => {
            Quickshell.execDetached(["sh", "-c", command + " &"])
        })
    }
}