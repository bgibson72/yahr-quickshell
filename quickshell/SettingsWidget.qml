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
    property bool bentoSettingsChanged: false  // Track if Bento settings were modified
    
    signal closeRequested()
    signal settingsUpdated()  // Signal to notify when settings change
    
    focus: true
    Keys.onEscapePressed: closeRequested()
    
    onIsVisibleChanged: {
        if (isVisible) {
            loadSettings()
            loadThemes()
            root.forceActiveFocus()
            bentoSettingsChanged = false  // Reset change tracking when opening panel
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
                            useFahrenheit: true,
                            clockFormat24hr: true,
                            showSeconds: false,
                            enableBlur: false
                        }
                    }
                    if (!root.settings.calendar) {
                        root.settings.calendar = {
                            filePath: "~/.config/quickshell/calendar.ics"
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
                    if (!root.settings.bento) {
                        root.settings.bento = {
                            enabled: false,
                            twelveHourFormat: true,
                            greetingName: "",
                            bentoPath: Quickshell.env("HOME") + "/bento"
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
                    if (!root.settings.wallpaper) {
                        root.settings.wallpaper = {
                            showAllWallpapers: false
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
        // Capture current values from all fields before saving
        if (!root.settings.calendar) {
            root.settings.calendar = {}
        }
        root.settings.calendar.filePath = calendarPathField.text
        
        let interval = parseInt(refreshIntervalInput.text)
        if (!isNaN(interval) && interval >= 0) {
            root.settings.calendar.refreshInterval = interval
        }
        
        // Note: Bento config is only updated if user actually changed Bento settings
        if (root.settings.bento && bentoSettingsChanged) {
            updateBentoConfig()
        }
        
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
        
        // Calendar settings
        if (root.settings.calendar) {
            calendarPathField.text = root.settings.calendar.filePath || "~/.config/quickshell/calendar.ics"
            refreshIntervalInput.text = root.settings.calendar.refreshInterval?.toString() ?? "15"
        } else {
            calendarPathField.text = "~/.config/quickshell/calendar.ics"
            refreshIntervalInput.text = "15"
        }
        
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
            // Set background style (default to translucent if not set)
            var bgStyle = root.settings.bar.backgroundStyle || "translucent"
            barSolidCheck.checked = (bgStyle === "opaque")
            
            // Set slider value from barOpacity setting (default 0.70)
            if (root.settings.bar.barOpacity !== undefined) {
                barOpacitySlider.value = root.settings.bar.barOpacity
            } else {
                barOpacitySlider.value = 0.70
            }
            
            barPositionBottomCheck.checked = root.settings.bar.position === "bottom"
            barAutoHideCheck.checked = root.settings.bar.autoHide === true
        }
        
        // Bento settings
        if (root.settings.bento) {
            bentoEnabled.checked = root.settings.bento.enabled === true
            bentoTwelveHour.checked = root.settings.bento.twelveHourFormat !== false
            bentoNameField.text = root.settings.bento.greetingName || ""
            bentoPathField.text = root.settings.bento.bentoPath || (Quickshell.env("HOME") + "/bento")
        }
        
        // Wallpaper settings
        if (root.settings.wallpaper) {
            showAllWallpapers.checked = root.settings.wallpaper.showAllWallpapers === true
        }
    }
    
    // Update Bento config.js file
    function updateBentoConfig() {
        if (!root.settings.bento) return
        
        var bentoPath = root.settings.bento.bentoPath || (Quickshell.env("HOME") + "/bento")
        var configPath = bentoPath + "/config.js"
        
        console.log("Updating Bento config at:", configPath)
        console.log("  twelveHourFormat:", root.settings.bento.twelveHourFormat)
        console.log("  greetingName:", root.settings.bento.greetingName)
        
        // Update twelveHourFormat using bash script for reliability
        var updateTimeFormat = `sed -i "s/twelveHourFormat: \\(true\\|false\\)/twelveHourFormat: ${root.settings.bento.twelveHourFormat ? "true" : "false"}/" "${configPath}"`
        Quickshell.execDetached(["bash", "-c", updateTimeFormat])
        
        // Update ONLY the greeting name in the general settings (line ~14)
        // This pattern specifically targets line 14 which is the main name field after "// General" comment
        var updateName = `sed -i "14s/name: '[^']*'/name: '${root.settings.bento.greetingName}'/" "${configPath}"`
        Quickshell.execDetached(["bash", "-c", updateName])
        
        console.log("✓ Bento config.js updated - refresh your browser to see changes")
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
                    model: ["Widgets", "Screenshots", "Bar", "Theme", "Bento"]
                    
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
                
                // Widgets Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 32
                        
                        // ========== CLOCK SETTINGS ==========
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: ThemeManager.accentBlue
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "⏰ Clock Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 18
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
                        
                        // ========== CALENDAR SETTINGS ==========
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: ThemeManager.accentBlue
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "📅 Calendar Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                width: parent.width
                                text: "Configure your calendar integration (supports multiple files):"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                            }
                            
                            Column {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    text: "Calendar File(s)"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                }
                                
                                Row {
                                    spacing: 12
                                    width: parent.width
                                    
                                    Rectangle {
                                        width: parent.width - 140
                                        height: 32
                                        radius: 6
                                        color: ThemeManager.bgMantle
                                        border.width: 1
                                        border.color: calendarPathField.activeFocus ? ThemeManager.accentBlue : ThemeManager.border0
                                        
                                        TextInput {
                                            id: calendarPathField
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            text: "~/.config/quickshell/calendar.ics"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgPrimary
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            
                                            onEditingFinished: {
                                                if (!root.settings.calendar) {
                                                    root.settings.calendar = {}
                                                }
                                                root.settings.calendar.filePath = text
                                            }
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: 120
                                        height: 32
                                        radius: 6
                                        color: filePickerMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Browse..."
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: filePickerMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                        
                                        MouseArea {
                                            id: filePickerMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                filePickerProcess.running = true
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Process {
                                id: filePickerProcess
                                running: false
                                command: ["zenity", "--file-selection", "--title=Select Calendar File", "--file-filter=Calendar files (ics) | *.ics", "--file-filter=All files | *"]
                                
                                property string buffer: ""
                                
                                stdout: SplitParser {
                                    onRead: data => {
                                        filePickerProcess.buffer += data
                                    }
                                }
                                
                                onRunningChanged: {
                                    if (!running && buffer !== "") {
                                        const selectedPath = buffer.trim()
                                        if (selectedPath) {
                                            calendarPathField.text = selectedPath
                                            if (!root.settings.calendar) {
                                                root.settings.calendar = {}
                                            }
                                            root.settings.calendar.filePath = selectedPath
                                        }
                                        buffer = ""
                                    } else if (running) {
                                        buffer = ""
                                    }
                                }
                            }
                            
                            Text {
                                width: parent.width
                                text: "Supports iCal format (.ics files) or URLs. You can use:\n• Local file: ~/.config/quickshell/calendar.ics\n• Google Calendar URL: https://calendar.google.com/calendar/ical/...\n• Multiple sources (separate with commas or spaces)"
                                font.family: "MapleMono NF"
                                font.pixelSize: 10
                                color: ThemeManager.fgTertiary
                                wrapMode: Text.WordWrap
                            }
                            
                            // Calendar Refresh Interval
                            Column {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    text: "Auto-Refresh Interval (minutes)"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: ThemeManager.fgPrimary
                                }
                                
                                Row {
                                    spacing: 12
                                    
                                    Rectangle {
                                        width: 100
                                        height: 32
                                        radius: 6
                                        color: ThemeManager.bgMantle
                                        border.width: 1
                                        border.color: refreshIntervalInput.activeFocus ? ThemeManager.accentBlue : ThemeManager.border0
                                        
                                        TextInput {
                                            id: refreshIntervalInput
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: root.settings.calendar?.refreshInterval ?? "15"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            validator: IntValidator { bottom: 0; top: 1440 }
                                            
                                            onEditingFinished: {
                                                let interval = parseInt(text)
                                                if (isNaN(interval) || interval < 0) {
                                                    text = "15"
                                                    interval = 15
                                                }
                                                if (!root.settings.calendar) {
                                                    root.settings.calendar = {}
                                                }
                                                root.settings.calendar.refreshInterval = interval
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "minutes (0 = disabled)"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                }
                                
                                Text {
                                    width: parent.width
                                    text: "How often to refresh calendar data from URLs. Set to 0 to disable auto-refresh."
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                        
                        // ========== WALLPAPER SETTINGS ==========
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: ThemeManager.accentBlue
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "🖼️ Wallpaper Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                width: parent.width
                                text: "Configure wallpaper picker behavior:"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                            }
                            
                            // Show all wallpapers toggle
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showAllWallpapers.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: showAllWallpapers.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showAllWallpapers.checked = !showAllWallpapers.checked
                                            if (!root.settings.wallpaper) {
                                                root.settings.wallpaper = {}
                                            }
                                            root.settings.wallpaper.showAllWallpapers = showAllWallpapers.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Column {
                                    spacing: 4
                                    
                                    Text {
                                        text: "Show all wallpapers"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }
                                    
                                    Text {
                                        width: 600
                                        text: "When enabled, wallpaper picker shows all images from ~/Pictures/Wallpapers (including subfolders). When disabled, shows only theme-specific wallpapers."
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                        wrapMode: Text.WordWrap
                                    }
                                }
                                
                                QtObject {
                                    id: showAllWallpapers
                                    property bool checked: false
                                }
                            }
                        }
                        
                        // ========== WEATHER SETTINGS ==========
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: ThemeManager.accentBlue
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "🌤️ Weather Settings"
                                font.family: "MapleMono NF"
                                font.pixelSize: 18
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
                        
                        // Weather Location Settings
                        Column {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                width: parent.width
                                text: "Location (leave empty to auto-detect, or enter coordinates for accuracy):"
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
                            
                            // Bar Background Style
                            Column {
                                spacing: 16
                                
                                Text {
                                    text: "Bar Background Style"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: ThemeManager.fgPrimary
                                }
                                
                                // Solid Background Toggle
                                Row {
                                    spacing: 12
                                    leftPadding: 20
                                    
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 4
                                        color: barSolidCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 16
                                            color: ThemeManager.fgPrimary
                                            visible: barSolidCheck.checked
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                barSolidCheck.checked = !barSolidCheck.checked
                                                if (!root.settings.bar) root.settings.bar = {}
                                                if (barSolidCheck.checked) {
                                                    root.settings.bar.backgroundStyle = "opaque"
                                                } else {
                                                    // Use transparency slider value
                                                    root.settings.bar.backgroundStyle = "translucent"
                                                }
                                                saveSettings()
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Solid background (no transparency)"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }
                                }
                                
                                // Opacity Slider
                                Column {
                                    spacing: 8
                                    leftPadding: 20
                                    width: parent.width - 40
                                    opacity: barSolidCheck.checked ? 0.5 : 1.0
                                    
                                    Row {
                                        spacing: 12
                                        width: parent.width
                                        
                                        Text {
                                            text: "Transparency: " + Math.round((1.0 - barOpacitySlider.value) * 100) + "%"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            width: 180
                                        }
                                        
                                        Text {
                                            text: "(Opacity: " + Math.round(barOpacitySlider.value * 100) + "%)"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgSecondary
                                        }
                                    }
                                    
                                    // Slider
                                    Item {
                                        width: parent.width
                                        height: 40
                                        
                                        Rectangle {
                                            id: sliderTrack
                                            anchors.centerIn: parent
                                            width: parent.width
                                            height: 6
                                            radius: 3
                                            color: ThemeManager.surface2
                                            
                                            Rectangle {
                                                width: sliderHandle.x + sliderHandle.width / 2
                                                height: parent.height
                                                radius: parent.radius
                                                color: ThemeManager.accentBlue
                                            }
                                        }
                                        
                                        Rectangle {
                                            id: sliderHandle
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: sliderMouseArea.containsMouse || sliderMouseArea.pressed ? 
                                                   ThemeManager.accentBlue : ThemeManager.fgPrimary
                                            border.width: 2
                                            border.color: ThemeManager.accentBlue
                                            y: (parent.height - height) / 2
                                            
                                            property real value: barOpacitySlider.value
                                            x: (sliderTrack.width - width) * value
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                        
                                        MouseArea {
                                            id: sliderMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: !barSolidCheck.checked
                                            
                                            function updateValue(mouse) {
                                                var newValue = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                                barOpacitySlider.value = newValue
                                                if (!root.settings.bar) root.settings.bar = {}
                                                root.settings.bar.barOpacity = newValue
                                                root.settings.bar.backgroundStyle = "translucent"
                                                saveSettings()
                                            }
                                            
                                            onPressed: updateValue(mouse)
                                            onPositionChanged: if (pressed) updateValue(mouse)
                                        }
                                    }
                                    
                                    Text {
                                        text: "Drag slider: 0% = fully transparent, 100% = completely opaque"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }
                                }
                                
                                QtObject {
                                    id: barSolidCheck
                                    property bool checked: false
                                }
                                
                                QtObject {
                                    id: barOpacitySlider
                                    property real value: 0.70  // default 70% opacity (30% transparent)
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
                            
                            // Auto-Hide Bar Toggle
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: barAutoHideCheck.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: barAutoHideCheck.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            barAutoHideCheck.checked = !barAutoHideCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.autoHide = barAutoHideCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Auto-hide bar"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }
                                    
                                    Text {
                                        text: "Bar slides out when mouse approaches edge"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }
                                
                                QtObject {
                                    id: barAutoHideCheck
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
                                    
                                    // Theme color chips
                                    Rectangle {
                                        width: 420
                                        height: 120
                                        radius: 6
                                        color: ThemeManager.bgMantle
                                        border.width: 1
                                        border.color: ThemeManager.border0
                                        clip: true
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        property var themePalettes: {
                                            "Catppuccin": ["#89b4fa", "#cba6f7", "#f5c2e7", "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5", "#89dceb", "#74c7ec"],
                                            "Dracula": ["#bd93f9", "#ff79c6", "#ff6e6e", "#ffb86c", "#f1fa8c", "#50fa7b", "#8be9fd", "#6272a4", "#44475a", "#282a36"],
                                            "Eldritch": ["#f16c75", "#ebfafa", "#7081d0", "#a48cf2", "#f16c75", "#37f499", "#04d1f9", "#f265b5", "#ffd700", "#323449"],
                                            "Everforest": ["#7fbbb3", "#d699b6", "#dbbc7f", "#e67e80", "#a7c080", "#83c092", "#d699b6", "#7fbbb3", "#e69875", "#374247"],
                                            "Gruvbox": ["#fe8019", "#fb4934", "#d3869b", "#b16286", "#fabd2f", "#b8bb26", "#8ec07c", "#689d6a", "#83a598", "#458588"],
                                            "Kanagawa": ["#7fb4ca", "#957fb8", "#d27e99", "#e46876", "#dca561", "#98bb6c", "#7fb4ca", "#938aa9", "#2d4f67", "#16161d"],
                                            "Material": ["#82aaff", "#c792ea", "#f07178", "#f78c6c", "#ffcb6b", "#c3e88d", "#89ddff", "#676e95", "#2e3c43", "#263238"],
                                            "Monochrome": ["#bebebe", "#a8a8a8", "#999999", "#888888", "#777777", "#666666", "#555555", "#444444", "#333333", "#252525"],
                                            "NightFox": ["#719cd6", "#9d79d6", "#d67ad2", "#f52a65", "#f4a261", "#dbc074", "#63cdcf", "#4d688e", "#2b3b51", "#131a24"],
                                            "Nord": ["#88c0d0", "#81a1c1", "#5e81ac", "#bf616a", "#d08770", "#ebcb8b", "#a3be8c", "#b48ead", "#4c566a", "#2e3440"],
                                            "Rosepine": ["#c4a7e7", "#ebbcba", "#eb6f92", "#f6c177", "#ea9a97", "#9ccfd8", "#31748f", "#26233a", "#1f1d2e", "#191724"],
                                            "Solarized": ["#268bd2", "#6c71c4", "#d33682", "#dc322f", "#cb4b16", "#b58900", "#859900", "#2aa198", "#073642", "#002b36"],
                                            "TokyoNight": ["#7aa2f7", "#bb9af7", "#f7768e", "#ff9e64", "#e0af68", "#9ece6a", "#73daca", "#7dcfff", "#1f2335", "#1a1b26"]
                                        }
                                        
                                        property var currentPalette: themePalettes[model.name] || ["#89b4fa", "#cba6f7", "#f5c2e7", "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5", "#89dceb", "#74c7ec"]
                                        
                                        Grid {
                                            anchors.centerIn: parent
                                            columns: 5
                                            rows: 2
                                            spacing: 8
                                            
                                            Repeater {
                                                model: parent.parent.currentPalette
                                                
                                                Rectangle {
                                                    width: 76
                                                    height: 48
                                                    radius: 6
                                                    color: modelData
                                                    border.width: 1
                                                    border.color: Qt.darker(modelData, 1.2)
                                                    antialiasing: true
                                                }
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
                
                // Bento Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 32
                        
                        // ========== BENTO BROWSER START PAGE ==========
                        Column {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: ThemeManager.accentBlue
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "🏠 Bento Browser Start Page"
                                font.family: "MapleMono NF"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                text: "Configure your beautiful browser start page"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgSecondary
                            }
                            
                            // Refresh reminder
                            Rectangle {
                                width: parent.width
                                height: 50
                                color: ThemeManager.accentYellow + "20"
                                radius: 8
                                border.width: 1
                                border.color: ThemeManager.accentYellow
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "💡"
                                        font.pixelSize: 18
                                    }
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "After applying settings, refresh your browser (F5) to see changes"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: ThemeManager.fgPrimary
                                    }
                                }
                            }
                            
                            // Enable Bento
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: bentoEnabled.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: bentoEnabled.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            bentoEnabled.checked = !bentoEnabled.checked
                                            if (root.settings.bento) {
                                                root.settings.bento.enabled = bentoEnabled.checked
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enable Bento Integration"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: bentoEnabled
                                    property bool checked: false
                                }
                            }
                            
                            // 12-hour format
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: bentoTwelveHour.checked ? ThemeManager.accentBlue : ThemeManager.surface1
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.bgBase
                                        visible: bentoTwelveHour.checked
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            bentoTwelveHour.checked = !bentoTwelveHour.checked
                                            if (root.settings.bento) {
                                                root.settings.bento.twelveHourFormat = bentoTwelveHour.checked
                                                bentoSettingsChanged = true
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Use 12-hour time format"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: bentoTwelveHour
                                    property bool checked: true
                                }
                            }
                            
                            // Greeting Name
                            Column {
                                spacing: 8
                                
                                Text {
                                    text: "Greeting Name"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: ThemeManager.accentBlue
                                }
                                
                                Rectangle {
                                    width: 300
                                    height: 36
                                    color: ThemeManager.bgBase
                                    radius: 6
                                    border.width: 1
                                    border.color: bentoNameField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                    
                                    TextInput {
                                        id: bentoNameField
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 13
                                        color: ThemeManager.fgPrimary
                                        verticalAlignment: TextInput.AlignVCenter
                                        selectByMouse: true
                                        
                                        onTextChanged: {
                                            if (root.settings.bento) {
                                                root.settings.bento.greetingName = text
                                                bentoSettingsChanged = true
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "This name will appear in the Bento greeting messages"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    font.italic: true
                                    color: ThemeManager.fgTertiary
                                }
                            }
                            
                            // Bento Path
                            Column {
                                spacing: 8
                                
                                Text {
                                    text: "Bento Installation Path"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: ThemeManager.accentBlue
                                }
                                
                                Rectangle {
                                    width: 400
                                    height: 36
                                    color: ThemeManager.bgBase
                                    radius: 6
                                    border.width: 1
                                    border.color: bentoPathField.activeFocus ? ThemeManager.accentBlue : ThemeManager.surface2
                                    
                                    TextInput {
                                        id: bentoPathField
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                        verticalAlignment: TextInput.AlignVCenter
                                        selectByMouse: true
                                        text: Quickshell.env("HOME") + "/bento"
                                        
                                        onTextChanged: {
                                            if (root.settings.bento) {
                                                root.settings.bento.bentoPath = text
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "Path where Bento is installed (typically ~/bento)"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    font.italic: true
                                    color: ThemeManager.fgTertiary
                                }
                            }
                            
                            // Quick Links Section
                            Column {
                                spacing: 12
                                
                                Text {
                                    text: "Quick Links Configuration"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: ThemeManager.accentBlue
                                }
                                
                                Text {
                                    text: "To edit your Bento quick links, open the config file directly:"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.WordWrap
                                }
                                
                                Row {
                                    spacing: 8
                                    
                                    Rectangle {
                                        width: 350
                                        height: 32
                                        color: ThemeManager.surface1
                                        radius: 6
                                        border.width: 1
                                        border.color: ThemeManager.surface2
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: bentoPathField.text + "/config.js"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: ThemeManager.fgSecondary
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideMiddle
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: 120
                                        height: 32
                                        radius: 6
                                        color: openConfigMouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface1
                                        border.width: 1
                                        border.color: ThemeManager.accentBlue
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Open in Editor"
                                            font.family: "MapleMono NF"
                                            font.pixelSize: 11
                                            color: openConfigMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.accentBlue
                                        }
                                        
                                        MouseArea {
                                            id: openConfigMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                var configPath = bentoPathField.text + "/config.js"
                                                console.log("Opening Bento config in editor:", configPath)
                                                
                                                // Use code (VS Code) to open the file
                                                Quickshell.execDetached(["code", configPath])
                                                console.log("Launched editor with command: code", configPath)
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "Edit the 'firstButtonsContainer' and 'secondButtonsContainer' arrays to customize your links"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    font.italic: true
                                    color: ThemeManager.fgTertiary
                                    wrapMode: Text.WordWrap
                                }
                            }
                            
                            // Browser Homepage Instructions
                            Column {
                                spacing: 8
                                
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: ThemeManager.surface2
                                    opacity: 0.5
                                }
                                
                                Text {
                                    text: "Browser Setup"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: ThemeManager.accentBlue
                                }
                                
                                Text {
                                    text: "To use Bento as your browser homepage, set your browser's homepage to:"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.WordWrap
                                }
                                
                                Rectangle {
                                    width: 500
                                    height: 36
                                    color: ThemeManager.bgBase
                                    radius: 6
                                    border.width: 1
                                    border.color: ThemeManager.surface2
                                    
                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        text: "file://" + bentoPathField.text + "/index.html"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.accentGreen
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Text {
                                    text: "The colors will automatically sync with your Quickshell theme!"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    font.italic: true
                                    color: ThemeManager.accentGreen
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
                visible: tabBar.currentIndex === 0 || tabBar.currentIndex === 1 || tabBar.currentIndex === 4  // Show on Widgets, Screenshots, and Bento tabs
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
