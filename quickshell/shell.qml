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
    property bool trashVisible: false
    property var wallpaperPicker: wallpaperPickerWindow
    property bool barAtBottom: false
    property bool barAutoHide: false
    property bool barFloating: false
    property string barSize: "small"
    property string barStyle: "single"
    property string barLayoutPreset: "default"
    property bool barShowQuickLaunch: true
    property bool barShowSystemTray: true
    property bool barShowMediaPlayer: true
    property bool barShowBorder: false
    property string barBackgroundStyle: "opaque"
    property real barOpacity: 0.70
    property int barWidgetBorderWidth: 1
    property int barHyprRounding: 12
    property int barMinWorkspaces: 4

    // ---- Dock ----
    property bool dockEnabled: true
    property string dockPosition: "bottom"     // "top" | "bottom" | "left" | "right"
    property string dockAlignment: "center"    // "start" | "center" | "end"
    property bool dockFloating: true
    property string dockBackgroundStyle: "translucent"
    property real dockOpacity: 0.70
    property bool dockShowBorder: false
    property int dockIconSize: 48
    property bool dockSpanFullWidth: false
    property var dockPinnedApps: []
    property bool dockPickerVisible: false
    property string dockBehavior: "always-on-top"  // "always-on-top" | "behind-windows" | "dodge" | "auto-hide"
    property bool dockHovered: false
    // Timestamp (Date.now()) at which the dock should auto-hide again after
    // the cursor moves away; 0 means no hide is scheduled. Using a plain
    // property + timestamp (checked each poll) instead of a shared Timer id,
    // since Timer ids declared at shellRoot scope are not reliably reachable
    // via shellRoot.<id> from inside Variants-generated PanelWindow instances
    // (confirmed via a runtime TypeError: "Cannot read property of undefined").
    property real dockHideAt: 0

    // Persist the dock's pinned-apps list to settings.json without clobbering
    // other settings keys — reads the file fresh, merges, writes it back.
    // dockPinnedSaveGuardUntil suppresses the periodic settings poll (below)
    // from re-reading and overwriting dockPinnedApps with a stale on-disk
    // value while this async write is still in flight — otherwise a newly
    // pinned/unpinned app can visibly flash and then revert.
    property real dockPinnedSaveGuardUntil: 0

    function saveDockPinned(newPinnedArray) {
        shellRoot.dockPinnedApps = newPinnedArray
        shellRoot.dockPinnedSaveGuardUntil = Date.now() + 2000
        // Base64-encode the JSON payload to sidestep shell quoting/heredoc
        // fragility entirely (app names/paths can contain quotes, and a
        // heredoc-based approach was found to silently fail when embedded
        // inside a larger `sh -c "..."` invocation via execDetached).
        const json = JSON.stringify(newPinnedArray)
        const base64Json = Qt.btoa(json)
        const mergeCmd = "python3 -c \"import json,base64; p='" +
            Quickshell.env('HOME') + "/.config/quickshell/settings.json'; " +
            "d=json.load(open(p)); " +
            "d.setdefault('dock',{})['pinned']=json.loads(base64.b64decode('" + base64Json + "').decode()); " +
            "json.dump(d,open(p,'w'),indent=2)\""
        Quickshell.execDetached(["sh", "-c", mergeCmd])
    }

    function launchDockApp(execCmd, needsTerminal) {
        if (needsTerminal)
            Quickshell.execDetached(["kitty", "-e", "sh", "-c", execCmd])
        else
            Quickshell.execDetached(["sh", "-c", execCmd])
    }

    
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
                        if (settings.bar.barStyle !== undefined) {
                            shellRoot.barStyle = settings.bar.barStyle
                            barSurfaceState.barStyle = settings.bar.barStyle
                            try { singleBar.barStyle = settings.bar.barStyle } catch(e) {}
                        }
                        if (settings.bar.layoutPreset !== undefined) shellRoot.barLayoutPreset = settings.bar.layoutPreset
                        if (settings.bar.showQuickLaunch !== undefined) shellRoot.barShowQuickLaunch = settings.bar.showQuickLaunch
                        if (settings.bar.showSystemTray !== undefined) shellRoot.barShowSystemTray = settings.bar.showSystemTray
                        if (settings.bar.showMediaPlayer !== undefined) shellRoot.barShowMediaPlayer = settings.bar.showMediaPlayer
                        if (settings.bar.minWorkspaces !== undefined) shellRoot.barMinWorkspaces = settings.bar.minWorkspaces
                        if (settings.bar.showBorder !== undefined) shellRoot.barShowBorder = settings.bar.showBorder
                        if (settings.bar.backgroundStyle !== undefined) shellRoot.barBackgroundStyle = settings.bar.backgroundStyle
                        if (settings.bar.barOpacity !== undefined) shellRoot.barOpacity = settings.bar.barOpacity
                    }
                    if (settings.dock) {
                        if (settings.dock.enabled !== undefined) shellRoot.dockEnabled = settings.dock.enabled
                        if (settings.dock.position !== undefined) shellRoot.dockPosition = settings.dock.position
                        if (settings.dock.alignment !== undefined) shellRoot.dockAlignment = settings.dock.alignment
                        if (settings.dock.floating !== undefined) shellRoot.dockFloating = settings.dock.floating
                        if (settings.dock.backgroundStyle !== undefined) shellRoot.dockBackgroundStyle = settings.dock.backgroundStyle
                        if (settings.dock.opacity !== undefined) shellRoot.dockOpacity = settings.dock.opacity
                        if (settings.dock.showBorder !== undefined) shellRoot.dockShowBorder = settings.dock.showBorder
                        if (settings.dock.iconSize !== undefined) shellRoot.dockIconSize = settings.dock.iconSize
                        if (settings.dock.spanFullWidth !== undefined) shellRoot.dockSpanFullWidth = settings.dock.spanFullWidth
                        if (settings.dock.pinned !== undefined && Date.now() >= shellRoot.dockPinnedSaveGuardUntil) {
                            shellRoot.dockPinnedApps = settings.dock.pinned
                        }
                        if (settings.dock.behavior !== undefined) shellRoot.dockBehavior = settings.dock.behavior
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
    
    // Trash Panel
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            visible: shellRoot.trashVisible

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
                onClicked: shellRoot.trashVisible = false
                propagateComposedEvents: true
            }

            // Panel positioned at center, slides down from top
            Item {
                width: 480
                height: 620
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.trashVisible ? 0 : -800
                z: 1

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                // Stop background clicks from closing panel
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                    propagateComposedEvents: true
                }

                TrashWidget {
                    id: trashPanel
                    anchors.fill: parent
                    isVisible: shellRoot.trashVisible
                    opacity: shellRoot.trashVisible ? 1 : 0
                    z: 2

                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }

                    onRequestClose: shellRoot.trashVisible = false
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
                height: 740
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
            // -1 = anchor to full screen geometry, not usable area.
            // The singleBar (transparent, full-width) holds the exclusive zone so windows
            // don't overlap; islands just float at y=0 via full-screen anchoring.
            exclusiveZone: -1

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? 8 : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? 8 : 0)
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
            exclusiveZone: -1

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? 8 : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? 8 : 0)
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
                showMediaPlayer: shellRoot.barShowMediaPlayer
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
            exclusiveZone: -1

            margins {
                top: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? 0 : implicitHeight * -1) : (barSurfaceState.barFloating && !barSurfaceState.barAtBottom ? 8 : 0)
                bottom: barSurfaceState.barAutoHide && !barSurfaceState.barHovered ? (barSurfaceState.barAtBottom ? implicitHeight * -1 : 0) : (barSurfaceState.barFloating && barSurfaceState.barAtBottom ? 8 : 0)
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
                showMediaPlayer: shellRoot.barShowMediaPlayer
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

    // ---- Dock ----
    // A single dynamically-anchored PanelWindow so the dock can be moved to
    // any screen edge (position) and aligned start/center/end along that
    // edge, without needing four separate Variants blocks like the bars.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-dock"
            WlrLayershell.layer: shellRoot.dockBehavior === "behind-windows" ? WlrLayer.Bottom
                : (shellRoot.dockBehavior === "auto-hide" ? WlrLayer.Overlay : WlrLayer.Top)

            visible: shellRoot.dockEnabled

            readonly property bool isHorizontal: shellRoot.dockPosition === "top" || shellRoot.dockPosition === "bottom"
            readonly property bool autoHideActive: shellRoot.dockBehavior === "auto-hide" && !shellRoot.dockHovered
            // How far to push the dock off-screen when auto-hidden — its own
            // thickness plus a bit extra so no sliver remains visible.
            readonly property int hideOffset: autoHideActive ? -((isHorizontal ? implicitHeight : implicitWidth) + 20) : 0
            // wlr-layer-shell only honors exclusiveZone (reserving screen space)
            // when a surface spans the FULL length of the edge it's anchored to
            // — a corner-anchored, content-sized window (used for visual
            // centering in other modes) is ignored for reserved-area purposes.
            // So "dodge" mode spans the full edge here; Dock.qml handles the
            // start/center/end alignment of its content internally instead.
            // The window spans the full edge either because "dodge" mode
            // requires it (wlr-layer-shell only honors exclusiveZone for
            // full-edge-spanning surfaces) or because the user explicitly
            // wants a taskbar-style full-width/height dock (spanFullWidth).
            // Dock.qml's content still aligns per `alignment` internally in
            // both cases; only its background chrome also spans when
            // spanFullWidth is on (see Dock.qml).
            readonly property bool windowSpansFull: shellRoot.dockBehavior === "dodge" || shellRoot.dockSpanFullWidth

            anchors {
                top: shellRoot.dockPosition === "top" || (!isHorizontal && (shellRoot.dockAlignment === "start" || windowSpansFull))
                bottom: shellRoot.dockPosition === "bottom" || (!isHorizontal && (shellRoot.dockAlignment === "end" || windowSpansFull))
                left: shellRoot.dockPosition === "left" || (isHorizontal && (shellRoot.dockAlignment !== "end" || windowSpansFull))
                right: shellRoot.dockPosition === "right" || (isHorizontal && (shellRoot.dockAlignment === "end" || windowSpansFull))
            }

            implicitWidth: isHorizontal ? (windowSpansFull ? screen.width : dockContent.implicitWidth) : (shellRoot.dockIconSize + 20)
            implicitHeight: isHorizontal ? (shellRoot.dockIconSize + 20) : (windowSpansFull ? screen.height : dockContent.implicitHeight)
            color: "transparent"
            // Only "dodge" mode reserves screen space (shrinking/pushing windows
            // away from the dock). All other modes overlay windows (either above
            // or below them, per the layer setting) without reserving space.
            // The floating gap (8px) matches the Bar's own floating gap exactly
            // (see barSurfaceState's PanelWindow margins/exclusiveZone above) so
            // the dodge reserved-space gap, the dock's floating inset, and the
            // bar's floating inset are all visually identical.
            exclusiveZone: shellRoot.dockBehavior === "dodge"
                ? (isHorizontal ? implicitHeight : implicitWidth) + (shellRoot.dockFloating ? 8 : 0)
                : 0

            margins {
                // Perpendicular-axis alignment (start/center/end) along the docked
                // edge. Not applied when the window spans the full edge — Dock.qml
                // aligns its content internally in that case. The floating gap on
                // the dock's own docked edge still applies even when spanning, so
                // a floating full-width/height dock is still visibly inset from
                // the screen edge rather than flush against it.
                left: (windowSpansFull ? (shellRoot.dockPosition === "left" && shellRoot.dockFloating ? 8 : 0) : (shellRoot.dockPosition === "left"
                    ? (shellRoot.dockFloating ? 8 : 0)
                    : (isHorizontal && shellRoot.dockAlignment === "center"
                        ? Math.max(0, Math.round((screen.width - implicitWidth) / 2))
                        : (isHorizontal && shellRoot.dockAlignment === "start" ? (shellRoot.dockFloating ? 8 : 0) : 0))))
                    + (shellRoot.dockPosition === "left" ? hideOffset : 0)
                right: (windowSpansFull ? (shellRoot.dockPosition === "right" && shellRoot.dockFloating ? 8 : 0) : (shellRoot.dockPosition === "right"
                    ? (shellRoot.dockFloating ? 8 : 0)
                    : (isHorizontal && shellRoot.dockAlignment === "end" ? (shellRoot.dockFloating ? 8 : 0) : 0)))
                    + (shellRoot.dockPosition === "right" ? hideOffset : 0)
                top: (windowSpansFull ? (shellRoot.dockPosition === "top" && shellRoot.dockFloating ? 8 : 0) : (shellRoot.dockPosition === "top"
                    ? (shellRoot.dockFloating ? 8 : 0)
                    : (!isHorizontal && shellRoot.dockAlignment === "center"
                        ? Math.max(0, Math.round((screen.height - implicitHeight) / 2))
                        : (!isHorizontal && shellRoot.dockAlignment === "start" ? (shellRoot.dockFloating ? 8 : 0) : 0))))
                    + (shellRoot.dockPosition === "top" ? hideOffset : 0)
                bottom: (windowSpansFull ? (shellRoot.dockPosition === "bottom" && shellRoot.dockFloating ? 8 : 0) : (shellRoot.dockPosition === "bottom"
                    ? (shellRoot.dockFloating ? 8 : 0)
                    : (!isHorizontal && shellRoot.dockAlignment === "end" ? (shellRoot.dockFloating ? 8 : 0) : 0)))
                    + (shellRoot.dockPosition === "bottom" ? hideOffset : 0)
            }

            Behavior on margins.left { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.right { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.top { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on margins.bottom { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Dock {
                id: dockContent
                anchors.fill: parent
                position: shellRoot.dockPosition
                alignment: shellRoot.dockAlignment
                floating: shellRoot.dockFloating
                backgroundStyle: shellRoot.dockBackgroundStyle
                dockOpacity: shellRoot.dockOpacity
                showBorder: shellRoot.dockShowBorder
                iconSize: shellRoot.dockIconSize
                spanFullWidth: shellRoot.dockSpanFullWidth
                pinnedApps: shellRoot.dockPinnedApps

                onLaunchRequested: (execCmd, needsTerminal) => shellRoot.launchDockApp(execCmd, needsTerminal)
                onUnpinRequested: (desktopId) => {
                    const updated = shellRoot.dockPinnedApps.filter(a => a.desktopId !== desktopId)
                    shellRoot.saveDockPinned(updated)
                }
                onPinPickerRequested: shellRoot.dockPickerVisible = true
                onSettingsRequested: shellRoot.settingsVisible = !shellRoot.settingsVisible
                onTrashRequested: shellRoot.trashVisible = !shellRoot.trashVisible
            }

            // Auto-hide reveal detection via polling the compositor's actual
            // cursor position (hyprctl cursorpos) rather than relying on
            // Wayland layer-shell surface hover events. This sidesteps any
            // input-region/z-order edge cases with a paper-thin always-on-top
            // reveal strip and reliably detects proximity to the dock's edge
            // even while it's fully off-screen and other windows are focused.
            Process {
                id: cursorPosChecker
                running: false
                command: ["hyprctl", "cursorpos", "-j"]
                property string buffer: ""
                stdout: SplitParser {
                    onRead: data => { cursorPosChecker.buffer += data }
                }
                onRunningChanged: {
                    if (!running && buffer !== "") {
                        try {
                            const pos = JSON.parse(buffer)
                            const thickness = (shellRoot.dockIconSize + 20)
                            const revealThreshold = 20
                            const hideThreshold = thickness + 40
                            let distanceFromEdge
                            switch (shellRoot.dockPosition) {
                                case "top": distanceFromEdge = pos.y; break
                                case "bottom": distanceFromEdge = screen.height - pos.y; break
                                case "left": distanceFromEdge = pos.x; break
                                case "right": distanceFromEdge = screen.width - pos.x; break
                                default: distanceFromEdge = 9999
                            }
                            if (distanceFromEdge <= revealThreshold) {
                                // Close/approaching — reveal immediately and
                                // cancel any pending hide.
                                shellRoot.dockHideAt = 0
                                shellRoot.dockHovered = true
                            } else if (shellRoot.dockHovered && distanceFromEdge > hideThreshold) {
                                // Far enough away — schedule a debounced hide
                                // (only once; don't keep pushing it back).
                                if (shellRoot.dockHideAt === 0) {
                                    shellRoot.dockHideAt = Date.now() + 400
                                }
                            } else if (distanceFromEdge <= hideThreshold) {
                                // Still within the dock's own footprint — stay revealed.
                                shellRoot.dockHideAt = 0
                            }
                            if (shellRoot.dockHideAt !== 0 && Date.now() >= shellRoot.dockHideAt) {
                                shellRoot.dockHovered = false
                                shellRoot.dockHideAt = 0
                            }
                        } catch (e) {}
                        buffer = ""
                    } else if (running) {
                        buffer = ""
                    }
                }
            }

            Timer {
                interval: 150
                running: shellRoot.dockBehavior === "auto-hide" && shellRoot.dockEnabled
                repeat: true
                onTriggered: cursorPosChecker.running = true
            }
        }
    }

    // Dock app picker popup
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.namespace: "yahr-dock-picker"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            visible: shellRoot.dockPickerVisible

            anchors { top: true; bottom: true; left: true; right: true }
            margins { top: 0; bottom: 0; left: 0; right: 0 }
            color: "transparent"
            exclusiveZone: 0

            MouseArea {
                anchors.fill: parent
                onClicked: shellRoot.dockPickerVisible = false
            }

            // Panel positioned at center, slides down from top (matches
            // ClipboardPanel/TrashWidget's open animation).
            Item {
                width: 360
                height: 440
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.dockPickerVisible ? 0 : -800
                z: 1

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                // Stop background clicks from closing the picker
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                    propagateComposedEvents: true
                }

                DockAppPicker {
                    anchors.fill: parent
                    pinnedIds: shellRoot.dockPinnedApps.map(a => a.desktopId)
                    opacity: shellRoot.dockPickerVisible ? 1 : 0
                    z: 2

                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }

                    onRequestClose: shellRoot.dockPickerVisible = false
                    onAppSelected: (desktopId, name, icon, exec, terminal) => {
                        const updated = shellRoot.dockPinnedApps.concat([{
                            desktopId: desktopId, name: name, icon: icon, exec: exec, terminal: terminal
                        }])
                        shellRoot.saveDockPinned(updated)
                        shellRoot.dockPickerVisible = false
                    }
                }
            }
        }
    }

}
