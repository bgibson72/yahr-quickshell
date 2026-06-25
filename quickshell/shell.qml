import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shellRoot
    
    property bool calendarVisible: false
    property bool appLauncherVisible: false
    property bool powerMenuVisible: false
    property bool themeSwitcherVisible: false
    property bool screenshotVisible: false
    property bool settingsVisible: false
    property bool clipboardVisible: false
    property bool controlCenterVisible: false
    property var wallpaperPicker: wallpaperPickerWindow
    property bool barAtBottom: false
    property bool barAutoHide: false
    property bool barFloating: false
    property string barSize: "small"
    property string barStyle: "single"
    property string barLayoutPreset: "default"
    property bool barShowQuickLaunch: true
    property bool barShowSystemTray: true
    property bool barShowBorder: false
    property string barBackgroundStyle: "opaque"
    property real barOpacity: 0.70
    property int barWidgetBorderWidth: 1
    property int barHyprRounding: 12
    property int barMinWorkspaces: 4
    
    // Make shellRoot globally accessible via objectName
    objectName: "shellRoot"

    Process {
        id: shellBarSettingsLoader
        running: true
        command: ["sh", "-c", "cat ~/.config/quickshell/settings.json 2>/dev/null || echo '{}' "]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                shellBarSettingsLoader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.bar) {
                        if (settings.bar.position) shellRoot.barAtBottom = settings.bar.position === "bottom"
                        if (settings.bar.autoHide !== undefined) shellRoot.barAutoHide = settings.bar.autoHide
                        if (settings.bar.floating !== undefined) shellRoot.barFloating = settings.bar.floating
                        if (settings.bar.barSize !== undefined) shellRoot.barSize = settings.bar.barSize
                        if (settings.bar.barStyle !== undefined) shellRoot.barStyle = settings.bar.barStyle
                        if (settings.bar.layoutPreset !== undefined) shellRoot.barLayoutPreset = settings.bar.layoutPreset
                        if (settings.bar.showQuickLaunch !== undefined) shellRoot.barShowQuickLaunch = settings.bar.showQuickLaunch
                        if (settings.bar.showSystemTray !== undefined) shellRoot.barShowSystemTray = settings.bar.showSystemTray
                        if (settings.bar.minWorkspaces !== undefined) shellRoot.barMinWorkspaces = settings.bar.minWorkspaces
                        if (settings.bar.showBorder !== undefined) shellRoot.barShowBorder = settings.bar.showBorder
                        if (settings.bar.backgroundStyle !== undefined) shellRoot.barBackgroundStyle = settings.bar.backgroundStyle
                        if (settings.bar.barOpacity !== undefined) shellRoot.barOpacity = settings.bar.barOpacity
                    }
                    if (settings.general) {
                        const transparent = settings.general.widgetTransparent !== false
                        ThemeManager.widgetOpacity = transparent ? 0.75 : 1.0
                        if (settings.general.uiFont !== undefined && settings.general.uiFont.length > 0) {
                            ThemeManager.uiFont = settings.general.uiFont
                        }
                        if (settings.general.widgetBorderWidth !== undefined) {
                            shellRoot.barWidgetBorderWidth = settings.general.widgetBorderWidth
                        }
                    }
                    if (settings.hypr && settings.hypr.rounding !== undefined) {
                        shellRoot.barHyprRounding = settings.hypr.rounding
                    }
                    ThemeManager.barLarge = shellRoot.barSize === "large"
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: shellBarSettingsLoader.running = true
    }
    
    // Public toggle functions for IPC
    function toggleAppLauncher() {
        console.log("IPC: Toggling app launcher")
        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
    }
    
    function toggleCalendar() {
        console.log("IPC: Toggling calendar")
        shellRoot.calendarVisible = !shellRoot.calendarVisible
    }
    
    function togglePowerMenu() {
        console.log("IPC: Toggling power menu")
        shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
    }
    
    function toggleThemeSwitcher() {
        console.log("IPC: Toggling theme switcher")
        shellRoot.themeSwitcherVisible = !shellRoot.themeSwitcherVisible
    }
    
    function toggleScreenshot() {
        console.log("IPC: Toggling screenshot widget")
        shellRoot.screenshotVisible = !shellRoot.screenshotVisible
    }
    
    function toggleSettings() {
        console.log("IPC: Toggling settings")
        shellRoot.settingsVisible = !shellRoot.settingsVisible
    }
    
    function toggleClipboard() {
        console.log("IPC: Toggling clipboard")
        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
    }
    
    function toggleControlCenter() {
        console.log("IPC: Toggling control center")
        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
    }
    
    // Wallpaper Picker window
    WallpaperPicker {
        id: wallpaperPickerWindow
        
        Component.onCompleted: {
            WallpaperPickerBridge.pickerWindow = wallpaperPickerWindow
        }
    }

    // On every quickshell startup, sync .current-theme to the active theme from settings.json.
    // This prevents a stale .current-theme from causing theme reversions on restart.
    Process {
        id: themeFileSync
        running: true
        // Read theme from settings.json — the authoritative source — to avoid depending
        // on a ThemeManager property that may not exist or be unset at startup.
        // Also re-applies kitty, mako and hyprlock themes so they match on every startup.
        command: ["bash", "-c",
            "theme=$(python3 -c \"import json,os; d=json.load(open(os.environ['HOME']+'/.config/quickshell/settings.json')); print(d.get('theme',{}).get('current','Catppuccin'))\" 2>/dev/null || echo 'Catppuccin'); " +
            "printf '%s' \"$theme\" > \"$HOME/.config/hypr/.current-theme\"; " +
            "\"$HOME/.config/quickshell/sync-kitty-theme.sh\" >/dev/null 2>&1; " +
            "\"$HOME/.config/quickshell/sync-mako-theme.sh\" >/dev/null 2>&1; " +
            "\"$HOME/.config/quickshell/sync-hyprlock-theme.sh\" >/dev/null 2>&1"]
    }

    // Listen for calendar toggle requests
    Connections {
        target: Quickshell
        function onReload() {
            console.log("Quickshell reloaded")
        }
    }

    // Consolidated IPC watcher - single process for all keybinds (efficient!)
    Process {
        id: consolidatedIpcWatcher
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/consolidated-ipc-watcher.sh"]
        
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(":")
                if (parts.length !== 2) return
                
                const component = parts[0]
                const action = parts[1]
                
                if (action === "toggle") {
                    switch (component) {
                        case "themeswitcher":
                            shellRoot.themeSwitcherVisible = !shellRoot.themeSwitcherVisible
                            console.log("Theme switcher toggled via keybind:", shellRoot.themeSwitcherVisible)
                            break
                        case "applauncher":
                            shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                            console.log("App launcher toggled via keybind:", shellRoot.appLauncherVisible)
                            break
                        case "calendar":
                            shellRoot.calendarVisible = !shellRoot.calendarVisible
                            console.log("Calendar toggled via keybind:", shellRoot.calendarVisible)
                            break
                        case "powermenu":
                            shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
                            console.log("Power menu toggled via keybind:", shellRoot.powerMenuVisible)
                            break
                        case "screenshot":
                            shellRoot.screenshotVisible = !shellRoot.screenshotVisible
                            console.log("Screenshot widget toggled via keybind:", shellRoot.screenshotVisible)
                            break
                        case "settings":
                            shellRoot.settingsVisible = !shellRoot.settingsVisible
                            console.log("Settings widget toggled via keybind:", shellRoot.settingsVisible)
                            break
                        case "clipboard":
                            shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                            console.log("Clipboard toggled via keybind:", shellRoot.clipboardVisible)
                            break
                    }
                }
            }
        }
    }
    
    // Calendar popup - anchored below clock (center)
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: leftBarWindow
            property var modelData
            screen: modelData
            
            visible: shellRoot.calendarVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside calendar panel")
                    shellRoot.calendarVisible = false
                }
                propagateComposedEvents: false
            }
            
            // Panel positioned at top-center, slides down
            Item {
                width: 900
                height: 700
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: shellRoot.calendarVisible ? 6 : -800
                
                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                SystemInfoWidget {
                    anchors.fill: parent
                    isVisible: shellRoot.calendarVisible
                    opacity: shellRoot.calendarVisible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        shellRoot.calendarVisible = false
                    }
                }
            }
        }
    }
    
    // App Launcher popup - anchored below Arch button
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.appLauncherVisible

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside app launcher")
                    shellRoot.appLauncherVisible = false
                }
                propagateComposedEvents: false
            }
            
            // Panel - positioned and sized based on Arch button location
            Item {
                id: launcherPanel
                // isLeft: Arch button in left island ("default" preset)
                // center: Arch button in center island ("center-menu" preset)
                property bool isLeft: shellRoot.barLayoutPreset === "default"
                property int barBottom: (ThemeManager.barLarge ? 43 : 36) + (shellRoot.barFloating ? 8 : 0) + 8

                width: isLeft ? 480 : 1000
                height: isLeft ? 700 : 600

                x: isLeft
                    ? (shellRoot.appLauncherVisible ? 8 : -(width + 8))
                    : (parent.width - width) / 2

                y: isLeft
                    ? 6
                    : (shellRoot.appLauncherVisible ? 6 : -(height + 8))

                Behavior on x {
                    enabled: launcherPanel.isLeft
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Behavior on y {
                    enabled: !launcherPanel.isLeft
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                AppLauncher {
                    anchors.fill: parent
                    isVisible: shellRoot.appLauncherVisible
                    opacity: shellRoot.appLauncherVisible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }

                    onRequestClose: {
                        shellRoot.appLauncherVisible = false
                    }

                    onOpenSettings: {
                        shellRoot.appLauncherVisible = false
                        shellRoot.settingsVisible = true
                    }
                }
            }
        }
    }
    
    // Power Menu popup - anchored below power button (top right)
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.powerMenuVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside power menu")
                    shellRoot.powerMenuVisible = false
                }
                propagateComposedEvents: true
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 586
                height: 120
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.powerMenuVisible ? 0 : -400
                z: 1  // Ensure menu is above background
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                // Stop background clicks from closing menu
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Absorb clicks on the menu panel itself
                    }
                    propagateComposedEvents: true
                }
                
                PowerMenu {
                    id: powerMenu
                    anchors.fill: parent
                    isVisible: shellRoot.powerMenuVisible
                    opacity: shellRoot.powerMenuVisible ? 1 : 0
                    z: 2  // Ensure PowerMenu is above the absorbing MouseArea
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("PowerMenu requested close")
                        shellRoot.powerMenuVisible = false
                    }
                }
            }
        }
    }
    
    // Clipboard Manager Panel
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.clipboardVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside clipboard panel")
                    shellRoot.clipboardVisible = false
                }
                propagateComposedEvents: true
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 500
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.clipboardVisible ? 0 : -800
                z: 1  // Ensure panel is above background
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                // Stop background clicks from closing panel
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Absorb clicks on the panel itself
                    }
                    propagateComposedEvents: true
                }
                
                ClipboardPanel {
                    id: clipboardPanel
                    anchors.fill: parent
                    isVisible: shellRoot.clipboardVisible
                    opacity: shellRoot.clipboardVisible ? 1 : 0
                    z: 2  // Ensure ClipboardPanel is above the absorbing MouseArea
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("ClipboardPanel requested close")
                        shellRoot.clipboardVisible = false
                    }
                }
            }
        }
    }
    
    // Control Center Panel
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            visible: shellRoot.controlCenterVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside control center panel")
                    shellRoot.controlCenterVisible = false
                }
                
                // Prevent clicks from reaching the background
                propagateComposedEvents: false
            }
            
            // Panel positioned at top-right, slides in from right
            Item {
                width: 420
                height: 820
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 6
                anchors.rightMargin: shellRoot.controlCenterVisible ? 6 : -(420 + 12)
                
                Behavior on anchors.rightMargin {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                ControlCenter {
                    id: controlCenterPanel
                    anchors.fill: parent
                    isVisible: shellRoot.controlCenterVisible
                    opacity: shellRoot.controlCenterVisible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("ControlCenter requested close")
                        shellRoot.controlCenterVisible = false
                    }
                }
            }
        }
    }
    
    // Theme Switcher widget
    ThemeSwitcher {
        id: themeSwitcherWidget
        isVisible: shellRoot.themeSwitcherVisible
    }
    
    // Settings Widget
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.settingsVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    shellRoot.settingsVisible = false
                }
                propagateComposedEvents: false
            }
            
            SettingsWidget {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.settingsVisible ? 0 : 800

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }
                
                isVisible: shellRoot.settingsVisible
                
                onCloseRequested: {
                    shellRoot.settingsVisible = false
                }
                
                onSettingsUpdated: {
                    console.log("Settings changed, notifying widgets...")
                    // Immediately reload bar state so style/position changes apply at once
                    // instead of waiting up to 1 second for the polling timers.
                    shellBarSettingsLoader.running = true
                    barPositionLoader.running = true
                    singleBar.reloadBarSettings()
                }
            }
        }
    }
    
    // Screenshot widget
    Variants {
        model: Quickshell.screens
        
        ScreenshotWidget {
            property var modelData
            screen_: modelData
            visible: shellRoot.screenshotVisible
            
            onCloseRequested: {
                shellRoot.screenshotVisible = false
            }
        }
    }

    QtObject {
        id: barSurfaceState
        property bool barAtBottom: false
        property bool barAutoHide: false
        property bool barHovered: false
        property bool barFloating: false
        property string barSize: "small"
        property string barStyle: "single"
    }

    Process {
        id: barPositionLoader
        running: true
        command: ["sh", "-c", "cat ~/.config/quickshell/settings.json 2>/dev/null || echo '{}' "]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                barPositionLoader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.bar) {
                        if (settings.bar.position) {
                            barSurfaceState.barAtBottom = settings.bar.position === "bottom"
                        }
                        if (settings.bar.autoHide !== undefined) {
                            barSurfaceState.barAutoHide = settings.bar.autoHide
                        }
                        if (settings.bar.floating !== undefined) {
                            barSurfaceState.barFloating = settings.bar.floating
                        }
                        if (settings.bar.barSize !== undefined) {
                            barSurfaceState.barSize = settings.bar.barSize
                            ThemeManager.barLarge = (settings.bar.barSize === "large")
                        }
                        if (settings.bar.barStyle !== undefined) {
                            barSurfaceState.barStyle = settings.bar.barStyle
                        }
                    }
                    if (settings.general !== undefined) {
                        const transparent = settings.general.widgetTransparent !== false
                        ThemeManager.widgetOpacity = transparent ? 0.75 : 1.0
                        if (settings.general.uiFont !== undefined && settings.general.uiFont.length > 0) {
                            ThemeManager.uiFont = settings.general.uiFont
                        }
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: barPositionLoader.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-bar"

            visible: true

            anchors {
                top: !barSurfaceState.barAtBottom
                bottom: barSurfaceState.barAtBottom
                left: true
                right: true
            }

            implicitHeight: barSurfaceState.barSize === "large" ? 53 : 42
            color: "transparent"

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barStyle !== "islands" && barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? 8 : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barStyle !== "islands" && barSurfaceState.barFloating && barSurfaceState.barAtBottom ? 8 : 0)
                left: barSurfaceState.barStyle !== "islands" && barSurfaceState.barFloating ? 8 : 0
                right: barSurfaceState.barStyle !== "islands" && barSurfaceState.barFloating ? 8 : 0
            }

            Behavior on margins.top { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.bottom { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.left { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.right { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            exclusiveZone: barSurfaceState.barAutoHide ? 0 : (barSurfaceState.barStyle === "islands" ? (implicitHeight + (barSurfaceState.barFloating ? 8 : 0)) : height)

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: barSurfaceState.barAtBottom ? 0 : -10
                anchors.bottomMargin: barSurfaceState.barAtBottom ? -10 : 0
                hoverEnabled: true
                propagateComposedEvents: true
                enabled: barSurfaceState.barAutoHide && barSurfaceState.barStyle !== "islands"
                z: 100

                onEntered: barSurfaceState.barHovered = true
                onExited: barSurfaceState.barHovered = false
                onClicked: function(mouse) { mouse.accepted = false }
            }

            Bar {
                id: singleBar
                anchors.fill: parent
                section: "full"

                Connections {
                    target: singleBar.clockComponent
                    function onToggleCalendar() {
                        shellRoot.calendarVisible = !shellRoot.calendarVisible
                    }
                }

                Connections {
                    target: singleBar.archComponent
                    function onToggleLauncher() {
                        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                    }
                }

                Connections {
                    target: singleBar
                    function onToggleClipboard() {
                        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                    }
                }

                Connections {
                    target: singleBar
                    function onToggleControlCenter() {
                        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
                    }
                }

                Connections {
                    target: singleBar
                    function onToggleSettings() {
                        shellRoot.settingsVisible = !shellRoot.settingsVisible
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-bar-left"

            visible: barSurfaceState.barStyle === "islands"

            anchors {
                top: !barSurfaceState.barAtBottom
                bottom: barSurfaceState.barAtBottom
                left: true
            }

            implicitWidth: leftIslandBar.implicitWidth
            implicitHeight: barSurfaceState.barSize === "large" ? 53 : 42
            color: "transparent"
            // Left island claims exclusive zone; its anchor config (top+left only) is
            // insufficient for layer-shell exclusive zones — the single bar handles that.
            exclusiveZone: 0

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? -implicitHeight : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? -implicitHeight : 0)
                left: barSurfaceState.barFloating ? 8 : 0
            }

            Behavior on margins.top { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.bottom { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.left { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Bar {
                id: leftIslandBar
                anchors.fill: parent
                section: "left"
                barStyle: "islands"
                layoutPreset: shellRoot.barLayoutPreset
                showQuickLaunch: shellRoot.barShowQuickLaunch
                showSystemTray: shellRoot.barShowSystemTray
                minWorkspaces: shellRoot.barMinWorkspaces
                backgroundStyle: shellRoot.barBackgroundStyle
                showBorder: shellRoot.barShowBorder
                floating: shellRoot.barFloating
                barOpacity: shellRoot.barOpacity
                widgetBorderWidth: shellRoot.barWidgetBorderWidth
                hyprRounding: shellRoot.barHyprRounding

                Connections {
                    target: leftIslandBar.archComponent
                    function onToggleLauncher() {
                        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                    }
                }

                Connections {
                    target: leftIslandBar
                    function onToggleSettings() {
                        shellRoot.settingsVisible = !shellRoot.settingsVisible
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-bar-center"

            visible: barSurfaceState.barStyle === "islands"

            anchors {
                top: !barSurfaceState.barAtBottom
                bottom: barSurfaceState.barAtBottom
                left: true
            }

            implicitWidth: centerIslandBar.implicitWidth
            implicitHeight: barSurfaceState.barSize === "large" ? 53 : 42
            color: "transparent"
            exclusiveZone: 0

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? -implicitHeight : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? -implicitHeight : 0)
                left: Math.max(0, Math.round((screen.width - implicitWidth) / 2))
            }

            Behavior on margins.top { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.bottom { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.left { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Bar {
                id: centerIslandBar
                anchors.fill: parent
                section: "center"
                barStyle: "islands"
                layoutPreset: shellRoot.barLayoutPreset
                showQuickLaunch: shellRoot.barShowQuickLaunch
                showSystemTray: shellRoot.barShowSystemTray
                minWorkspaces: shellRoot.barMinWorkspaces
                backgroundStyle: shellRoot.barBackgroundStyle
                showBorder: shellRoot.barShowBorder
                floating: shellRoot.barFloating
                barOpacity: shellRoot.barOpacity
                widgetBorderWidth: shellRoot.barWidgetBorderWidth
                hyprRounding: shellRoot.barHyprRounding

                Connections {
                    target: centerIslandBar.clockComponent
                    function onToggleCalendar() {
                        shellRoot.calendarVisible = !shellRoot.calendarVisible
                    }
                }

                Connections {
                    target: centerIslandBar.archComponent
                    function onToggleLauncher() {
                        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-bar-right"

            visible: barSurfaceState.barStyle === "islands"

            anchors {
                top: !barSurfaceState.barAtBottom
                bottom: barSurfaceState.barAtBottom
                right: true
            }

            implicitWidth: rightIslandBar.implicitWidth
            implicitHeight: barSurfaceState.barSize === "large" ? 53 : 42
            color: "transparent"
            exclusiveZone: 0

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? -implicitHeight : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? -implicitHeight : 0)
                right: barSurfaceState.barFloating ? 8 : 0
            }

            Behavior on margins.top { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.bottom { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.right { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Bar {
                id: rightIslandBar
                anchors.fill: parent
                section: "right"
                barStyle: "islands"
                layoutPreset: shellRoot.barLayoutPreset
                showQuickLaunch: shellRoot.barShowQuickLaunch
                showSystemTray: shellRoot.barShowSystemTray
                minWorkspaces: shellRoot.barMinWorkspaces
                backgroundStyle: shellRoot.barBackgroundStyle
                showBorder: shellRoot.barShowBorder
                floating: shellRoot.barFloating
                barOpacity: shellRoot.barOpacity
                widgetBorderWidth: shellRoot.barWidgetBorderWidth
                hyprRounding: shellRoot.barHyprRounding

                Connections {
                    target: rightIslandBar.clockComponent
                    function onToggleCalendar() {
                        shellRoot.calendarVisible = !shellRoot.calendarVisible
                    }
                }

                Connections {
                    target: rightIslandBar
                    function onToggleClipboard() {
                        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                    }
                }

                Connections {
                    target: rightIslandBar
                    function onToggleControlCenter() {
                        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
                    }
                }

                Connections {
                    target: rightIslandBar
                    function onToggleSettings() {
                        shellRoot.settingsVisible = !shellRoot.settingsVisible
                    }
                }
            }
        }
    }

}
