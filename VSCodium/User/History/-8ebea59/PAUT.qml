import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 700
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property var settings: ({})
    property var themes: []
    
    signal closeRequested()
    signal settingsUpdated()  // Signal to notify when settings change
    
    focus: true
    Keys.onEscapePressed: closeRequested()
    
    onIsVisibleChanged: {
        if (isVisible) {
            loadSettings()
            loadThemes()
            root.forceActiveFocus()
        }
    }
    
    // Load settings from JSON file
    function loadSettings() {
        settingsLoader.running = true
    }
    
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.settings = JSON.parse(data)
                    console.log("Settings loaded:", JSON.stringify(root.settings))
                    updateUI()
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
            }
        }
    }
    
    // Save settings to JSON file
    function saveSettings() {
        const json = JSON.stringify(root.settings, null, 2)
        console.log("Saving settings:", json)
        
        // Use cat with heredoc for more reliable writing
        const command = `cat > ~/.config/quickshell/settings.json << 'SETTINGSEOF'
${json}
SETTINGSEOF`
        
        Quickshell.execDetached(["sh", "-c", command])
        console.log("Settings saved to file")
        settingsUpdated()  // Emit signal when settings are saved
    }
    
    // Reload Quickshell to apply settings
    function reloadQuickshell() {
        console.log("Reloading Quickshell...")
        Quickshell.execDetached(["quickshell", "--reload"])
    }
    
    // Save and apply settings
    function applySettings() {
        saveSettings()
        reloadQuickshell()
    }
    
    // Update UI from loaded settings
    function updateUI() {
        if (!root.settings.general) return
        
        latitudeField.text = root.settings.general.weatherLatitude || ""
        longitudeField.text = root.settings.general.weatherLongitude || ""
        useFahrenheit.checked = root.settings.general.useFahrenheit !== false
        clockFormat24hr.checked = root.settings.general.clockFormat24hr !== false
        showSeconds.checked = root.settings.general.showSeconds === true
        
        if (root.settings.screenshot) {
            delaySpinBox.value = root.settings.screenshot.defaultDelay || 0
            saveToDiskCheck.checked = root.settings.screenshot.saveToDisk !== false
            copyToClipboardCheck.checked = root.settings.screenshot.copyToClipboard === true
            saveLocationField.text = root.settings.screenshot.saveLocation || "~/Pictures/Screenshots"
        }
    }
    
    // Load available themes
    function loadThemes() {
        themeLoader.running = true
    }
    
    Process {
        id: themeLoader
        running: false
        command: ["sh", "-c", "ls ~/.config/hypr/themes/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//' | sort"]
        
        stdout: SplitParser {
            onRead: data => {
                const themeName = data.trim()
                if (themeName.length > 0 && root.themes.indexOf(themeName) === -1) {
                    root.themes.push(themeName)
                    themeModel.append({name: themeName})
                }
            }
        }
    }
    
    ListModel {
        id: themeModel
    }
    
    function applyTheme(themeName) {
        console.log("Applying theme:", themeName)
        root.settings.theme.current = themeName
        saveSettings()
        
        Quickshell.execDetached([
            "bash", "-c",
            `. ~/.config/quickshell/theme-switcher-quickshell 2>/dev/null; apply_theme "$HOME/.config/hypr/themes/${themeName}.conf" "${themeName}"`
        ])
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "Quickshell Settings"
                font.family: "MapleMono NF"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
            }
            
            // Close button
            Rectangle {
                width: 32
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 6
                color: closeMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.family: "Maple Mono NF"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: closeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgSecondary
                }
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }
        }
        
        // Tab Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: ThemeManager.surface0
            radius: 12
            
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                Repeater {
                    model: ["General", "Screenshot", "Theme"]
                    
                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: parent.height
                        radius: 8
                        color: tabBar.currentIndex === index ? ThemeManager.accentBlue : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: tabBar.currentIndex === index ? ThemeManager.bgBase : ThemeManager.fgPrimary
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabBar.currentIndex = index
                        }
                    }
                }
            }
            
            QtObject {
                id: tabBar
                property int currentIndex: 0
            }
        }
        
        // Content Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 12
            color: ThemeManager.surface0
            radius: 12
            
            StackLayout {
                anchors.fill: parent
                anchors.margins: 16
                currentIndex: tabBar.currentIndex
                
                // General Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 24
                        
                        // Weather Settings Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Weather Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            // Temperature Unit
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: useFahrenheit.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: useFahrenheit.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            useFahrenheit.checked = !useFahrenheit.checked
                                            root.settings.general.useFahrenheit = useFahrenheit.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Use Fahrenheit (uncheck for Celsius)"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: useFahrenheit
                                    property bool checked: true
                                }
                            }
                            
                            // Weather Location
                            Column {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    text: "Location"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: ThemeManager.fgSecondary
                                }
                                
                                Text {
                                    width: parent.width
                                    text: "Leave empty to auto-detect by IP, or enter coordinates for accuracy:"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.WordWrap
                                }
                                
                                Row {
                                    spacing: 12
                                    
                                    Column {
                                        spacing: 4
                                        
                                        Text {
                                            text: "Latitude"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgSecondary
                                        }
                                        
                                        Rectangle {
                                            width: 200
                                            height: 32
                                            color: ThemeManager.bgBase
                                            radius: 6
                                            border.width: 1
                                            border.color: latitudeField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                            
                                            TextInput {
                                                id: latitudeField
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                font.family: "MapleMono NF"
                                                font.pixelSize: 12
                                                color: ThemeManager.fgPrimary
                                                verticalAlignment: TextInput.AlignVCenter
                                                selectByMouse: true
                                                
                                                onEditingFinished: {
                                                    console.log("Latitude changed to:", text)
                                                    root.settings.general.weatherLatitude = text
                                                    saveSettings()
                                                }
                                                
                                                onTextChanged: {
                                                    console.log("Latitude text changed:", text)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 4
                                        
                                        Text {
                                            text: "Longitude"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgSecondary
                                        }
                                        
                                        Rectangle {
                                            width: 200
                                            height: 32
                                            color: ThemeManager.bgBase
                                            radius: 6
                                            border.width: 1
                                            border.color: longitudeField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                            
                                            TextInput {
                                                id: longitudeField
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                font.family: "MapleMono NF"
                                                font.pixelSize: 12
                                                color: ThemeManager.fgPrimary
                                                verticalAlignment: TextInput.AlignVCenter
                                                selectByMouse: true
                                                
                                                onEditingFinished: {
                                                    console.log("Longitude changed to:", text)
                                                    root.settings.general.weatherLongitude = text
                                                    saveSettings()
                                                }
                                                
                                                onTextChanged: {
                                                    console.log("Longitude text changed:", text)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Clock Settings Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Clock Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            // 24-hour format
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: clockFormat24hr.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: clockFormat24hr.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            clockFormat24hr.checked = !clockFormat24hr.checked
                                            root.settings.general.clockFormat24hr = clockFormat24hr.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Use 24-hour format"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: clockFormat24hr
                                    property bool checked: true
                                }
                            }
                            
                            // Show seconds
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showSeconds.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: showSeconds.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showSeconds.checked = !showSeconds.checked
                                            root.settings.general.showSeconds = showSeconds.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Show seconds"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: showSeconds
                                    property bool checked: false
                                }
                            }
                        }
                        
                        // Apply Button
                        Rectangle {
                            Layout.alignment: Qt.AlignRight
                            Layout.topMargin: 12
                            width: 120
                            height: 40
                            radius: 8
                            color: applyGeneralMouseArea.containsMouse ? ThemeManager.accentGreen : ThemeManager.surface1
                            border.width: 2
                            border.color: ThemeManager.accentGreen
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Apply"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: applyGeneralMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentGreen
                            }
                            
                            MouseArea {
                                id: applyGeneralMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    applySettings()
                                }
                            }
                        }
                    }
                }
                
                // Screenshot Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        
                        // Default Delay Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Default Delay"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: ThemeManager.accentBlue
                            }
                            
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 100
                                    height: 32
                                    color: "transparent"
                                    
                                    SpinBox {
                                        id: delaySpinBox
                                        anchors.fill: parent
                                        from: 0
                                        to: 10
                                        value: 0
                                        editable: true
                                        
                                        onValueModified: {
                                            root.settings.screenshot.defaultDelay = value
                                            saveSettings()
                                        }
                                        
                                        down.indicator: Rectangle {
                                            x: 0
                                            height: parent.height
                                            width: 28
                                            color: delaySpinBox.down.pressed ? Qt.darker(ThemeManager.accentBlue, 1.2) : ThemeManager.surface1
                                            radius: 6
                                            border.width: 1
                                            border.color: ThemeManager.surface2
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "-"
                                                font.family: "MapleMono NF"
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: ThemeManager.accentBlue
                                            }
                                        }
                                        
                                        up.indicator: Rectangle {
                                            x: delaySpinBox.width - width
                                            height: parent.height
                                            width: 28
                                            color: delaySpinBox.up.pressed ? Qt.darker(ThemeManager.accentBlue, 1.2) : ThemeManager.surface1
                                            radius: 6
                                            border.width: 1
                                            border.color: ThemeManager.surface2
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "+"
                                                font.family: "MapleMono NF"
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: ThemeManager.accentBlue
                                            }
                                        }
                                        
                                        contentItem: TextInput {
                                            x: 30
                                            width: parent.width - 60
                                            height: parent.height
                                            text: delaySpinBox.textFromValue(delaySpinBox.value, delaySpinBox.locale)
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                            readOnly: !delaySpinBox.editable
                                            validator: delaySpinBox.validator
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        }
                                        
                                        background: Rectangle {
                                            color: ThemeManager.bgBase
                                            radius: 6
                                            border.width: 1
                                            border.color: ThemeManager.surface2
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "seconds"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgSecondary
                                }
                            }
                        }
                        
                        // Output Options Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Output Options"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: ThemeManager.accentBlue
                            }
                            
                            // Save to Disk
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: saveToDiskCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: saveToDiskCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            saveToDiskCheck.checked = !saveToDiskCheck.checked
                                            root.settings.screenshot.saveToDisk = saveToDiskCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Save to disk"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: saveToDiskCheck
                                    property bool checked: true
                                }
                            }
                            
                            // Copy to Clipboard
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: copyToClipboardCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: copyToClipboardCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            copyToClipboardCheck.checked = !copyToClipboardCheck.checked
                                            root.settings.screenshot.copyToClipboard = copyToClipboardCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Copy to clipboard"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: copyToClipboardCheck
                                    property bool checked: false
                                }
                            }
                        }
                        
                        // Save Location Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Save Location"
                                font.family: "MapleMono NF"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: ThemeManager.accentBlue
                            }
                            
                            Row {
                                spacing: 8
                                
                                Rectangle {
                                    width: 350
                                    height: 32
                                    color: ThemeManager.bgBase
                                    radius: 6
                                    border.width: 1
                                    border.color: saveLocationField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                    
                                    TextInput {
                                        id: saveLocationField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                        verticalAlignment: TextInput.AlignVCenter
                                        selectByMouse: true
                                        text: "~/Pictures/Screenshots"
                                        
                                        onEditingFinished: {
                                            root.settings.screenshot.saveLocation = text
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: 42
                                    height: 32
                                    radius: 6
                                    color: browseMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 1
                                    border.color: ThemeManager.surface2
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: ""  // folder open icon
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: browseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                    }
                                    
                                    MouseArea {
                                        id: browseMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            // Open file picker
                                            Quickshell.execDetached(["thunar", "--dialog", saveLocationField.text || Quickshell.env("HOME")])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Theme Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    Column {
                        width: parent.parent.width
                        spacing: 12
                        
                        Repeater {
                            model: themeModel
                            
                            Rectangle {
                                width: parent.width
                                height: 60
                                radius: 8
                                color: themeMouseArea.containsMouse ? ThemeManager.surface2 : ThemeManager.surface1
                                
                                property string themeName: model.name
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12
                                    
                                    // Color chips - show palette preview
                                    Row {
                                        spacing: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Repeater {
                                            model: {
                                                // Return array of colors for each theme
                                                const name = parent.parent.parent.themeName.toLowerCase()
                                                if (name.includes("tokyo")) return ["#1a1b26", "#7aa2f7", "#9ece6a", "#e0af68", "#bb9af7", "#f7768e"]
                                                if (name.includes("catppuccin")) return ["#1e1e2e", "#89b4fa", "#a6e3a1", "#f9e2af", "#cba6f7", "#f38ba8"]
                                                if (name.includes("nord")) return ["#2e3440", "#88c0d0", "#a3be8c", "#ebcb8b", "#b48ead", "#bf616a"]
                                                if (name.includes("gruvbox")) return ["#282828", "#458588", "#98971a", "#d79921", "#b16286", "#cc241d"]
                                                if (name.includes("everforest")) return ["#2d353b", "#7fbbb3", "#a7c080", "#dbbc7f", "#d699b6", "#e67e80"]
                                                if (name.includes("dracula")) return ["#282a36", "#8be9fd", "#50fa7b", "#f1fa8c", "#bd93f9", "#ff79c6"]
                                                if (name.includes("rose")) return ["#191724", "#9ccfd8", "#ebbcba", "#f6c177", "#c4a7e7", "#eb6f92"]
                                                return [ThemeManager.bgBase, ThemeManager.accentBlue, ThemeManager.accentGreen, ThemeManager.accentYellow, ThemeManager.accentPurple, ThemeManager.accentRed]
                                            }
                                            
                                            Rectangle {
                                                width: 20
                                                height: 36
                                                radius: 4
                                                color: modelData
                                                border.width: 1
                                                border.color: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                                            }
                                        }
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        
                                        Text {
                                            text: model.name
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }
                                        
                                        Text {
                                            text: model.name === root.settings.theme.current ? "● Current" : ""
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 10
                                            color: ThemeManager.accentGreen
                                            visible: model.name === root.settings.theme.current
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: themeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        applyTheme(model.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

