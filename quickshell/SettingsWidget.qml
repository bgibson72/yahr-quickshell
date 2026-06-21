import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 800
    height: 600
    // When embedded as a tab inside another widget, suppress the background
    property bool embedded: false
    color: embedded ? "transparent" : Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, ThemeManager.widgetOpacity)
    radius: embedded ? 0 : 16
    border.width: embedded ? 0 : (showWidgetBorders ? widgetBorderWidth : 0)
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true
    
    property bool isVisible: false
    property var settings: ({})
    property string currentTheme: ""  // Separate property for reactive binding
    property var themes: []
    property bool applyButtonSuccess: false
    property bool enableBlur: false
    property bool showWidgetBorders: true
    property int widgetBorderWidth: 1

    // Hyprland live-settings
    property int hyprBorderSize: 1
    property int hyprGapsIn: 5
    property int hyprGapsOut: 10
    property int hyprRounding: 12
    property bool hyprAnimations: true
    property bool hyprShadow: true
    property bool hyprBlur: true
    property int hyprBlurSize: 10
    
    signal closeRequested()
    signal settingsUpdated()  // Signal to notify when settings change
    
    focus: true
    Keys.onEscapePressed: closeRequested()
    
    onIsVisibleChanged: {
        if (isVisible) {
            loadSettings()
            loadThemes()
            loadFonts()
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
                            useFahrenheit: true,
                            clockFormat24hr: true,
                            showSeconds: false,
                            enableBlur: false,
                            showWidgetBorders: true,
                            widgetTransparent: true
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
                    if (!root.settings.bar) {
                        root.settings.bar = {
                            transparentBackground: false,
                            showQuickLaunch: true,
                            showSystemTray: true,
                            layoutPreset: "default",
                            barStyle: "single"
                        }
                    }
                    if (!root.settings.theme) {
                        root.settings.theme = {
                            current: "TokyoNight"
                        }
                    }
                    if (!root.settings.hypr) {
                        root.settings.hypr = {
                            borderSize: 1,
                            rounding: 12,
                            gapsIn: 5,
                            gapsOut: 10,
                            animations: true,
                            shadow: true,
                            blur: true,
                            blurSize: 10
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
                            dateFormat: "MDY",
                            dateLong: false,
                            showDayOfWeek: false,
                            enableBlur: false,
                            widgetTransparent: true
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
                            transparentBackground: false,
                            layoutPreset: "default",
                            barStyle: "single"
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
        dateFormatDMY.checked = root.settings.general.dateFormat === "DMY"
        dateLong.checked = root.settings.general.dateLong === true
        showDayOfWeek.checked = root.settings.general.showDayOfWeek === true
        
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
            showBorderCheck.checked = root.settings.bar.showBorder === true
            floatingBarCheck.checked = root.settings.bar.floating === true
            showQuickLaunchCheck.checked = root.settings.bar.showQuickLaunch !== false
            showSystemTrayCheck.checked = root.settings.bar.showSystemTray !== false
            workspaceCountObj.value = root.settings.bar.minWorkspaces !== undefined ? root.settings.bar.minWorkspaces : 4
            barSizeLargeCheck.checked = root.settings.bar.barSize === "large"
            barLayoutPreset.value = root.settings.bar.layoutPreset || "default"
            barContainerStyle.value = root.settings.bar.barStyle || "single"
        }
        
        // Widget borders
        root.showWidgetBorders = root.settings.general ? root.settings.general.showWidgetBorders !== false : true
        root.widgetBorderWidth = (root.settings.general && root.settings.general.widgetBorderWidth !== undefined)
            ? root.settings.general.widgetBorderWidth : 1

        // Widget transparency
        const transparent = root.settings.general ? root.settings.general.widgetTransparent !== false : true
        widgetTransparentCheck.checked = transparent
        ThemeManager.widgetOpacity = transparent ? 0.75 : 1.0

        // UI Font
        const savedFont = (root.settings.general && root.settings.general.uiFont) ? root.settings.general.uiFont : "Sen"
        root.currentFontSelection = savedFont
        ThemeManager.uiFont = savedFont

        // Hyprland appearance settings — restore from settings.json
        if (root.settings.hypr) {
            const h = root.settings.hypr
            if (h.borderSize !== undefined) {
                hyprBorderEnabledCheck.checked = h.borderSize > 0
                hyprBorderThicknessObj.value = h.borderSize > 0 ? h.borderSize : 1
            }
            if (h.rounding   !== undefined) hyprRoundingObj.value    = h.rounding
            if (h.gapsIn     !== undefined) hyprGapsInObj.value       = h.gapsIn
            if (h.gapsOut    !== undefined) hyprGapsOutObj.value      = h.gapsOut
            if (h.animations !== undefined) hyprAnimationsCheck.checked = h.animations
            if (h.shadow     !== undefined) hyprShadowCheck.checked   = h.shadow
            if (h.blur       !== undefined) hyprBlurCheck.checked     = h.blur
            if (h.blurSize   !== undefined) hyprBlurSizeObj.value     = h.blurSize
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

    ListModel {
        id: fontModel
    }

    property string currentFontSelection: ThemeManager.uiFont

    Process {
        id: fontLoader
        running: false
        command: ["sh", "-c", "fc-list : family | tr ',' '\\n' | sed 's/^ *//' | grep -ivE '^symbols |emoji|noto color emoji|^font awesome|weather icon' | sort -uf"]

        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (name.length > 0) {
                    fontModel.append({name: name})
                }
            }
        }
    }

    function loadFonts() {
        fontModel.clear()
        fontLoader.running = true
    }

    // Load Hyprland settings from look-and-feel.conf
    function loadHyprlandSettings() {
        hyprlandLoader.running = true
    }

    Process {
        id: hyprlandLoader
        running: false
        command: ["sh", "-c", `
            CONFIG="$HOME/.config/hypr/look-and-feel.conf"
            border=$(grep 'border_size = ' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            gaps_in=$(grep 'gaps_in = ' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            gaps_out=$(grep 'gaps_out = ' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            rounding=$(grep 'rounding = ' "$CONFIG" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            shadow=$(grep -A 10 'shadow {' "$CONFIG" 2>/dev/null | grep 'enabled' | grep -c 'true' || echo 0)
            blur=$(grep -A 10 'blur {' "$CONFIG" 2>/dev/null | grep 'enabled' | grep -c 'true' || echo 0)
            blur_size=$(grep -A 10 'blur {' "$CONFIG" 2>/dev/null | grep 'size = ' | grep -oE '[0-9]+' | head -1)
            [ -z "$blur_size" ] && blur_size=10
            anim=$(grep -A 5 'animations {' "$CONFIG" 2>/dev/null | grep 'enabled' | grep -c 'yes' || echo 0)
            echo "$border $gaps_in $gaps_out $rounding $shadow $blur $anim $blur_size"
        `]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { hyprlandLoader.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const parts = buffer.trim().split(" ")
                if (parts.length >= 7) {
                    const bs = parseInt(parts[0]) || 1
                    root.hyprBorderSize = bs
                    root.hyprGapsIn = parseInt(parts[1]) || 5
                    root.hyprGapsOut = parseInt(parts[2]) || 10
                    root.hyprRounding = parseInt(parts[3]) || 12
                    root.hyprShadow = parts[4] === "1"
                    root.hyprBlur = parts[5] === "1"
                    root.hyprAnimations = parts[6] === "1"
                    root.hyprBlurSize = parseInt(parts[7]) || 10

                    hyprBorderEnabledCheck.checked = bs > 0
                    hyprBorderThicknessObj.value = bs > 0 ? bs : 1
                    hyprGapsInObj.value = root.hyprGapsIn
                    hyprGapsOutObj.value = root.hyprGapsOut
                    hyprRoundingObj.value = root.hyprRounding
                    hyprAnimationsCheck.checked = root.hyprAnimations
                    hyprShadowCheck.checked = root.hyprShadow
                    hyprBlurCheck.checked = root.hyprBlur
                    hyprBlurSizeObj.value = root.hyprBlurSize
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Apply a Hyprland keyword live and persist to conf
    function buildLuaConfig(hyprKey, value) {
        var parts = hyprKey.split(":")
        var v = value
        var luaVal
        if (v === true || v === "true") luaVal = "true"
        else if (v === false || v === "false") luaVal = "false"
        else if (String(v).trim() !== "" && !isNaN(Number(v))) luaVal = String(v)
        else luaVal = '"' + String(v).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"'
        var lua = luaVal
        for (var i = parts.length - 1; i >= 0; i--) {
            lua = "{" + parts[i] + "=" + lua + "}"
        }
        return "hl.config(" + lua + ")"
    }

    function applyHypr(hyprKey, value, sedExpr) {
        Quickshell.execDetached(["hyprctl", "eval", buildLuaConfig(hyprKey, value)])
        // Persist to settings.json so changes survive theme changes and reboots
        if (!root.settings.hypr) root.settings.hypr = {}
        var keyMap = {
            "general:border_size":   "borderSize",
            "decoration:rounding":   "rounding",
            "general:gaps_in":       "gapsIn",
            "general:gaps_out":      "gapsOut",
            "decoration:blur:size":  "blurSize"
        }
        var field = keyMap[hyprKey]
        if (field !== undefined) {
            root.settings.hypr[field] = value
            saveSettings()
        }
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
                font.family: ThemeManager.uiFont
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
            }
            
            // Close button (hidden when embedded as a tab inside another widget)
            Rectangle {
                width: 32
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 6
                visible: !root.embedded
                color: closeMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.30) : "transparent"
                border.width: closeMouseArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: ThemeManager.fgSecondary
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
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Repeater {
                    model: ["Widgets", "Screenshots", "Bar", "Hyprland", "Theme"]

                    Rectangle {
                        width: (parent.width - 30) / 5
                        height: parent.height
                        radius: 8
                        color: tabBar.currentIndex === index ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30) : "transparent"
                        border.width: tabBar.currentIndex === index ? 1 : 0
                        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
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
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

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

                        // ========== WIDGET APPEARANCE ==========
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
                                text: "🪟 Widget Appearance"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            // Transparent background toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: widgetTransparentCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: widgetTransparentCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            widgetTransparentCheck.checked = !widgetTransparentCheck.checked
                                            ThemeManager.widgetOpacity = widgetTransparentCheck.checked ? 0.75 : 1.0
                                            if (!root.settings.general) root.settings.general = {}
                                            root.settings.general.widgetTransparent = widgetTransparentCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Text {
                                        text: "Transparent widget backgrounds"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: widgetTransparentCheck.checked ? "Widgets use semi-transparent backgrounds" : "Widgets use solid opaque backgrounds"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                QtObject {
                                    id: widgetTransparentCheck
                                    property bool checked: true
                                }
                            }

                            // Font picker
                            Column {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: "UI Font"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: "Current: " + root.currentFontSelection
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                // Search field
                                Rectangle {
                                    width: parent.width
                                    height: 30
                                    radius: 6
                                    color: Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.12)

                                    TextInput {
                                        id: fontSearchField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        color: ThemeManager.fgPrimary
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        clip: true

                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 0
                                            text: "Search fonts..."
                                            color: ThemeManager.fgTertiary
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            visible: fontSearchField.text.length === 0
                                        }
                                    }
                                }

                                // Font list
                                Rectangle {
                                    width: parent.width
                                    height: 160
                                    radius: 6
                                    color: Qt.rgba(0, 0, 0, 0.2)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.10)
                                    clip: true

                                    ListView {
                                        id: fontListView
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        clip: true
                                        model: fontModel
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar {}

                                        // Filter via wrapper
                                        property string filterText: fontSearchField.text.toLowerCase()

                                        delegate: Item {
                                            width: fontListView.width
                                            height: visible ? 28 : 0
                                            visible: model.name.toLowerCase().indexOf(fontListView.filterText) !== -1

                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                radius: 4
                                                color: model.name === root.currentFontSelection
                                                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                                                    : (fontDelegateArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent")

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 8
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: 8
                                                    text: model.name
                                                    font.family: model.name
                                                    font.pixelSize: 12
                                                    color: model.name === root.currentFontSelection
                                                        ? ThemeManager.accentBlue
                                                        : ThemeManager.fgPrimary
                                                    elide: Text.ElideRight
                                                }

                                                MouseArea {
                                                    id: fontDelegateArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        root.currentFontSelection = model.name
                                                        ThemeManager.uiFont = model.name
                                                        if (!root.settings.general) root.settings.general = {}
                                                        root.settings.general.uiFont = model.name
                                                        saveSettings()
                                                        Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/sync-font.sh", model.name])
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

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
                                font.family: ThemeManager.uiFont
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
                                    color: clockFormat24hr.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                    color: showSeconds.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }
                                
                                QtObject {
                                    id: showSeconds
                                    property bool checked: false
                                }
                            }

                            // Date format (MM/DD/YYYY vs DD/MM/YYYY)
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: dateFormatDMY.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: dateFormatDMY.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            dateFormatDMY.checked = !dateFormatDMY.checked
                                            root.settings.general.dateFormat = dateFormatDMY.checked ? "DMY" : "MDY"
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Text {
                                        text: "Use DD/MM/YYYY date format"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: dateFormatDMY.checked ? "Currently: DD/MM/YYYY" : "Currently: MM/DD/YYYY"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                QtObject {
                                    id: dateFormatDMY
                                    property bool checked: false
                                }
                            }

                            // Long date format
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: dateLong.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: dateLong.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            dateLong.checked = !dateLong.checked
                                            root.settings.general.dateLong = dateLong.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Text {
                                        text: "Use long date format"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: dateFormatDMY.checked ? "e.g., 25 March 2026" : "e.g., March 25, 2026"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                QtObject {
                                    id: dateLong
                                    property bool checked: false
                                }
                            }

                            // Show day of week (only visible when long date format is enabled)
                            Row {
                                spacing: 12
                                visible: dateLong.checked

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showDayOfWeek.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: showDayOfWeek.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showDayOfWeek.checked = !showDayOfWeek.checked
                                            root.settings.general.showDayOfWeek = showDayOfWeek.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Text {
                                        text: "Show day of week"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: dateFormatDMY.checked ? "e.g., Wednesday, 25 March 2026" : "e.g., Wednesday, March 25, 2026"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                QtObject {
                                    id: showDayOfWeek
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
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                width: parent.width
                                text: "Configure your calendar integration (supports multiple files):"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                            }
                            
                            Column {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    text: "Calendar File(s)"
                                    font.family: ThemeManager.uiFont
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
                                            font.family: ThemeManager.uiFont
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
                                        color: filePickerMouseArea.containsMouse ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Browse..."
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.accentBlue
                                            
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
                                font.family: ThemeManager.uiFont
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
                                    font.family: ThemeManager.uiFont
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
                                            font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                }
                                
                                Text {
                                    width: parent.width
                                    text: "How often to refresh calendar data from URLs. Set to 0 to disable auto-refresh."
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                    wrapMode: Text.WordWrap
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
                                font.family: ThemeManager.uiFont
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
                                    color: useFahrenheit.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 200
                                        height: 32
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        radius: 6
                                        border.width: 1
                                        border.color: latitudeField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                        
                                        TextInput {
                                            id: latitudeField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 200
                                        height: 32
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        radius: 6
                                        border.width: 1
                                        border.color: longitudeField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                        
                                        TextInput {
                                            id: longitudeField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 150
                                        height: 32
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        radius: 6
                                        border.width: 1
                                        border.color: cityField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                        
                                        TextInput {
                                            id: cityField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 100
                                        height: 32
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        radius: 6
                                        border.width: 1
                                        border.color: stateField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                        
                                        TextInput {
                                            id: stateField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: ThemeManager.uiFont
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Rectangle {
                                        width: 100
                                        height: 32
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        radius: 6
                                        border.width: 1
                                        border.color: countryField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                        
                                        TextInput {
                                            id: countryField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            
                            Rectangle {
                                width: 420
                                height: 32
                                color: Qt.rgba(1, 1, 1, 0.07)
                                radius: 6
                                border.width: 1
                                border.color: apiKeyField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                
                                TextInput {
                                    id: apiKeyField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
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
                                        color: decreaseMouseArea.containsMouse ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.07)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "−"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: ThemeManager.fgPrimary
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
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.07)
                                        
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
                                            font.family: ThemeManager.uiFont
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
                                        color: increaseMouseArea.containsMouse ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.07)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
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
                                    color: saveToDiskCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                    color: copyToClipboardCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: ThemeManager.accentBlue
                            }
                            
                            Row {
                                spacing: 8
                                
                                Rectangle {
                                    width: 350
                                    height: 32
                                    color: Qt.rgba(1, 1, 1, 0.07)
                                    radius: 6
                                    border.width: 1
                                    border.color: saveLocationField.activeFocus ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.18)
                                    
                                    TextInput {
                                        id: saveLocationField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: ThemeManager.uiFont
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
                                    color: browseMouseArea.containsMouse ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.07)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰉋"  // folder open icon (nf-md-folder_open)
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 18
                                        color: ThemeManager.accentBlue
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
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            Text {
                                text: "Configure bar background and system tray details"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Column {
                                spacing: 12

                                Text {
                                    text: "Bar Style"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: barContainerStyle.value === "islands"
                                        ? "Render each bar area as a separate island."
                                        : "Render a single continuous bar background."
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgSecondary
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 130
                                        height: 34
                                        radius: 8
                                        color: barContainerStyle.value === "single"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: barContainerStyle.value === "single"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.12)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Single Bar"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!root.settings.bar) root.settings.bar = {}
                                                barContainerStyle.value = "single"
                                                root.settings.bar.barStyle = "single"
                                                saveSettings()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 120
                                        height: 34
                                        radius: 8
                                        color: barContainerStyle.value === "islands"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: barContainerStyle.value === "islands"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.12)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Islands"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!root.settings.bar) root.settings.bar = {}
                                                barContainerStyle.value = "islands"
                                                root.settings.bar.barStyle = "islands"
                                                saveSettings()
                                            }
                                        }
                                    }
                                }

                                QtObject {
                                    id: barContainerStyle
                                    property string value: "single"
                                }
                            }

                            Column {
                                spacing: 12

                                Text {
                                    text: "Bar Item Layout"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: barLayoutPreset.value === "center-menu"
                                        ? "Left: workspaces and quick launch. Center: app menu. Right: clipboard, updates, system tray, and date/time."
                                        : "Default layout keeps the app menu on the left, the clock in the center, and the utility tray on the right."
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 170
                                        height: 34
                                        radius: 8
                                        color: barLayoutPreset.value === "default"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: barLayoutPreset.value === "default"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.12)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Default Layout"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!root.settings.bar) root.settings.bar = {}
                                                barLayoutPreset.value = "default"
                                                root.settings.bar.layoutPreset = "default"
                                                saveSettings()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 190
                                        height: 34
                                        radius: 8
                                        color: barLayoutPreset.value === "center-menu"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: barLayoutPreset.value === "center-menu"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.12)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Centered App Menu"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!root.settings.bar) root.settings.bar = {}
                                                barLayoutPreset.value = "center-menu"
                                                root.settings.bar.layoutPreset = "center-menu"
                                                saveSettings()
                                            }
                                        }
                                    }
                                }

                                QtObject {
                                    id: barLayoutPreset
                                    property string value: "default"
                                }
                            }
                            
                            // Bar Background Style
                            Column {
                                spacing: 16
                                
                                Text {
                                    text: "Bar Background Style"
                                    font.family: ThemeManager.uiFont
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
                                        color: barSolidCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
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
                                        font.family: ThemeManager.uiFont
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
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            color: ThemeManager.fgPrimary
                                            width: 180
                                        }
                                        
                                        Text {
                                            text: "(Opacity: " + Math.round(barOpacitySlider.value * 100) + "%)"
                                            font.family: ThemeManager.uiFont
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
                                            color: Qt.rgba(1, 1, 1, 0.07)
                                            
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
                                        font.family: ThemeManager.uiFont
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
                            
                            // Bar Border Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showBorderCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: showBorderCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showBorderCheck.checked = !showBorderCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.showBorder = showBorderCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Show border around bar"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                QtObject {
                                    id: showBorderCheck
                                    property bool checked: false
                                }
                            }

                            // Floating Bar Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: floatingBarCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: floatingBarCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            floatingBarCheck.checked = !floatingBarCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.floating = floatingBarCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Floating bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Adds padding around the bar with rounded corners"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                QtObject {
                                    id: floatingBarCheck
                                    property bool checked: false
                                }
                            }

                            // Bar Size Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: barSizeLargeCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: barSizeLargeCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            barSizeLargeCheck.checked = !barSizeLargeCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.barSize = barSizeLargeCheck.checked ? "large" : "small"
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Use chonky bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Increases bar height by 25% (53px vs 42px)"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                QtObject {
                                    id: barSizeLargeCheck
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
                                    color: barPositionBottomCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                    color: barAutoHideCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }
                                    
                                    Text {
                                        text: "Bar slides out when mouse approaches edge"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }
                                
                                QtObject {
                                    id: barAutoHideCheck
                                    property bool checked: false
                                }
                            }

                            // Show Quick Launch Drawer Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showQuickLaunchCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: showQuickLaunchCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showQuickLaunchCheck.checked = !showQuickLaunchCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.showQuickLaunch = showQuickLaunchCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Show quick launch drawer"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Chevron button and quick launch icons on the left"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                QtObject {
                                    id: showQuickLaunchCheck
                                    property bool checked: true
                                }
                            }

                            // Show System Tray Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showSystemTrayCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: showSystemTrayCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showSystemTrayCheck.checked = !showSystemTrayCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.showSystemTray = showSystemTrayCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Show system tray icons"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Clipboard, updates, and status icons on the right"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                QtObject {
                                    id: showSystemTrayCheck
                                    property bool checked: true
                                }
                            }

                            // Minimum Workspaces
                            Row {
                                spacing: 16

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Minimum workspaces shown"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Number of workspace indicators always visible in the bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        radius: 6
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.15)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "−"
                                            font.pixelSize: 16
                                            color: workspaceCountObj.value > 1 ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (workspaceCountObj.value > 1) {
                                                    workspaceCountObj.value -= 1
                                                    if (!root.settings.bar) root.settings.bar = {}
                                                    root.settings.bar.minWorkspaces = workspaceCountObj.value
                                                    saveSettings()
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 28
                                        radius: 6
                                        color: Qt.rgba(1, 1, 1, 0.10)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.20)

                                        Text {
                                            anchors.centerIn: parent
                                            text: workspaceCountObj.value.toString()
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: ThemeManager.fgPrimary
                                        }
                                    }

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        radius: 6
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.15)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.pixelSize: 14
                                            color: workspaceCountObj.value < 10 ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (workspaceCountObj.value < 10) {
                                                    workspaceCountObj.value += 1
                                                    if (!root.settings.bar) root.settings.bar = {}
                                                    root.settings.bar.minWorkspaces = workspaceCountObj.value
                                                    saveSettings()
                                                }
                                            }
                                        }
                                    }
                                }

                                QtObject {
                                    id: workspaceCountObj
                                    property int value: 4
                                }
                            }

                            // Show Battery Details
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: showBatteryDetailsCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                    color: showVolumeDetailsCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                                    color: showNetworkDetailsCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
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
                                    font.family: ThemeManager.uiFont
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
                
                // Hyprland Tab
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.parent.width - 32
                        spacing: 32

                        // ========== WINDOW DECORATIONS ==========
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
                                text: "🪟 Window Decorations"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            Text {
                                text: "Changes apply live via Hyprland and are saved to look-and-feel.conf."
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            // Border Enabled
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: hyprBorderEnabledCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: hyprBorderEnabledCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            hyprBorderEnabledCheck.checked = !hyprBorderEnabledCheck.checked
                                            const sz = hyprBorderEnabledCheck.checked ? hyprBorderThicknessObj.value : 0
                                            root.applyHypr("general:border_size", sz,
                                                `sed -i -E 's/border_size = [0-9]+/border_size = ${sz}/'`)
                                            // Sync widget borders setting
                                            if (!root.settings.general) root.settings.general = {}
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.general.showWidgetBorders = hyprBorderEnabledCheck.checked
                                            root.settings.bar.showBorder = hyprBorderEnabledCheck.checked
                                            root.showWidgetBorders = hyprBorderEnabledCheck.checked
                                            saveSettings()
                                            // Sync mako border thickness (0 when borders disabled)
                                            Quickshell.execDetached(["sh", "-c",
                                                `sed -i 's/^border-size=.*/border-size=${sz}/' "$HOME/.config/mako/config" && makoctl reload 2>/dev/null`])
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enable window borders"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                QtObject {
                                    id: hyprBorderEnabledCheck
                                    property bool checked: true
                                }
                            }

                            // Border Thickness
                            Column {
                                spacing: 8
                                width: parent.width - 40
                                leftPadding: 20
                                opacity: hyprBorderEnabledCheck.checked ? 1.0 : 0.5

                                Text {
                                    text: "Border thickness: " + hyprBorderThicknessObj.value + "px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                Item {
                                    width: parent.width - 40
                                    height: 32

                                    Rectangle {
                                        id: borderThickTrack
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: Qt.rgba(1, 1, 1, 0.07)

                                        Rectangle {
                                            width: borderThickHandle.x + borderThickHandle.width / 2
                                            height: parent.height
                                            radius: parent.radius
                                            color: ThemeManager.accentBlue
                                        }
                                    }

                                    Rectangle {
                                        id: borderThickHandle
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: borderThickMA.containsMouse || borderThickMA.pressed ? ThemeManager.accentBlue : ThemeManager.fgPrimary
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        y: (parent.height - height) / 2
                                        x: (borderThickTrack.width - width) * ((hyprBorderThicknessObj.value - 1) / 4.0)
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: borderThickMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: hyprBorderEnabledCheck.checked

                                        function updateVal(mouse) {
                                            const norm = Math.max(0, Math.min(1, mouse.x / width))
                                            const val = Math.max(1, Math.round(1 + norm * 4))
                                            hyprBorderThicknessObj.value = val
                                            root.applyHypr("general:border_size", val,
                                                `sed -i -E 's/border_size = [0-9]+/border_size = ${val}/'`)
                                            if (!root.settings.general) root.settings.general = {}
                                            root.settings.general.widgetBorderWidth = val
                                            root.widgetBorderWidth = val
                                            saveSettings()
                                            // Sync mako border thickness
                                            Quickshell.execDetached(["sh", "-c",
                                                `sed -i 's/^border-size=.*/border-size=${val}/' "$HOME/.config/mako/config" && makoctl reload 2>/dev/null`])
                                        }

                                        onPressed: updateVal(mouse)
                                        onPositionChanged: if (pressed) updateVal(mouse)
                                    }
                                }

                                Text {
                                    text: "Range: 1–5px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                QtObject {
                                    id: hyprBorderThicknessObj
                                    property int value: 1
                                }
                            }

                            // Window Rounding
                            Column {
                                spacing: 8
                                width: parent.width - 20

                                Text {
                                    text: "Window rounding: " + hyprRoundingObj.value + "px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                Item {
                                    width: parent.width - 40
                                    height: 32

                                    Rectangle {
                                        id: roundingTrack
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: Qt.rgba(1, 1, 1, 0.07)

                                        Rectangle {
                                            width: roundingHandle.x + roundingHandle.width / 2
                                            height: parent.height
                                            radius: parent.radius
                                            color: ThemeManager.accentBlue
                                        }
                                    }

                                    Rectangle {
                                        id: roundingHandle
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: roundingMA.containsMouse || roundingMA.pressed ? ThemeManager.accentBlue : ThemeManager.fgPrimary
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        y: (parent.height - height) / 2
                                        x: (roundingTrack.width - width) * (hyprRoundingObj.value / 20.0)
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: roundingMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        function updateVal(mouse) {
                                            const norm = Math.max(0, Math.min(1, mouse.x / width))
                                            const val = Math.round(norm * 20)
                                            hyprRoundingObj.value = val
                                            root.applyHypr("decoration:rounding", val,
                                                `sed -i -E 's/rounding = [0-9]+/rounding = ${val}/'`)
                                        }

                                        onPressed: updateVal(mouse)
                                        onPositionChanged: if (pressed) updateVal(mouse)
                                    }
                                }

                                Text {
                                    text: "Range: 0–20px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                QtObject {
                                    id: hyprRoundingObj
                                    property int value: 12
                                }
                            }
                        }

                        // ========== WINDOW GAPS ==========
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
                                text: "↔ Window Gaps"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            // Gaps In
                            Column {
                                spacing: 8
                                width: parent.width - 20

                                Text {
                                    text: "Inner gaps (between windows): " + hyprGapsInObj.value + "px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                Item {
                                    width: parent.width - 40
                                    height: 32

                                    Rectangle {
                                        id: gapsInTrack
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: Qt.rgba(1, 1, 1, 0.07)

                                        Rectangle {
                                            width: gapsInHandle.x + gapsInHandle.width / 2
                                            height: parent.height
                                            radius: parent.radius
                                            color: ThemeManager.accentBlue
                                        }
                                    }

                                    Rectangle {
                                        id: gapsInHandle
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: gapsInMA.containsMouse || gapsInMA.pressed ? ThemeManager.accentBlue : ThemeManager.fgPrimary
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        y: (parent.height - height) / 2
                                        x: (gapsInTrack.width - width) * (hyprGapsInObj.value / 20.0)
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: gapsInMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        function updateVal(mouse) {
                                            const norm = Math.max(0, Math.min(1, mouse.x / width))
                                            const val = Math.round(norm * 20)
                                            hyprGapsInObj.value = val
                                            root.applyHypr("general:gaps_in", val,
                                                `sed -i -E 's/gaps_in = [0-9]+/gaps_in = ${val}/'`)
                                        }

                                        onPressed: updateVal(mouse)
                                        onPositionChanged: if (pressed) updateVal(mouse)
                                    }
                                }

                                Text {
                                    text: "Range: 0–20px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                QtObject {
                                    id: hyprGapsInObj
                                    property int value: 5
                                }
                            }

                            // Gaps Out
                            Column {
                                spacing: 8
                                width: parent.width - 20

                                Text {
                                    text: "Outer gaps (screen edge): " + hyprGapsOutObj.value + "px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                Item {
                                    width: parent.width - 40
                                    height: 32

                                    Rectangle {
                                        id: gapsOutTrack
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: Qt.rgba(1, 1, 1, 0.07)

                                        Rectangle {
                                            width: gapsOutHandle.x + gapsOutHandle.width / 2
                                            height: parent.height
                                            radius: parent.radius
                                            color: ThemeManager.accentBlue
                                        }
                                    }

                                    Rectangle {
                                        id: gapsOutHandle
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: gapsOutMA.containsMouse || gapsOutMA.pressed ? ThemeManager.accentBlue : ThemeManager.fgPrimary
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        y: (parent.height - height) / 2
                                        x: (gapsOutTrack.width - width) * (hyprGapsOutObj.value / 40.0)
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: gapsOutMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        function updateVal(mouse) {
                                            const norm = Math.max(0, Math.min(1, mouse.x / width))
                                            const val = Math.round(norm * 40)
                                            hyprGapsOutObj.value = val
                                            root.applyHypr("general:gaps_out", val,
                                                `sed -i -E 's/gaps_out = [0-9]+/gaps_out = ${val}/'`)
                                        }

                                        onPressed: updateVal(mouse)
                                        onPositionChanged: if (pressed) updateVal(mouse)
                                    }
                                }

                                Text {
                                    text: "Range: 0–40px"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                QtObject {
                                    id: hyprGapsOutObj
                                    property int value: 10
                                }
                            }
                        }

                        // ========== EFFECTS ==========
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
                                text: "✨ Effects"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            // Animations
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: hyprAnimationsCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: hyprAnimationsCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            hyprAnimationsCheck.checked = !hyprAnimationsCheck.checked
                                            const en = hyprAnimationsCheck.checked
                                            Quickshell.execDetached(["hyprctl", "eval", "hl.config({animations={enabled=" + (en ? "true" : "false") + "}})"])
                                            if (!root.settings.hypr) root.settings.hypr = {}
                                            root.settings.hypr.animations = en
                                            saveSettings()
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enable window animations"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                QtObject {
                                    id: hyprAnimationsCheck
                                    property bool checked: true
                                }
                            }

                            // Shadows
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: hyprShadowCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: hyprShadowCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            hyprShadowCheck.checked = !hyprShadowCheck.checked
                                            const en = hyprShadowCheck.checked
                                            Quickshell.execDetached(["hyprctl", "eval", "hl.config({decoration={shadow={enabled=" + (en ? "true" : "false") + "}}})"])
                                            if (!root.settings.hypr) root.settings.hypr = {}
                                            root.settings.hypr.shadow = en
                                            saveSettings()
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enable window shadows"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                QtObject {
                                    id: hyprShadowCheck
                                    property bool checked: true
                                }
                            }

                            // Blur
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 4
                                    color: hyprBlurCheck.checked ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 2
                                    border.color: ThemeManager.accentBlue

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: ThemeManager.fgPrimary
                                        visible: hyprBlurCheck.checked
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            hyprBlurCheck.checked = !hyprBlurCheck.checked
                                            const en = hyprBlurCheck.checked
                                            const bval = en ? "true" : "false"
                                            Quickshell.execDetached(["hyprctl", "eval", "hl.config({decoration={blur={enabled=" + bval + "}}})"])
                                            Quickshell.execDetached(["hyprctl", "eval", "hl.layer_rule({match={namespace='^quickshell'}, blur=" + bval + "})"])
                                            Quickshell.execDetached(["hyprctl", "eval", "hl.layer_rule({match={namespace='^mako'}, blur=" + bval + "})"])
                                            if (!root.settings.hypr) root.settings.hypr = {}
                                            root.settings.hypr.blur = en
                                            saveSettings()
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enable background blur"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                QtObject {
                                    id: hyprBlurCheck
                                    property bool checked: true
                                }
                            }

                            // Blur Size
                            Column {
                                spacing: 8
                                width: parent.width - 40
                                leftPadding: 20
                                opacity: hyprBlurCheck.checked ? 1.0 : 0.5

                                Text {
                                    text: "Blur intensity: " + hyprBlurSizeObj.value
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                Item {
                                    width: parent.width - 40
                                    height: 32

                                    Rectangle {
                                        id: blurSizeTrack
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: Qt.rgba(1, 1, 1, 0.07)

                                        Rectangle {
                                            width: blurSizeHandle.x + blurSizeHandle.width / 2
                                            height: parent.height
                                            radius: parent.radius
                                            color: ThemeManager.accentBlue
                                        }
                                    }

                                    Rectangle {
                                        id: blurSizeHandle
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: blurSizeMA.containsMouse || blurSizeMA.pressed ? ThemeManager.accentBlue : ThemeManager.fgPrimary
                                        border.width: 2
                                        border.color: ThemeManager.accentBlue
                                        y: (parent.height - height) / 2
                                        x: (blurSizeTrack.width - width) * ((hyprBlurSizeObj.value - 1) / 19.0)
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: blurSizeMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: hyprBlurCheck.checked

                                        function updateVal(mouse) {
                                            const norm = Math.max(0, Math.min(1, mouse.x / width))
                                            const val = Math.max(1, Math.round(1 + norm * 19))
                                            hyprBlurSizeObj.value = val
                                            root.applyHypr("decoration:blur:size", val,
                                                `sed -i -E '/blur \\{/,/\\}/ s/size = [0-9]+/size = ${val}/'`)
                                        }

                                        onPressed: updateVal(mouse)
                                        onPositionChanged: if (pressed) updateVal(mouse)
                                    }
                                }

                                Text {
                                    text: "Range: 1–20  (higher = more blur)"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 10
                                    color: ThemeManager.fgTertiary
                                }

                                QtObject {
                                    id: hyprBlurSizeObj
                                    property int value: 10
                                }
                            }

                            Item { height: 16; width: 1 }
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
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                font.italic: true
                                color: ThemeManager.fgSecondary
                            }
                        }
                        
                        Repeater {
                            model: themeModel
                            
                            Rectangle {
                                id: themeCard
                                width: parent.width
                                height: 72
                                radius: 10
                                clip: true

                                property bool isActive: model.name === root.currentTheme

                                border.width: isActive ? 2 : (themeMouseArea.containsMouse ? 1 : 0)
                                border.color: isActive ? "#a6e3a1" : Qt.rgba(1, 1, 1, 0.22)

                                Behavior on border.width {
                                    NumberAnimation { duration: 150 }
                                }

                                property var themeData: ({
                                    "Catppuccin": { bg: "#1e1e2e", fg: "#cdd6f4", accents: ["#89b4fa", "#cba6f7", "#f5c2e7", "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5"] },
                                    "Dracula":    { bg: "#282a36", fg: "#f8f8f2", accents: ["#bd93f9", "#ff79c6", "#ff6e6e", "#ffb86c", "#f1fa8c", "#50fa7b", "#8be9fd", "#6272a4"] },
                                    "Eldritch":   { bg: "#212337", fg: "#ebfafa", accents: ["#f16c75", "#f265b5", "#7081d0", "#a48cf2", "#37f499", "#04d1f9", "#ffd700", "#323449"] },
                                    "Everforest": { bg: "#374247", fg: "#d3c6aa", accents: ["#e67e80", "#e69875", "#dbbc7f", "#a7c080", "#83c092", "#7fbbb3", "#d699b6", "#9da9a0"] },
                                    "Gruvbox":    { bg: "#282828", fg: "#ebdbb2", accents: ["#fb4934", "#fe8019", "#fabd2f", "#b8bb26", "#8ec07c", "#83a598", "#d3869b", "#689d6a"] },
                                    "Kanagawa":   { bg: "#1f1f28", fg: "#dcd7ba", accents: ["#7fb4ca", "#957fb8", "#d27e99", "#e46876", "#dca561", "#98bb6c", "#7aa89f", "#938aa9"] },
                                    "Material":   { bg: "#263238", fg: "#eeffff", accents: ["#82aaff", "#c792ea", "#f07178", "#f78c6c", "#ffcb6b", "#c3e88d", "#89ddff", "#546e7a"] },
                                    "Monochrome": { bg: "#252525", fg: "#bebebe", accents: ["#bebebe", "#a8a8a8", "#999999", "#888888", "#777777", "#666666", "#555555", "#444444"] },
                                    "NightFox":   { bg: "#131a24", fg: "#cdcecf", accents: ["#719cd6", "#9d79d6", "#d67ad2", "#f52a65", "#f4a261", "#dbc074", "#63cdcf", "#4d688e"] },
                                    "Nord":       { bg: "#2e3440", fg: "#eceff4", accents: ["#88c0d0", "#81a1c1", "#5e81ac", "#bf616a", "#d08770", "#ebcb8b", "#a3be8c", "#b48ead"] },
                                    "Rosepine":   { bg: "#191724", fg: "#e0def4", accents: ["#c4a7e7", "#ebbcba", "#eb6f92", "#f6c177", "#ea9a97", "#9ccfd8", "#31748f", "#907aa9"] },
                                    "Solarized":  { bg: "#002b36", fg: "#839496", accents: ["#268bd2", "#6c71c4", "#d33682", "#dc322f", "#cb4b16", "#b58900", "#859900", "#2aa198"] },
                                    "TokyoNight": { bg: "#1a1b26", fg: "#c0caf5", accents: ["#7aa2f7", "#bb9af7", "#f7768e", "#ff9e64", "#e0af68", "#9ece6a", "#73daca", "#7dcfff"] }
                                })

                                property var data: themeData[model.name] || { bg: "#1e1e2e", fg: "#cdd6f4", accents: ["#89b4fa", "#cba6f7", "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5", "#74c7ec"] }

                                // Top band — theme bg color with name and current badge
                                Rectangle {
                                    id: topBand
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: accentRow.top
                                    color: themeCard.data.bg

                                    // Subtle hover brightening
                                    Rectangle {
                                        anchors.fill: parent
                                        color: themeMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    Text {
                                        id: cardThemeName
                                        anchors.left: parent.left
                                        anchors.leftMargin: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.name
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 15
                                        font.weight: Font.Medium
                                        color: themeCard.data.fg
                                    }

                                    Rectangle {
                                        visible: themeCard.isActive
                                        anchors.left: cardThemeName.right
                                        anchors.leftMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: currentBadge.implicitWidth + 12
                                        height: 18
                                        radius: 4
                                        color: Qt.rgba(0.651, 0.890, 0.631, 0.18)

                                        Text {
                                            id: currentBadge
                                            anchors.centerIn: parent
                                            text: "● Current"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 9
                                            color: "#a6e3a1"
                                        }
                                    }
                                }

                                // Accent color band strip at bottom
                                Row {
                                    id: accentRow
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 14

                                    Repeater {
                                        model: themeCard.data.accents
                                        Rectangle {
                                            width: accentRow.width / themeCard.data.accents.length
                                            height: 14
                                            color: modelData
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
                clip: true
                color: applyButtonMouseArea.containsMouse && !applyButtonSuccess ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.25) : "transparent"
                border.width: 1
                border.color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.55)
                visible: tabBar.currentIndex === 0 || tabBar.currentIndex === 1  // Show on Widgets and Screenshots tabs
                z: 100  // Ensure it's on top

                // Progress fill — animates left-to-right while applying
                Rectangle {
                    id: applyProgressFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 0
                    color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.3)

                    states: State {
                        name: "filling"
                        when: applyButtonSuccess
                        PropertyChanges { target: applyProgressFill; width: 120 }
                    }

                    transitions: [
                        Transition {
                            from: ""
                            to: "filling"
                            NumberAnimation { property: "width"; duration: 1500; easing.type: Easing.Linear }
                        },
                        Transition {
                            from: "filling"
                            to: ""
                            NumberAnimation { property: "width"; duration: 0 }
                        }
                    ]
                }
                
                Text {
                    anchors.centerIn: parent
                    text: applyButtonSuccess ? "Applying..." : "Apply"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: ThemeManager.accentGreen
                    z: 1
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

    // Top specular highlight
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.07) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
        }
        z: 10
    }

    // Bottom fade
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.12) }
        }
        z: 10
    }
}
