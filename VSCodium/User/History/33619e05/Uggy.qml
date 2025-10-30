import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 400
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property int selectedIndex: 0
    property int hoverIndex: -1  // Track mouse hover separately
    
    signal requestClose()
    
    focus: true
    
    // Keyboard navigation
    Keys.onEscapePressed: requestClose()
    
    Keys.onUpPressed: {
        hoverIndex = -1  // Clear hover when using keyboard
        if (selectedIndex === -1) {
            selectedIndex = appListModel.count - 1  // Go to last item if nothing selected
        } else if (selectedIndex > 0) {
            selectedIndex--
        }
        listView.positionViewAtIndex(selectedIndex, ListView.Contain)
    }
    
    Keys.onDownPressed: {
        hoverIndex = -1  // Clear hover when using keyboard
        if (selectedIndex === -1) {
            selectedIndex = 0  // Go to first item if nothing selected
        } else if (selectedIndex < appListModel.count - 1) {
            selectedIndex++
        }
        listView.positionViewAtIndex(selectedIndex, ListView.Contain)
    }
    
    Keys.onReturnPressed: {
        if (selectedIndex >= 0 && selectedIndex < appListModel.count) {
            launchApp(appListModel.get(selectedIndex).appCommand)
        }
    }
    
    Keys.onEnterPressed: {
        if (selectedIndex >= 0 && selectedIndex < appListModel.count) {
            launchApp(appListModel.get(selectedIndex).appCommand)
        }
    }
    
    // Reset selection when widget becomes visible
    onIsVisibleChanged: {
        if (isVisible) {
            selectedIndex = -1  // Start with nothing selected
            hoverIndex = -1  // Reset hover on open
            root.forceActiveFocus()
        }
    }
    
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
                    color: {
                        if (root.hoverIndex === index) return ThemeManager.accentBlue
                        if (root.hoverIndex === -1 && index === root.selectedIndex) return ThemeManager.accentBlue
                        return "transparent"
                    }
                    radius: 8
                    
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
                                color: {
                                    if (root.hoverIndex === index) return ThemeManager.bgBase
                                    if (root.hoverIndex === -1 && index === root.selectedIndex) return ThemeManager.bgBase
                                    return ThemeManager.surface2
                                }
                                radius: 8
                                visible: !appIconImage.visible
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"  // default app icon
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 22
                                    color: {
                                        if (root.hoverIndex === index) return ThemeManager.accentBlue
                                        if (root.hoverIndex === -1 && index === root.selectedIndex) return ThemeManager.accentBlue
                                        return ThemeManager.fgPrimary
                                    }
                                }
                            }
                        }
                        
                        Text {
                            width: parent.width - 60
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.appName
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: {
                                if (root.hoverIndex === index) return Font.DemiBold
                                if (root.hoverIndex === -1 && index === root.selectedIndex) return Font.DemiBold
                                return Font.Medium
                            }
                            color: {
                                if (root.hoverIndex === index) return ThemeManager.bgBase
                                if (root.hoverIndex === -1 && index === root.selectedIndex) return ThemeManager.bgBase
                                return ThemeManager.fgPrimary
                            }
                            elide: Text.ElideRight
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: {
                            root.hoverIndex = index
                        }
                        onExited: {
                            root.hoverIndex = -1
                        }
                        
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