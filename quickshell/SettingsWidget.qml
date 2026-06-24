import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 1100
    height: 720
    // When embedded as a tab inside another widget, suppress the background
    property bool embedded: false
    color: embedded ? "transparent" : ThemeManager.bgBase
    radius: embedded ? 0 : root.hyprRounding
    border.width: embedded ? 0 : (ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0)
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true
    clip: true
    
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
            if (themeModel.count === 0) loadThemes()
            if (root.fontList.length === 0) loadFonts()
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
            showWeatherInBarCheck.checked = root.settings.bar.showWeatherInBar === true
            floatingBarCheck.checked = root.settings.bar.floating === true
            showQuickLaunchCheck.checked = root.settings.bar.showQuickLaunch !== false
            showSystemTrayCheck.checked = root.settings.bar.showSystemTray !== false
            workspaceCountObj.value = root.settings.bar.minWorkspaces !== undefined ? root.settings.bar.minWorkspaces : 4
            ThemeManager.workspaceStyle = root.settings.bar.workspaceStyle || "numbers"
            barSizeLargeCheck.checked = root.settings.bar.barSize === "large"
            barLayoutPreset.value = root.settings.bar.layoutPreset || "default"
            barContainerStyle.value = root.settings.bar.barStyle || "single"
        }
        
        // Widget borders
        root.showWidgetBorders = root.settings.general ? root.settings.general.showWidgetBorders !== false : true
        root.widgetBorderWidth = (root.settings.general && root.settings.general.widgetBorderWidth !== undefined)
            ? root.settings.general.widgetBorderWidth : 1
        ThemeManager.showWidgetBorders = root.showWidgetBorders
        ThemeManager.widgetBorderWidth = root.widgetBorderWidth

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

    property var fontList: []

    property string currentFontSelection: ThemeManager.uiFont

    Process {
        id: fontLoader
        running: false
        command: ["sh", "-c", "fc-list : family | tr ',' '\\n' | sed 's/^ *//' | grep -ivE '^symbols |emoji|noto color emoji|^font awesome|weather icon' | sort -uf"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { fontLoader.buffer += data + "\n" }
        }

        onRunningChanged: {
            if (running) {
                fontLoader.buffer = ""
            } else if (buffer !== "") {
                root.fontList = buffer.split("\n")
                    .map(n => n.trim())
                    .filter(n => n.length > 0)
                fontLoader.buffer = ""
            }
        }
    }

    function loadFonts() {
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
            if (field === "rounding") {
                root.hyprRounding = value
                ThemeManager.hyprRounding = value
            }
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
    


    // ─── Monitor management ──────────────────────────────────────
    ListModel { id: monitorsModel }

    Process {
        id: monitorLoader
        running: false
        command: ["hyprctl", "monitors", "-j"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { monitorLoader.buffer += data }
        }

        onRunningChanged: {
            if (running) {
                buffer = ""
            } else if (!running && buffer !== "") {
                try {
                    var mons = JSON.parse(buffer)
                    monitorsModel.clear()
                    for (var i = 0; i < mons.length; i++) {
                        var m = mons[i]
                        var modes = m.availableModes || []
                        monitorsModel.append({
                            name:        m.name || "",
                            description: m.description || "",
                            width:       m.width || 1920,
                            height:      m.height || 1080,
                            refreshRate: m.refreshRate || 60.0,
                            scale:       m.scale || 1.0,
                            x:           m.x || 0,
                            y:           m.y || 0,
                            focused:     m.focused || false,
                            modesJson:   JSON.stringify(modes),
                            currentMode: (m.width || 1920) + "x" + (m.height || 1080) + "@" + (m.refreshRate || 60.0).toFixed(2) + "Hz"
                        })
                    }
                } catch(e) {
                    console.log("Monitor parse error:", e)
                }
                monitorLoader.buffer = ""
            }
        }
    }

    Process {
        id: monitorCmdRunner
        running: false
        command: ["bash", "-c", "true"]
    }

    function applyMonitorMode(monitorName, mode) {
        var scale = 1.0
        var posStr = "auto"
        for (var i = 0; i < monitorsModel.count; i++) {
            if (monitorsModel.get(i).name === monitorName) {
                scale = monitorsModel.get(i).scale
                var mx = monitorsModel.get(i).x
                var my = monitorsModel.get(i).y
                posStr = mx + "x" + my
                break
            }
        }
        var luaCmd = 'hl.monitor({ output = "' + monitorName + '", mode = "' + mode + '", position = "' + posStr + '", scale = ' + scale.toFixed(2) + ' })'
        monitorCmdRunner.command = ["hyprctl", "eval", luaCmd]
        monitorCmdRunner.running = true
        monitorRefreshTimer.start()
    }

    function applyMonitorScale(monitorName, scale) {
        var mode = "preferred"
        var posStr = "auto"
        for (var i = 0; i < monitorsModel.count; i++) {
            if (monitorsModel.get(i).name === monitorName) {
                var m = monitorsModel.get(i)
                mode = m.width + "x" + m.height + "@" + m.refreshRate.toFixed(2) + "Hz"
                posStr = m.x + "x" + m.y
                break
            }
        }
        var luaCmd = 'hl.monitor({ output = "' + monitorName + '", mode = "' + mode + '", position = "' + posStr + '", scale = ' + scale.toFixed(2) + ' })'
        monitorCmdRunner.command = ["hyprctl", "eval", luaCmd]
        monitorCmdRunner.running = true
        monitorRefreshTimer.start()
    }

    Timer {
        id: monitorRefreshTimer
        interval: 800
        repeat: false
        onTriggered: monitorLoader.running = true
    }

    Row {
        anchors.fill: parent
        spacing: 0

        // ── Left Sidebar ──────────────────────────────────────────
        Item {
            width: 218
            height: parent.height

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 64
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (sidebar.currentIndex === 0 || sidebar.currentIndex === 1) ? 56 : 12
                radius: root.hyprRounding
                color: Qt.rgba(0, 0, 0, 0.22)

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 2

                // Tab navigation buttons
                Repeater {
                    model: 8
                    Rectangle {
                        property int stackIdx:   [0, 1, 2, 4, 5, 3, 6, 7][index]
                        property string tabIcon: ["\uf013", "\uf030", "\uf0c9", "\uf1fc", "\uf03e", "\uf359", "\uf108", "\uf05a"][index]
                        property string tabLabel: ["Quickshell", "Screenshots", "Bar", "Theme", "Wallpaper", "Hyprland", "Monitors", "About"][index]
                        property bool tabHovered: false

                        Layout.fillWidth: true
                        height: 44
                        radius: 8
                        color: sidebar.currentIndex === stackIdx
                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                            : (tabHovered ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: tabIcon
                                font.pixelSize: 17
                                color: sidebar.currentIndex === stackIdx ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: tabLabel
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 15
                                font.weight: sidebar.currentIndex === stackIdx ? Font.Medium : Font.Normal
                                color: sidebar.currentIndex === stackIdx ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: parent.tabHovered = true
                            onExited: parent.tabHovered = false
                            onClicked: sidebar.currentIndex = parent.stackIdx
                        }
                    }
                }

                Item { Layout.fillWidth: true; Layout.fillHeight: true }
            }

            QtObject {
                id: sidebar
                property int currentIndex: 0
                onCurrentIndexChanged: { if (currentIndex === 6 && monitorsModel.count === 0) monitorLoader.running = true }
            }
            }
        }

        // ── Content Area ─────────────────────────────────────────
        Item {
            width: parent.width - 218
            height: parent.height

            StackLayout {
                anchors.fill: parent
                anchors.topMargin: 56
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: (sidebar.currentIndex === 0 || sidebar.currentIndex === 1) ? 56 : 16
                currentIndex: sidebar.currentIndex

                // Tab 0: QUICKSHELL ───────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.parent.width
                        spacing: 32

                        // ========== WIDGET APPEARANCE ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard1.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard1
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16


                            Text {
                                text: "  Widget Appearance"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            // Transparent background toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: widgetTransparentCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: widgetTransparentCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    clip: true

                                    ListView {
                                        id: fontListView
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        clip: true
                                        cacheBuffer: 200
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar {}

                                        property string filterText: fontSearchField.text.toLowerCase()
                                        model: filterText.length > 0
                                            ? root.fontList.filter(n => n.toLowerCase().indexOf(filterText) !== -1)
                                            : root.fontList

                                        delegate: Item {
                                            width: fontListView.width
                                            height: 28

                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                radius: 4
                                                color: modelData === root.currentFontSelection
                                                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                                                    : (fontDelegateArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent")

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 8
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: 8
                                                    text: modelData
                                                    font.family: modelData
                                                    font.pixelSize: 12
                                                    color: modelData === root.currentFontSelection
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
                                                        root.currentFontSelection = modelData
                                                        ThemeManager.uiFont = modelData
                                                        if (!root.settings.general) root.settings.general = {}
                                                        root.settings.general.uiFont = modelData
                                                        saveSettings()
                                                        Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/sync-font.sh", modelData])
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        }

                        // ========== CLOCK SETTINGS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard2.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard2
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16
                            
                            
                            Text {
                                text: "  Clock Settings"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            // 24-hour format
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: clockFormat24hr.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: clockFormat24hr.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showSeconds.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showSeconds.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: dateFormatDMY.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: dateFormatDMY.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: dateLong.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: dateLong.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showDayOfWeek.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showDayOfWeek.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                        }
                        
                        // ========== CALENDAR SETTINGS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard3.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard3
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16
                            
                            
                            Text {
                                text: "  Calendar Settings"
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
                        }
                        
                        // ========== WEATHER SETTINGS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard4.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard4
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16
                            
                            
                            Text {
                                text: "\ue30c  Weather Settings"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }
                            
                            // Temperature Unit
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: useFahrenheit.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: useFahrenheit.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                

                // Tab 1: SCREENSHOTS ──────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.parent.width
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: saveToDiskCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: saveToDiskCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: copyToClipboardCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: copyToClipboardCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                

                // Tab 2: BAR ────────────────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.parent.width
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
                                        width: 48
                                        height: 24
                                        radius: 12
                                        color: barSolidCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 9
                                            color: ThemeManager.fgPrimary
                                            x: barSolidCheck.checked ? parent.width - width - 3 : 3
                                            anchors.verticalCenter: parent.verticalCenter
                                            Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showBorderCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showBorderCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: floatingBarCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: floatingBarCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: barSizeLargeCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: barSizeLargeCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: barPositionBottomCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: barPositionBottomCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: barAutoHideCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: barAutoHideCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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

                            // Show Weather in Bar Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showWeatherInBarCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showWeatherInBarCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showWeatherInBarCheck.checked = !showWeatherInBarCheck.checked
                                            if (!root.settings.bar) root.settings.bar = {}
                                            root.settings.bar.showWeatherInBar = showWeatherInBarCheck.checked
                                            saveSettings()
                                        }
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Text {
                                        text: "Show weather in bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: showWeatherInBarCheck.checked
                                            ? "Showing current condition and temperature in bar"
                                            : "Weather is hidden from the bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                QtObject {
                                    id: showWeatherInBarCheck
                                    property bool checked: false
                                }
                            }

                            // Show Quick Launch Drawer Toggle
                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showQuickLaunchCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showQuickLaunchCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showSystemTrayCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showSystemTrayCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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

                            // Workspace Style
                            Row {
                                spacing: 12

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Workspace indicators"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 12
                                        color: ThemeManager.fgPrimary
                                    }

                                    Text {
                                        text: "Show workspace numbers or dots in the bar"
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgSecondary
                                    }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Rectangle {
                                        width: 64
                                        height: 28
                                        radius: 6
                                        color: ThemeManager.workspaceStyle !== "dots"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: ThemeManager.workspaceStyle !== "dots"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.15)
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "1  2  3"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 11
                                            color: ThemeManager.workspaceStyle !== "dots" ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                ThemeManager.workspaceStyle = "numbers"
                                                if (!root.settings.bar) root.settings.bar = {}
                                                root.settings.bar.workspaceStyle = "numbers"
                                                saveSettings()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 64
                                        height: 28
                                        radius: 6
                                        color: ThemeManager.workspaceStyle === "dots"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                                            : Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: ThemeManager.workspaceStyle === "dots"
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                                            : Qt.rgba(1, 1, 1, 0.15)
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf444  \uf444  \uf444"
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 11
                                            color: ThemeManager.workspaceStyle === "dots" ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                ThemeManager.workspaceStyle = "dots"
                                                if (!root.settings.bar) root.settings.bar = {}
                                                root.settings.bar.workspaceStyle = "dots"
                                                saveSettings()
                                            }
                                        }
                                    }
                                }
                            }

                            // Show Battery Details
                            Row {
                                spacing: 12
                                
                                Rectangle {
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showBatteryDetailsCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showBatteryDetailsCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showVolumeDetailsCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showVolumeDetailsCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: showNetworkDetailsCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: showNetworkDetailsCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                

                // Tab 3: HYPRLAND ────────────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.parent.width
                        spacing: 32

                        // ========== WINDOW DECORATIONS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard5.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard5
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16


                            Text {
                                text: "  Window Decorations"
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: hyprBorderEnabledCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: hyprBorderEnabledCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                            ThemeManager.showWidgetBorders = hyprBorderEnabledCheck.checked
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
                                            ThemeManager.widgetBorderWidth = val
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
                        }

                        // ========== WINDOW GAPS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard6.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard6
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16


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
                        }

                        // ========== EFFECTS ==========
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard7.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard7
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16


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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: hyprAnimationsCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: hyprAnimationsCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: hyprShadowCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: hyprShadowCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                                    width: 48
                                    height: 24
                                    radius: 12
                                    color: hyprBlurCheck.checked ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: ThemeManager.fgPrimary
                                        x: hyprBlurCheck.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on x { NumberAnimation { duration: 200 } }
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
                }


                // Tab 4: THEME ──────────────────────────────────────
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

                        // App restart note
                        Rectangle {
                            width: parent.width
                            height: restartNoteText.implicitHeight + 20
                            color: Qt.rgba(ThemeManager.accentYellow.r, ThemeManager.accentYellow.g, ThemeManager.accentYellow.b, 0.08)
                            radius: 8
                            border.width: 1
                            border.color: Qt.rgba(ThemeManager.accentYellow.r, ThemeManager.accentYellow.g, ThemeManager.accentYellow.b, 0.30)

                            Text {
                                id: restartNoteText
                                anchors.centerIn: parent
                                width: parent.width - 24
                                text: "⚠  Some applications need to be relaunched before theme changes take full effect, including Kitty terminal and Thunar file manager."
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                font.italic: true
                                color: ThemeManager.accentYellow
                                wrapMode: Text.WordWrap
                            }
                        }
                        
                        Repeater {
                            model: themeModel
                            
                            Rectangle {
                                id: themeCard
                                width: Math.min(parent.width - 40, 520)
                                x: (parent.width - width) / 2
                                height: 72
                                radius: 10
                                clip: true
                                color: cardBg

                                property bool isActive: model.name === root.currentTheme

                                border.width: isActive ? 2 : (themeMouseArea.containsMouse ? 1 : 0)
                                border.color: isActive ? "#a6e3a1" : Qt.rgba(1, 1, 1, 0.22)

                                Behavior on border.width {
                                    NumberAnimation { duration: 150 }
                                }

                                property string cardBg: {
                                    var m = {
                                        "Catppuccin":"#1e1e2e","Dracula":"#282a36","Eldritch":"#212337",
                                        "Everforest":"#374247","Gruvbox":"#282828","Kanagawa":"#1f1f28",
                                        "Material":"#263238","Monochrome":"#252525","NightFox":"#131a24",
                                        "Nord":"#2e3440","Rosepine":"#191724","Solarized":"#002b36",
                                        "TokyoNight":"#1a1b26"
                                    };
                                    return m[model.name] || "#1e1e2e";
                                }

                                property string cardFg: {
                                    var m = {
                                        "Catppuccin":"#cdd6f4","Dracula":"#f8f8f2","Eldritch":"#ebfafa",
                                        "Everforest":"#d3c6aa","Gruvbox":"#ebdbb2","Kanagawa":"#dcd7ba",
                                        "Material":"#eeffff","Monochrome":"#bebebe","NightFox":"#cdcecf",
                                        "Nord":"#eceff4","Rosepine":"#e0def4","Solarized":"#839496",
                                        "TokyoNight":"#c0caf5"
                                    };
                                    return m[model.name] || "#cdd6f4";
                                }

                                property var cardAccents: {
                                    var m = {
                                        "Catppuccin":["#89b4fa","#cba6f7","#f5c2e7","#f38ba8","#fab387","#f9e2af","#a6e3a1","#94e2d5"],
                                        "Dracula":   ["#bd93f9","#ff79c6","#ff6e6e","#ffb86c","#f1fa8c","#50fa7b","#8be9fd","#6272a4"],
                                        "Eldritch":  ["#f16c75","#f265b5","#7081d0","#a48cf2","#37f499","#04d1f9","#ffd700","#323449"],
                                        "Everforest":["#e67e80","#e69875","#dbbc7f","#a7c080","#83c092","#7fbbb3","#d699b6","#9da9a0"],
                                        "Gruvbox":   ["#fb4934","#fe8019","#fabd2f","#b8bb26","#8ec07c","#83a598","#d3869b","#689d6a"],
                                        "Kanagawa":  ["#7fb4ca","#957fb8","#d27e99","#e46876","#dca561","#98bb6c","#7aa89f","#938aa9"],
                                        "Material":  ["#82aaff","#c792ea","#f07178","#f78c6c","#ffcb6b","#c3e88d","#89ddff","#546e7a"],
                                        "Monochrome":["#bebebe","#a8a8a8","#999999","#888888","#777777","#666666","#555555","#444444"],
                                        "NightFox":  ["#719cd6","#9d79d6","#d67ad2","#f52a65","#f4a261","#dbc074","#63cdcf","#4d688e"],
                                        "Nord":      ["#88c0d0","#81a1c1","#5e81ac","#bf616a","#d08770","#ebcb8b","#a3be8c","#b48ead"],
                                        "Rosepine":  ["#c4a7e7","#ebbcba","#eb6f92","#f6c177","#ea9a97","#9ccfd8","#31748f","#907aa9"],
                                        "Solarized": ["#268bd2","#6c71c4","#d33682","#dc322f","#cb4b16","#b58900","#859900","#2aa198"],
                                        "TokyoNight":["#7aa2f7","#bb9af7","#f7768e","#ff9e64","#e0af68","#9ece6a","#73daca","#7dcfff"]
                                    };
                                    return m[model.name] || ["#89b4fa","#cba6f7","#f38ba8","#fab387","#f9e2af","#a6e3a1","#94e2d5","#74c7ec"];
                                }

                                // Top band — theme bg color with name and current badge
                                Rectangle {
                                    id: topBand
                                    anchors.top: parent.top
                                    anchors.topMargin: themeCard.border.width
                                    anchors.left: parent.left
                                    anchors.leftMargin: themeCard.border.width
                                    anchors.right: parent.right
                                    anchors.rightMargin: themeCard.border.width
                                    anchors.bottom: accentBarWrap.top
                                    color: themeCard.cardBg
                                    topLeftRadius: Math.max(0, themeCard.radius - themeCard.border.width)
                                    topRightRadius: Math.max(0, themeCard.radius - themeCard.border.width)

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
                                        color: themeCard.cardFg
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
                                Rectangle {
                                    id: accentBarWrap
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 8
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.min(parent.width - 80, 480)
                                    height: 8
                                    radius: 4
                                    clip: true

                                    Row {
                                        anchors.fill: parent
                                        Repeater {
                                            model: themeCard.cardAccents
                                            Rectangle {
                                                width: accentBarWrap.width / themeCard.cardAccents.length
                                                height: accentBarWrap.height
                                                color: modelData
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

                // Tab 5: WALLPAPER ────────────────────────────────
                Item {
                    id: wallpaperTabItem
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property int wallSubTab: 0
                    property string wallCurrentTheme: ""

                    onVisibleChanged: {
                        if (visible && wallCurrentTheme === "") {
                            wallCurrentThemeProc.running = true
                        }
                    }

                    Process {
                        id: wallCurrentThemeProc
                        running: false
                        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/.current-theme"]
                        property string buffer: ""
                        stdout: SplitParser { onRead: data => wallCurrentThemeProc.buffer += data }
                        onRunningChanged: {
                            if (!running && buffer !== "") {
                                wallpaperTabItem.wallCurrentTheme = buffer.trim() || "TokyoNight"
                                buffer = ""
                                wallThemeModel.clear()
                                wallThemeProc.running = true
                            } else if (running) { buffer = "" }
                        }
                    }

                    ListModel { id: wallThemeModel }

                    Process {
                        id: wallThemeProc
                        running: false
                        command: ["sh", "-c",
                            "find '" + Quickshell.env("HOME") + "/Pictures/Wallpapers/" + wallpaperTabItem.wallCurrentTheme + "' " +
                            "-maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) " +
                            "| sort -f"]
                        stdout: SplitParser {
                            onRead: data => {
                                const p = data.trim()
                                if (p.length > 0) wallThemeModel.append({path: p, name: p.split('/').pop()})
                            }
                        }
                    }

                    ListModel { id: wallAllModel }

                    Process {
                        id: wallAllProc
                        running: false
                        command: ["find", Quickshell.env("HOME") + "/Pictures/Wallpapers",
                            "-type", "f",
                            "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg",
                                 "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")",
                            "-not", "-path", "*/.*"]
                        property string buffer: ""
                        stdout: SplitParser { onRead: data => wallAllProc.buffer += data + "\n" }
                        onRunningChanged: {
                            if (!running && buffer !== "") {
                                wallAllModel.clear()
                                const lines = buffer.trim().split("\n").filter(l => l.length > 0).sort()
                                for (const p of lines)
                                    wallAllModel.append({path: p, name: p.split('/').pop()})
                                buffer = ""
                            } else if (running) { buffer = "" }
                        }
                    }

                    function applyWallpaper(path) {
                        Quickshell.execDetached(["awww", "img", path,
                            "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-duration", "2"])
                        Quickshell.execDetached(["bash", "-c",
                            'printf "%s" "$1" > ~/.config/quickshell/last-wallpaper', "--", path])
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 0

                        // ── Sub-tab bar ──────────────────────────────────
                        Rectangle {
                            width: parent.width
                            height: 44
                            color: "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                spacing: 4

                                Repeater {
                                    model: ["Theme Wallpaper", "All Wallpapers"]

                                    Rectangle {
                                        width: 150
                                        height: parent.height
                                        radius: 6
                                        color: wallpaperTabItem.wallSubTab === index
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.20)
                                            : (wallSubTabMA.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")
                                        border.width: wallpaperTabItem.wallSubTab === index ? 1 : 0
                                        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.40)
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 13
                                            font.weight: wallpaperTabItem.wallSubTab === index ? Font.Medium : Font.Normal
                                            color: wallpaperTabItem.wallSubTab === index ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                        }
                                        MouseArea {
                                            id: wallSubTabMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                wallpaperTabItem.wallSubTab = index
                                                if (index === 0) {
                                                    wallThemeModel.clear()
                                                    wallThemeProc.running = true
                                                } else {
                                                    if (wallAllModel.count === 0) {
                                                        wallAllProc.running = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }



                        // ── Content ──────────────────────────────────────
                        Item {
                            width: parent.width
                            height: parent.height - 45

                            // Theme Wallpaper sub-tab
                            GridView {
                                id: wallThemeGrid
                                anchors.fill: parent
                                clip: true
                                visible: wallpaperTabItem.wallSubTab === 0
                                model: wallThemeModel
                                boundsBehavior: Flickable.StopAtBounds
                                property int cols: 3
                                cellWidth: Math.floor(width / cols)
                                cellHeight: Math.floor(cellWidth * 10 / 16) + 4
                                topMargin: 12
                                bottomMargin: 12

                                delegate: Item {
                                    width: wallThemeGrid.cellWidth
                                    height: wallThemeGrid.cellHeight
                                    property string wallPath: model.path
                                    property string wallName: model.name

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        radius: 8
                                        clip: true
                                        color: Qt.rgba(1,1,1,0.05)
                                        border.width: wallThumbMA.containsMouse ? 2 : 1
                                        border.color: wallThumbMA.containsMouse
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.9)
                                            : Qt.rgba(1,1,1,0.12)

                                        Image {
                                            anchors.fill: parent
                                            source: "file://" + wallPath
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            asynchronous: true
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 22
                                            color: Qt.rgba(0,0,0,0.65)
                                            Text {
                                                anchors.centerIn: parent
                                                text: wallName
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 10
                                                color: "white"
                                                elide: Text.ElideRight
                                                width: parent.width - 8
                                            }
                                        }

                                        MouseArea {
                                            id: wallThumbMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: wallpaperTabItem.applyWallpaper(wallPath)
                                        }
                                    }
                                }
                            }

                            // All Wallpapers sub-tab
                            GridView {
                                id: wallAllGrid
                                anchors.fill: parent
                                clip: true
                                visible: wallpaperTabItem.wallSubTab === 1
                                model: wallAllModel
                                boundsBehavior: Flickable.StopAtBounds
                                property int cols: 3
                                cellWidth: Math.floor(width / cols)
                                cellHeight: Math.floor(cellWidth * 10 / 16) + 4
                                topMargin: 12
                                bottomMargin: 12

                                delegate: Item {
                                    width: wallAllGrid.cellWidth
                                    height: wallAllGrid.cellHeight

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        radius: 8
                                        clip: true
                                        color: Qt.rgba(1,1,1,0.05)
                                        border.width: allWallMA.containsMouse ? 2 : 1
                                        border.color: allWallMA.containsMouse
                                            ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.9)
                                            : Qt.rgba(1,1,1,0.12)

                                        Image {
                                            anchors.fill: parent
                                            source: "file://" + model.path
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            asynchronous: true
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 22
                                            color: Qt.rgba(0,0,0,0.65)
                                            Text {
                                                anchors.centerIn: parent
                                                text: model.name
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 10
                                                color: "white"
                                                elide: Text.ElideRight
                                                width: parent.width - 8
                                            }
                                        }

                                        MouseArea {
                                            id: allWallMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: wallpaperTabItem.applyWallpaper(model.path)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Tab 6: MONITORS ─────────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.parent.width
                        spacing: 24

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: sectionCard8.implicitHeight + 32
                            color: Qt.rgba(1, 1, 1, 0.05)
                            radius: 10
                            clip: true
                            Column {
                            id: sectionCard8
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 16


                            Text {
                                text: "  Monitors"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: ThemeManager.accentBlue
                            }

                            Text {
                                text: "Configure connected displays. Changes apply immediately via Hyprland."
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            Rectangle {
                                width: 130
                                height: 30
                                radius: 6
                                color: monRefreshHover.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.20) : Qt.rgba(1,1,1,0.06)
                                border.width: 1
                                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)

                                Text {
                                    anchors.centerIn: parent
                                    text: "↺  Refresh"
                                    font.family: ThemeManager.uiFont
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                }

                                MouseArea {
                                    id: monRefreshHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        monitorLoader.buffer = ""
                                        monitorLoader.running = true
                                    }
                                }
                            }
                        }
                        }

                        Repeater {
                            model: monitorsModel

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: monCardCol.implicitHeight + 32
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.07)

                                property string monName: model.name
                                property var monModes: (model.modesJson && model.modesJson.length > 2) ? JSON.parse(model.modesJson) : []
                                property real monScale: model.scale
                                property string monCurrentMode: model.currentMode

                                ColumnLayout {
                                    id: monCardCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 16
                                    spacing: 12

                                    Row {
                                        spacing: 10
                                        Text {
                                            text: "🖥  " + model.name
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 15
                                            font.weight: Font.Bold
                                            color: ThemeManager.fgPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Rectangle {
                                            visible: model.focused
                                            width: focBadge.implicitWidth + 12
                                            height: 18
                                            radius: 4
                                            color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.20)
                                            border.width: 1
                                            border.color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.50)
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text { id: focBadge; anchors.centerIn: parent; text: "focused"; font.pixelSize: 10; color: ThemeManager.accentGreen }
                                        }
                                    }

                                    Text {
                                        text: model.description || ""
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 10
                                        color: ThemeManager.fgTertiary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        visible: (model.description || "").length > 0
                                    }

                                    Text {
                                        text: "Current: " + model.width + "×" + model.height + " @ " + Math.round(model.refreshRate) + " Hz  ·  Scale: " + model.scale.toFixed(2)
                                        font.family: ThemeManager.uiFont
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }

                                    // Mode selector
                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Text {
                                            text: "Resolution & Refresh Rate"
                                            font.family: ThemeManager.uiFont
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: ThemeManager.fgPrimary
                                        }

                                        ComboBox {
                                            id: modeCombo
                                            width: parent.width
                                            height: 32
                                            model: monModes
                                            currentIndex: {
                                                var idx = monModes.indexOf(monCurrentMode)
                                                return idx >= 0 ? idx : 0
                                            }

                                            background: Rectangle {
                                                color: modeCombo.pressed ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.07)
                                                radius: 6
                                                border.width: 1
                                                border.color: Qt.rgba(1, 1, 1, 0.18)
                                            }

                                            contentItem: Text {
                                                leftPadding: 8
                                                text: modeCombo.displayText
                                                color: ThemeManager.fgPrimary
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            delegate: ItemDelegate {
                                                width: modeCombo.width
                                                contentItem: Text {
                                                    text: modelData
                                                    color: ThemeManager.fgPrimary
                                                    font.family: ThemeManager.uiFont
                                                    font.pixelSize: 12
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                background: Rectangle {
                                                    color: parent.hovered ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.20) : ThemeManager.bgBase
                                                }
                                            }

                                            popup: Popup {
                                                y: modeCombo.height
                                                width: modeCombo.width
                                                padding: 0
                                                contentItem: ListView {
                                                    clip: true
                                                    implicitHeight: Math.min(contentHeight, 200)
                                                    model: modeCombo.delegateModel
                                                    ScrollIndicator.vertical: ScrollIndicator {}
                                                }
                                                background: Rectangle {
                                                    color: ThemeManager.bgBase
                                                    radius: 6
                                                    border.width: 1
                                                    border.color: Qt.rgba(1,1,1,0.15)
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 110
                                            height: 28
                                            radius: 6
                                            color: applyModeHov.containsMouse ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.25) : Qt.rgba(1,1,1,0.06)
                                            border.width: 1
                                            border.color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.45)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Apply Mode"
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 11
                                                color: ThemeManager.accentGreen
                                            }

                                            MouseArea {
                                                id: applyModeHov
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (modeCombo.currentIndex >= 0 && modeCombo.currentIndex < monModes.length) {
                                                        applyMonitorMode(monName, monModes[modeCombo.currentIndex])
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Scale
                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Row {
                                            spacing: 8
                                            Text {
                                                text: "Scale:"
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: ThemeManager.fgPrimary
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            Text {
                                                text: scaleSlider.value.toFixed(2) + "×"
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 12
                                                color: ThemeManager.accentBlue
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        Slider {
                                            id: scaleSlider
                                            width: parent.width
                                            height: 24
                                            from: 0.5
                                            to: 3.0
                                            stepSize: 0.1
                                            value: monScale

                                            background: Rectangle {
                                                x: scaleSlider.leftPadding
                                                y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                                width: scaleSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: Qt.rgba(1, 1, 1, 0.15)
                                                Rectangle {
                                                    width: scaleSlider.visualPosition * parent.width
                                                    height: parent.height
                                                    color: ThemeManager.accentBlue
                                                    radius: 2
                                                }
                                            }

                                            handle: Rectangle {
                                                x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                                                y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: ThemeManager.accentBlue
                                            }
                                        }

                                        Rectangle {
                                            width: 110
                                            height: 28
                                            radius: 6
                                            color: applyScaleHov.containsMouse ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.25) : Qt.rgba(1,1,1,0.06)
                                            border.width: 1
                                            border.color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.45)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Apply Scale"
                                                font.family: ThemeManager.uiFont
                                                font.pixelSize: 11
                                                color: ThemeManager.accentGreen
                                            }

                                            MouseArea {
                                                id: applyScaleHov
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: applyMonitorScale(monName, scaleSlider.value)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true; height: 20 }
                    }
                }

                // Tab 7: ABOUT ─────────────────────────────────────────
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        id: aboutContent
                        width: parent.parent.width
                        spacing: 0

                        Item { Layout.fillWidth: true; height: 32 }

                        Item {
                            Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 420
                Layout.preferredHeight: 420
                implicitWidth: 420
                implicitHeight: 420
                            Image {
                                anchors.fill: parent
                                source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/yahr_logo.png"
                                fillMode: Image.PreserveAspectFit
                                smooth: true; antialiasing: true
                            }
                        }

                        Item { Layout.fillWidth: true; height: 16 }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "YahrShell"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 30; font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                        }

                        Item { Layout.fillWidth: true; height: 4 }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Yet Another Hyprland Rice"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 14
                            color: ThemeManager.fgSecondary
                        }

                        Item { Layout.fillWidth: true; height: 4 }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "v1.6"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 12; font.weight: Font.Bold
                            color: ThemeManager.accentBlue
                        }

                        Item { Layout.fillWidth: true; height: 24 }

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Rectangle {
                                width: 196; height: 40; radius: 8
                                color: ghMA.containsMouse
                                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.22)
                                    : Qt.rgba(1,1,1,0.06)
                                border.width: 1
                                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.40)
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Row {
                                    anchors.centerIn: parent; spacing: 8
                                    Text { text: "\uf09b"; font.family: "Symbols Nerd Font"; font.pixelSize: 17; color: ThemeManager.accentBlue; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "GitHub Repository"; font.family: ThemeManager.uiFont; font.pixelSize: 13; color: ThemeManager.fgPrimary; anchors.verticalCenter: parent.verticalCenter }
                                }
                                MouseArea {
                                    id: ghMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["xdg-open", "https://github.com/bgibson72/yahr-quickshell"])
                                }
                            }

                            Rectangle {
                                width: 196; height: 40; radius: 8
                                color: webMA.containsMouse
                                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.22)
                                    : Qt.rgba(1,1,1,0.06)
                                border.width: 1
                                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.40)
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Row {
                                    anchors.centerIn: parent; spacing: 8
                                    Text { text: "\uf0ac"; font.family: "Symbols Nerd Font"; font.pixelSize: 15; color: ThemeManager.accentBlue; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "vegvisirdesign.me"; font.family: ThemeManager.uiFont; font.pixelSize: 13; color: ThemeManager.fgPrimary; anchors.verticalCenter: parent.verticalCenter }
                                }
                                MouseArea {
                                    id: webMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["xdg-open", "https://vegvisirdesign.me"])
                                }
                            }
                        }

                        Item { Layout.fillWidth: true; height: 28 }
                        Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.10) }
                        Item { Layout.fillWidth: true; height: 20 }

                        Row {
                            spacing: 8
                            Text { text: "\uf1da"; font.family: "Symbols Nerd Font"; font.pixelSize: 15; color: ThemeManager.accentBlue; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Update Log"; font.family: ThemeManager.uiFont; font.pixelSize: 15; font.weight: Font.Bold; color: ThemeManager.fgPrimary; anchors.verticalCenter: parent.verticalCenter }
                        }

                        Item { Layout.fillWidth: true; height: 14 }

                        Repeater {
                            model: [
                                {version: "v1.6", date: "June 2026", summary: "Widget color consistency across all panels; workspace style toggle (numbers/dots); live widget borders; all 7 ThemeManager preferences now persist across theme switches; flat All Wallpapers grid; GTK theme mapping fixes; bgBaseAlpha fix in all theme files; Monochrome & Solarized wallpaper sets."},
                                {version: "v1.5", date: "2026", summary: "Flexible date format controls — 12/24hr, MM/DD vs DD/MM, numeric or long-form, optional day-of-week prefix; SDDM & Hyprlock date sync; wallpaper persistence across reboots; awww daemon support replacing swww."},
                                {version: "v1.4", date: "2026", summary: "Glass/Liquid Glass UI overhaul — frosted panels, specular highlights, smooth hover transitions; glass window borders with 45° theme-accent gradient; glass Mako notification styling; Sip-StartPage integration; AppLauncher cubic slide animation."},
                                {version: "v1.3", date: "2026", summary: "Google Calendar integration via iCal URL — full RRULE support (daily/weekly/monthly/yearly); timezone-aware event parsing; all-day events; event indicators; auto-refresh every 15 minutes."},
                                {version: "v1.2", date: "2026", summary: "Bar position toggle (top/bottom); Neovim AstroVim theme sync; enhanced GPU auto-detection installer; Thunar thumbnail support; colored weather emoji icons; fastfetch themed logos; CLI app launcher support."},
                                {version: "v1.1", date: "2026", summary: "Update counter for official repos and AUR; pacman lock file handling; paru/yay integration; hourly checks with wake-from-sleep detection."},
                                {version: "v1.0", date: "2025", summary: "Initial release — Hyprland + Quickshell desktop with 13 themes, unified instant theme switching, glassmorphism UI, fully automated Arch Linux installer with GPU detection and YOLO unattended mode."}
                            ]
                            delegate: ColumnLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 32
                                Layout.rightMargin: 32
                                spacing: 5
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: modelData.version; font.family: ThemeManager.uiFont; font.pixelSize: 13; font.weight: Font.Bold; color: ThemeManager.accentBlue }
                                    Text { text: "— " + modelData.date; font.family: ThemeManager.uiFont; font.pixelSize: 12; color: ThemeManager.fgTertiary }
                                    Item { Layout.fillWidth: true }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.summary
                                    font.family: ThemeManager.uiFont; font.pixelSize: 12
                                    color: ThemeManager.fgSecondary
                                    wrapMode: Text.WordWrap; lineHeight: 1.35
                                }
                                Item { Layout.fillWidth: true; height: 6 }
                                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.07) }
                                Item { Layout.fillWidth: true; height: 10 }
                            }
                        }

                        Item { Layout.fillWidth: true; height: 8 }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uf004  Made with love for the Arch + Hyprland community"
                            font.family: "Symbols Nerd Font, " + ThemeManager.uiFont
                            font.pixelSize: 12; color: ThemeManager.fgTertiary
                        }

                        Item { Layout.fillWidth: true; height: 28 }
                    }
                }

            }


        }
    }

    // ── Header Bar (full-width, sticky top) ──────────────────────────
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: root.border.width
        anchors.leftMargin: root.border.width
        anchors.rightMargin: root.border.width
        height: 56
        z: 150
        visible: !root.embedded
        color: ThemeManager.bgBase
        topLeftRadius: Math.max(0, root.hyprRounding - root.border.width)
        topRightRadius: Math.max(0, root.hyprRounding - root.border.width)

        // Title
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "YAHR Settings"
            font.family: ThemeManager.uiFont
            font.pixelSize: 16
            font.weight: Font.Bold
            color: ThemeManager.fgPrimary
        }

        // Close button
        Rectangle {
            id: headerCloseBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 12
            width: 28
            height: 28
            radius: 6
            color: headerCloseMA.containsMouse
                ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.28)
                : Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
            border.color: headerCloseMA.containsMouse
                ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.55)
                : Qt.rgba(1, 1, 1, 0.18)
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "\u2715"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 13
                color: headerCloseMA.containsMouse ? ThemeManager.accentRed : ThemeManager.fgSecondary
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: headerCloseMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
            }
        }
    }

    // ── Apply Toolbar (full-width, sticky bottom) ────────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        z: 150
        visible: sidebar.currentIndex === 0 || sidebar.currentIndex === 1
        color: ThemeManager.bgBase
        bottomLeftRadius: root.hyprRounding
        bottomRightRadius: root.hyprRounding

        // Apply button
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            width: 120
            height: 36
            radius: 8
            clip: true
            color: applyButtonMouseArea.containsMouse && !applyButtonSuccess
                ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.25)
                : "transparent"
            border.width: 1
            border.color: Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.55)

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
                    Transition { from: ""; to: "filling"; NumberAnimation { property: "width"; duration: 1500; easing.type: Easing.Linear } },
                    Transition { from: "filling"; to: ""; NumberAnimation { property: "width"; duration: 0 } }
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
                enabled: !applyButtonSuccess
                onClicked: applySettings()
            }
        }
    }

}

