import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 1000
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property bool enableBlur: false
    
    property int selectedIndex: -1
    property int hoverIndex: -1
    property string searchText: ""
    property bool hasLoadedApps: false
    
    signal requestClose()
    
    focus: true
    
    // Filtered model for search
    ListModel {
        id: filteredModel
    }
    
    function updateFilteredModel() {
        filteredModel.clear()
        const search = searchText.toLowerCase()
        
        // Create array for sorting
        let apps = []
        for (let i = 0; i < appListModel.count; i++) {
            const app = appListModel.get(i)
            if (search === "" || 
                app.appName.toLowerCase().includes(search) ||
                app.appDescription.toLowerCase().includes(search)) {
                apps.push({
                    appName: app.appName,
                    appDescription: app.appDescription,
                    appIcon: app.appIcon,
                    appCommand: app.appCommand,
                    needsTerminal: app.needsTerminal
                })
            }
        }
        
        // Sort alphabetically
        apps.sort((a, b) => a.appName.toLowerCase().localeCompare(b.appName.toLowerCase()))
        
        // Add to filtered model
        for (let app of apps) {
            filteredModel.append(app)
        }
    }
    
    // Keyboard navigation
    Keys.onEscapePressed: {
        if (searchText !== "") {
            searchText = ""
            searchField.text = ""
        } else {
            requestClose()
        }
    }
    
    Keys.onPressed: (event) => {
        // Focus search field on typing
        if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z && !event.modifiers) {
            searchField.forceActiveFocus()
        }
    }
    
    // Reset selection when widget becomes visible
    onIsVisibleChanged: {
        if (isVisible) {
            selectedIndex = -1
            hoverIndex = -1
            searchText = ""
            searchField.text = ""
            // Lazy loading: only load apps on first open
            if (!hasLoadedApps) {
                hasLoadedApps = true
                loadApps()
            }
            blurSettingsLoader.running = true
        }
    }
    
    onSearchTextChanged: updateFilteredModel()
    
    // Load blur setting
    Process {
        id: blurSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                blurSettingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        root.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Process to load apps
    Process {
        id: appLoader
        running: false
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
                            needsTerminal: parts.length >= 5 ? (parts[4].toLowerCase() === 'true') : false
                        })
                    }
                }
                console.log("Loaded", appListModel.count, "applications")
                updateFilteredModel()
            }
        }
        
        onRunningChanged: {
            if (!running) {
                appLoader.running = false
            }
        }
    }
    
    // Function to load/reload applications
    function loadApps() {
        appListModel.clear()
        appLoader.running = true
    }
    
    // Don't load apps on startup - wait until first open (lazy loading)
    Component.onCompleted: {
        // Apps will load when first opened via onIsVisibleChanged
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Search field
        Rectangle {
            width: parent.width - 48
            anchors.horizontalCenter: parent.horizontalCenter
            height: 42
            color: ThemeManager.surface0
            radius: 10
            border.width: 2
            border.color: searchField.activeFocus ? ThemeManager.accentBlue : "transparent"
            
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: ThemeManager.fgSecondary
                }
                
                TextInput {
                    id: searchField
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Maple Mono NF"
                    font.pixelSize: 13
                    color: ThemeManager.fgPrimary
                    selectionColor: ThemeManager.accentBlue
                    selectedTextColor: ThemeManager.bgBase
                    
                    Text {
                        anchors.fill: parent
                        text: "Search applications..."
                        font: searchField.font
                        color: ThemeManager.fgTertiary
                        visible: !searchField.text && !searchField.activeFocus
                    }
                    
                    onTextChanged: root.searchText = text
                    
                    Keys.onReturnPressed: {
                        if (filteredModel.count > 0) {
                            launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                        }
                    }
                    Keys.onEnterPressed: {
                        if (filteredModel.count > 0) {
                            launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                        }
                    }
                }
            }
        }
        
        // Apps grid with overlay for filtering
        Item {
            width: parent.width
            height: parent.height - 90
            
            // Base grid (all apps)
            GridView {
                id: gridView
                anchors.fill: parent
                cellWidth: width / 6
                cellHeight: 120
                clip: true
                visible: root.searchText === ""
                
                model: ListModel {
                    id: appListModel
                }
                
                delegate: Item {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 12
                        
                        Rectangle {
                            width: 64
                            height: 64
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: appMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
                            radius: 12
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            Item {
                                anchors.centerIn: parent
                                width: 48
                                height: 48
                                
                                Image {
                                    id: appIconImage
                                    anchors.fill: parent
                                    sourceSize.width: 48
                                    sourceSize.height: 48
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                    visible: status === Image.Ready
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 32
                                    color: appMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                    visible: !appIconImage.visible
                                }
                            }
                        }
                        
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: model.appName
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: appMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }
            
            // Filtered grid (search results)
            GridView {
                id: filteredGridView
                anchors.fill: parent
                cellWidth: width / 6
                cellHeight: 120
                clip: true
                visible: root.searchText !== ""
                
                model: filteredModel
                
                delegate: Item {
                    width: filteredGridView.cellWidth
                    height: filteredGridView.cellHeight
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 12
                        
                        Rectangle {
                            width: 64
                            height: 64
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: filteredMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
                            radius: 12
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            Item {
                                anchors.centerIn: parent
                                width: 48
                                height: 48
                                
                                Image {
                                    id: filteredIconImage
                                    anchors.fill: parent
                                    sourceSize.width: 48
                                    sourceSize.height: 48
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                    visible: status === Image.Ready
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 32
                                    color: filteredMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                    visible: !filteredIconImage.visible
                                }
                            }
                        }
                        
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: model.appName
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: filteredMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }
        }
    }
    
    function launchApp(command, needsTerminal) {
        console.log("Launching app:", command, "(Terminal:", needsTerminal, ")")
        root.requestClose()
        Qt.callLater(() => {
            if (needsTerminal) {
                // Launch in Kitty terminal
                Quickshell.execDetached(["hyprctl", "dispatch", "exec", "kitty -e sh -c '" + command + "'"])
            } else {
                // Use hyprctl dispatch for proper window management
                Quickshell.execDetached(["hyprctl", "dispatch", "exec", command])
            }
        })
    }
}
