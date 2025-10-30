import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 600
    height: 660
    color: ThemeManager.surface0
    radius: 24
    
    property bool isVisible: false
    
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
                            appCommand: parts[3],
                            visible: true
                        })
                    }
                }
                console.log("Loaded", appListModel.count, "applications")
            }
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Search section
        Rectangle {
            width: parent.width
            height: 60
            color: ThemeManager.surface1
            radius: 16
            
            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8
                
                Text {
                    text: ""
                    font.family: "MapleMono NF"
                    font.pixelSize: 18
                    color: ThemeManager.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    height: parent.height
                    font.family: "MapleMono NF"
                    font.pixelSize: 18
                    color: ThemeManager.fgPrimary
                    verticalAlignment: TextInput.AlignVCenter
                    
                    Text {
                        text: "Search applications..."
                        font: searchInput.font
                        color: ThemeManager.fgSecondary
                        visible: searchInput.text.length === 0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    onTextChanged: {
                        filterApps()
                    }
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) {
                            event.accepted = true
                            if (selectedIndex < appListModel.count - 1) {
                                selectedIndex++
                                listView.positionViewAtIndex(selectedIndex, ListView.Contain)
                            }
                        } else if (event.key === Qt.Key_Up) {
                            event.accepted = true
                            if (selectedIndex > 0) {
                                selectedIndex--
                                listView.positionViewAtIndex(selectedIndex, ListView.Contain)
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true
                            launchSelectedApp()
                        } else if (event.key === Qt.Key_Escape) {
                            event.accepted = true
                            root.isVisible = false
                        }
                    }
                }
            }
        }
        
        // Apps section
        Rectangle {
            width: parent.width
            height: 480
            color: ThemeManager.surface1
            radius: 16
            
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
                
                property int selectedIndex: 0
                
                delegate: Rectangle {
                    width: listView.width
                    height: model.visible ? 64 : 0
                    visible: model.visible
                    color: index === listView.selectedIndex ? ThemeManager.surface2 : "transparent"
                    radius: 12
                    clip: true
    
                    // Left highlight bar
                        Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: 2  // small margin to not overlap with rounded corner
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2  // small margin to not overlap with rounded corner
                        width: 3
                        color: ThemeManager.accentBlue
                        radius: 1.5  // half the width for smooth appearance
                        visible: index === listView.selectedIndex
                        }
    
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: index === listView.selectedIndex ? 9 : 12
                            anchors.rightMargin: 12
                            anchors.topMargin: 12
                            anchors.bottomMargin: 12
                            spacing: 12
                        
                        Item {
                            width: 40
                            height: 40
                            
                            Image {
                                id: appIconImage
                                anchors.fill: parent
                                sourceSize.width: 40
                                sourceSize.height: 40
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
                                    font.pixelSize: 24
                                    color: ThemeManager.fgPrimary
                                }
                            }
                        }
                        
                        Column {
                            width: parent.width - 64
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: model.appName
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: ThemeManager.fgPrimary
                            }
                            
                            Text {
                                text: model.appDescription
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: {
                            listView.selectedIndex = index
                        }
                        
                        onClicked: {
                            launchApp(model.appCommand)
                        }
                    }
                }
            }
        }
        
        // Hint section
        Row {
            width: parent.width
            height: 30
            spacing: 16
            
            Item {
                width: parent.width
                height: parent.height
                
                Row {
                    anchors.centerIn: parent
                    spacing: 16
                    
                    Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 32
                            height: 18
                            color: ThemeManager.surface2
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "↑↓"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.accentBlue
                                anchors.centerIn: parent
                            }
                        }
                        
                        Text {
                            text: "Navigate"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 48
                            height: 18
                            color: ThemeManager.surface2
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "Enter"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.accentBlue
                                anchors.centerIn: parent
                            }
                        }
                        
                        Text {
                            text: "Launch"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 32
                            height: 18
                            color: ThemeManager.surface2
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "Esc"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: ThemeManager.accentBlue
                                anchors.centerIn: parent
                            }
                        }
                        
                        Text {
                            text: "Close"
                            font.family: "MapleMono NF"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
    
    property int selectedIndex: 0
    
    function filterApps() {
        const query = searchInput.text.toLowerCase()
        let visibleCount = 0
        
        for (let i = 0; i < appListModel.count; i++) {
            const item = appListModel.get(i)
            const nameMatch = item.appName.toLowerCase().includes(query)
            const descMatch = item.appDescription.toLowerCase().includes(query)
            const shouldShow = query.length === 0 || nameMatch || descMatch
            
            appListModel.setProperty(i, "visible", shouldShow)
            if (shouldShow) visibleCount++
        }
        
        // Reset selection to first visible item
        if (visibleCount > 0) {
            selectedIndex = 0
            for (let i = 0; i < appListModel.count; i++) {
                if (appListModel.get(i).visible) {
                    selectedIndex = i
                    break
                }
            }
        }
    }
    
    function launchSelectedApp() {
        if (selectedIndex >= 0 && selectedIndex < appListModel.count) {
            const item = appListModel.get(selectedIndex)
            if (item.visible) {
                launchApp(item.appCommand)
            }
        }
    }
    
    function launchApp(command) {
        console.log("Launching app:", command)
        // Close the launcher
        root.isVisible = false
        
        // Launch the app
        Quickshell.execDetached(["sh", "-c", command + " &"])
    }
    
    onIsVisibleChanged: {
        if (isVisible) {
            searchInput.forceActiveFocus()
            searchInput.text = ""
            selectedIndex = 0
        }
    }
}