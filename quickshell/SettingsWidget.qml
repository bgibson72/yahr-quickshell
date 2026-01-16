import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 800
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property var settings: ({})
    property string currentTheme: ""  // Separate property for reactive binding
    property var themes: []
    property bool applyButtonSuccess: false
    property bool enableBlur: false
    
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
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                settingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    root.settings = JSON.parse(buffer)
                    
                    // Initialize default structure if missing
                    if (!root.settings.general) {
                        root.settings.general = {
                            weatherLatitude: "",
                            weatherLongitude: "",
                            weatherCity: "",
                            weatherState: "",
                            weatherCountry: "",
                            openWeatherApiKey: "",
                            openWeatherApiKey: "",
                            useFahrenheit: true,
                            clockFormat24hr: true,
                            showSeconds: false,
                            enableBlur: false
                        }
                    }
                    if (!root.settings.screenshot) {
                        root.settings.screenshot = {
                            defaultDelay: 0,
                            saveToDisk: true,
                            copyToClipboard: false,
                            saveLocation: "~/Pictures/Screenshots"
                        }
                    }
                    if (!root.settings.systemTray) {
                        root.settings.systemTray = {
                            showBatteryDetails: false,
                            showVolumeDetails: false,
                            showNetworkDetails: false
                        }
                    }
                    if (!root.settings.bar) {
                        root.settings.bar = {
                            transparentBackground: false
                        }
                    }
                    if (!root.settings.theme) {
                        root.settings.theme = {
                            current: "TokyoNight"
                        }
                    }
                    
                    // Update the reactive currentTheme property
                    root.currentTheme = root.settings.theme.current || "TokyoNight"
                    
                    console.log("Settings loaded:", JSON.stringify(root.settings))
                    updateUI()
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                    // Initialize with defaults on error
                    root.settings = {
                        general: {
                            weatherLatitude: "",
                            weatherLongitude: "",
                            useFahrenheit: true,
                            clockFormat24hr: true,
                            showSeconds: false,
                            enableBlur: false
                        },
                        screenshot: {
                            defaultDelay: 0,
                            saveToDisk: true,
                            copyToClipboard: false,
                            saveLocation: "~/Pictures/Screenshots"
                        },
                        systemTray: {
                            showBatteryDetails: false,
                            showVolumeDetails: false,
                            showNetworkDetails: false
                        },
                        bar: {
                            transparentBackground: false
                        },
                        theme: {
                            current: "TokyoNight"
                        }
                    }
                    updateUI()
                }
                buffer = ""
            } else if (running) {
                buffer = ""
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
        
        // Show success feedback
        applyButtonSuccess = true
        successTimer.start()
        
        // Reload Quickshell after a brief delay to show feedback
        Qt.callLater(function() {
            reloadQuickshell()
        })
    }
    
    // Timer to reset success state
    Timer {
        id: successTimer
        interval: 1500
        repeat: false
        onTriggered: {
            applyButtonSuccess = false
        }
    }
    
    // Update UI from loaded settings
    function updateUI() {
        if (!root.settings.general) return
        
        latitudeField.text = root.settings.general.weatherLatitude || ""
        longitudeField.text = root.settings.general.weatherLongitude || ""
        cityField.text = root.settings.general.weatherCity || ""
        stateField.text = root.settings.general.weatherState || ""
        countryField.text = root.settings.general.weatherCountry || ""
        apiKeyField.text = root.settings.general.openWeatherApiKey || ""
        useFahrenheit.checked = root.settings.general.useFahrenheit !== false
        clockFormat24hr.checked = root.settings.general.clockFormat24hr !== false
        showSeconds.checked = root.settings.general.showSeconds === true
        
        if (root.settings.screenshot) {
            delaySpinBox.value = root.settings.screenshot.defaultDelay || 0
            saveToDiskCheck.checked = root.settings.screenshot.saveToDisk !== false
            copyToClipboardCheck.checked = root.settings.screenshot.copyToClipboard === true
            saveLocationField.text = root.settings.screenshot.saveLocation || "~/Pictures/Screenshots"
        }
        
        if (root.settings.systemTray) {
            showBatteryDetailsCheck.checked = root.settings.systemTray.showBatteryDetails === true
            showVolumeDetailsCheck.checked = root.settings.systemTray.showVolumeDetails === true
            showNetworkDetailsCheck.checked = root.settings.systemTray.showNetworkDetails === true
        }
        
        if (root.settings.bar) {
            transparentBackgroundCheck.checked = root.settings.bar.transparentBackground === true
            barPositionBottomCheck.checked = root.settings.bar.position === "bottom"
        }
    }
    
    // Load available themes
    function loadThemes() {
        themeLoader.running = true
    }
    
    Process {
        id: themeLoader
        running: false
        command: ["sh", "-c", "ls ~/.config/hypr/themes/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//' | grep -v '^active-theme$' | sort"]
        
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
        
        // Update the theme in settings
        if (!root.settings.theme) {
            root.settings.theme = {}
        }
        root.settings.theme.current = themeName
        
        // Update the reactive property
        root.currentTheme = themeName
        
        // Force the settings object to update by creating a new object
        root.settings = JSON.parse(JSON.stringify(root.settings))
        
        saveSettings()
        
        Quickshell.execDetached([
            "bash", "-c",
            `. ~/.config/quickshell/theme-switcher-quickshell 2>/dev/null; apply_theme "$HOME/.config/hypr/themes/${themeName}.conf" "${themeName}"`
        ])
        
        // Theme switch happens in background, no need to reload Quickshell
        // The theme-switcher-quickshell script handles all necessary updates
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "YahrShell Settings"
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
                    model: ["General", "Widgets", "Screenshots", "Bar", "Theme"]
                    
                    Rectangle {
                        width: (parent.width - 32) / 5
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
            id: contentArea
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
                        
                        // Placeholder for future general settings
                        Text {
                            Layout.fillWidth: true
                            text: "General settings will appear here"
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgSecondary
                            horizontalAlignment: Text.AlignHCenter
                            Layout.topMargin: 40
                        }
                    }
                }
                
                // Widgets Tab
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
                        }
                        
                        // Location Settings Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Location Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                width: parent.width
                                text: "Leave empty to auto-detect by IP, or enter coordinates for accuracy:"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.NoWrap
                                elide: Text.ElideNone
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
                                            
                                            onTextChanged: {
                                                root.settings.general.weatherLatitude = text
                                                console.log("Latitude changed to:", text)
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
                                            
                                            onTextChanged: {
                                                root.settings.general.weatherLongitude = text
                                                console.log("Longitude changed to:", text)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                text: "Location Name (optional)"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                                topPadding: 8
                            }
                            
                            Row {
                                spacing: 12
                                
                                Column {
                                    spacing: 4
                                    
                                    Text {
                                        text: "City"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 150
                                        height: 32
                                        color: ThemeManager.bgBase
                                        radius: 6
                                        border.width: 1
                                        border.color: cityField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                        
                                        TextInput {
                                            id: cityField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                root.settings.general.weatherCity = text
                                            }
                                        }
                                    }
                                }
                                
                                Column {
                                    spacing: 4
                                    
                                    Text {
                                        text: "State/Region"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 100
                                        height: 32
                                        color: ThemeManager.bgBase
                                        radius: 6
                                        border.width: 1
                                        border.color: stateField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                        
                                        TextInput {
                                            id: stateField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                root.settings.general.weatherState = text
                                            }
                                        }
                                    }
                                }
                                
                                Column {
                                    spacing: 4
                                    
                                    Text {
                                        text: "Country"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 100
                                        height: 32
                                        color: ThemeManager.bgBase
                                        radius: 6
                                        border.width: 1
                                        border.color: countryField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                        
                                        TextInput {
                                            id: countryField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                root.settings.general.weatherCountry = text
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // OpenWeather API Key Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12
                            topPadding: 8
                            
                            Text {
                                text: "OpenWeather API Key (optional, for 5-day forecast)"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            
                            Rectangle {
                                width: 420
                                height: 32
                                color: ThemeManager.bgBase
                                radius: 6
                                border.width: 1
                                border.color: apiKeyField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                
                                TextInput {
                                    id: apiKeyField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgPrimary
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    echoMode: TextInput.Password
                                    
                                    onTextChanged: {
                                        root.settings.general.openWeatherApiKey = text
                                    }
                                }
                            }
                            
                            Text {
                                text: "Get a free API key at openweathermap.org/api"
                                font.family: "MapleMono NF"
                                font.pixelSize: 10
                                color: ThemeManager.fgTertiary
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
                    }
                }
                
                // Screenshots Tab
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
                                
                                Row {
                                    spacing: 4
                                    
                                    // Decrease button
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 6
                                        color: decreaseMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                        border.width: 1
                                        border.color: ThemeManager.surface2
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "−"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: decreaseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                        }
                                        
                                        MouseArea {
                                            id: decreaseMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.settings.screenshot.defaultDelay > 0) {
                                                    root.settings.screenshot.defaultDelay--
                                                    delaySpinBox.value = root.settings.screenshot.defaultDelay
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Value display
                                    Rectangle {
                                        width: 50
                                        height: 32
                                        radius: 6
                                        color: ThemeManager.bgBase
                                        border.width: 1
                                        border.color: ThemeManager.surface2
                                        
                                        SpinBox {
                                            id: delaySpinBox
                                            visible: false
                                            from: 0
                                            to: 10
                                            value: 0
                                            
                                            onValueChanged: {
                                                delayText.text = value.toString()
                                            }
                                        }
                                        
                                        Text {
                                            id: delayText
                                            anchors.centerIn: parent
                                            text: "0"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }
                                    }
                                    
                                    // Increase button
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 6
                                        color: increaseMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                        border.width: 1
                                        border.color: ThemeManager.surface2
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: increaseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                        }
                                        
                                        MouseArea {
                                            id: increaseMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.settings.screenshot.defaultDelay < 10) {
                                                    root.settings.screenshot.defaultDelay++
                                                    delaySpinBox.value = root.settings.screenshot.defaultDelay
                                                }
                                            }
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
                                        
                                        onTextChanged: {
                                            root.settings.screenshot.saveLocation = text
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
                                        text: "󰉋"  // folder open icon (nf-md-folder_open)
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 18
                                        color: browseMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                    }
                                    
                                    MouseArea {
                                        id: browseMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            // Open file manager in the save location
                                            var path = saveLocationField.text.replace("~", Quickshell.env("HOME"))
                                            console.log("Opening file manager at:", path)
                                            Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/launch-thunar.sh", path])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Bar Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 24
                        
                        // Bar Appearance Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Bar Appearance"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                text: "Configure bar background and system tray details"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            
                            // Transparent Background Toggle
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: transparentBackgroundCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: transparentBackgroundCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            transparentBackgroundCheck.checked = !transparentBackgroundCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.transparentBackground = transparentBackgroundCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Transparent bar background"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: transparentBackgroundCheck
                                    property bool checked: false
                                }
                            }
                            
                            // Bar Position Toggle
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: barPositionBottomCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: barPositionBottomCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            barPositionBottomCheck.checked = !barPositionBottomCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.position = barPositionBottomCheck.checked ? "bottom" : "top"
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Position bar at bottom"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: barPositionBottomCheck
                                    property bool checked: false
                                }
                            }
                            
                            // Show Battery Details
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showBatteryDetailsCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: showBatteryDetailsCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showBatteryDetailsCheck.checked = !showBatteryDetailsCheck.checked
                                            if (!root.settings.systemTray) root.settings.systemTray = {}
                                            root.settings.systemTray.showBatteryDetails = showBatteryDetailsCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Show battery percentage (e.g., \"85%\")"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: showBatteryDetailsCheck
                                    property bool checked: false
                                }
                            }
                            
                            // Show Volume Details
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showVolumeDetailsCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: showVolumeDetailsCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showVolumeDetailsCheck.checked = !showVolumeDetailsCheck.checked
                                            if (!root.settings.systemTray) root.settings.systemTray = {}
                                            root.settings.systemTray.showVolumeDetails = showVolumeDetailsCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Show volume percentage (e.g., \"75%\")"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: showVolumeDetailsCheck
                                    property bool checked: false
                                }
                            }
                            
                            // Show Network Details
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showNetworkDetailsCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: showNetworkDetailsCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showNetworkDetailsCheck.checked = !showNetworkDetailsCheck.checked
                                            if (!root.settings.systemTray) root.settings.systemTray = {}
                                            root.settings.systemTray.showNetworkDetails = showNetworkDetailsCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Show network upload/download speeds (e.g., \"↑ 2.5 Mb/s ↓ 10.3 Mb/s\")"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: showNetworkDetailsCheck
                                    property bool checked: false
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
                        
                        // Info text at top
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Please allow 30-45 seconds for the theme to propagate to all UI elements once selected"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                font.italic: true
                                color: ThemeManager.fgSecondary
                            }
                        }
                        
                        Repeater {
                            model: themeModel
                            
                            Rectangle {
                                width: parent.width
                                height: 180
                                radius: 8
                                color: themeMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                border.width: themeMouseArea.containsMouse ? 2 : 0
                                border.color: ThemeManager.accentBlue
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Behavior on border.width {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                property string themeName: model.name
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 20
                                    
                                    // Theme name and current indicator
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        width: 150
                                        
                                        Text {
                                            text: model.name
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 15
                                            font.weight: Font.Medium
                                            color: themeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                        
                                        Text {
                                            text: model.name === root.currentTheme ? "● Current" : ""
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 10
                                            color: themeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentGreen
                                            visible: model.name === root.currentTheme
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                    }
                                    
                                    // Theme mockup thumbnail
                                    Rectangle {
                                        width: 420
                                        height: 150
                                        radius: 6
                                        color: ThemeManager.bgMantle
                                        border.width: 1
                                        border.color: ThemeManager.border0
                                        clip: true
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/theme-mockups/" + model.name.toLowerCase() + ".png"
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            antialiasing: true
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "No preview"
                                                font.family: "MapleMono NF"
                                                font.pixelSize: 10
                                                color: ThemeManager.fgTertiary
                                                visible: parent.status === Image.Error
                                            }
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
            
            // Apply Button Overlay (bottom-right corner)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 20
                width: 120
                height: 40
                radius: 8
                color: applyButtonSuccess ? ThemeManager.accentGreen : 
                       (applyButtonMouseArea.containsMouse ? ThemeManager.accentGreen : ThemeManager.surface1)
                border.width: 2
                border.color: ThemeManager.accentGreen
                visible: tabBar.currentIndex === 0 || tabBar.currentIndex === 1  // Show on General and Screenshots tabs only
                z: 100  // Ensure it's on top
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: applyButtonSuccess ? "✓ Applied!" : "Apply"
                    font.family: "MapleMono NF"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: applyButtonSuccess ? ThemeManager.bgBase :
                           (applyButtonMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentGreen)
                    
                    Behavior on text {
                        SequentialAnimation {
                            PropertyAnimation { duration: 100 }
                        }
                    }
                }
                
                MouseArea {
                    id: applyButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !applyButtonSuccess  // Disable while showing success
                    
                    onClicked: {
                        applySettings()
                    }
                }
            }
        }
    }
}
