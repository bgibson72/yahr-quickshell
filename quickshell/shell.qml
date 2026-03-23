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
    
    // Make shellRoot globally accessible via objectName
    objectName: "shellRoot"
    
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
                width: 800
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: shellRoot.calendarVisible ? 6 : -700
                
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
            
            // Panel positioned at center, slides down from top
            Item {
                width: 1000
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.appLauncherVisible ? 0 : -800

                Behavior on anchors.verticalCenterOffset {
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
            
            // Panel positioned at top-right, slides down from top
            Item {
                width: 420
                height: 820
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: shellRoot.controlCenterVisible ? 6 : -860
                anchors.rightMargin: 6
                
                Behavior on anchors.topMargin {
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
            }
            
            margins {
                top: (screen.height - 600) / 2
                left: (screen.width - 800) / 2
            }
            
            implicitWidth: 800
            implicitHeight: 600
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            SettingsWidget {
                anchors.centerIn: parent
                isVisible: shellRoot.settingsVisible
                
                onCloseRequested: {
                    shellRoot.settingsVisible = false
                }
                
                onSettingsUpdated: {
                    console.log("Settings changed, notifying widgets...")
                    // The calendar widget will reload settings on next timer tick
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
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            property bool barAtBottom: false
            property bool barAutoHide: false
            property bool barHovered: false
            property bool barFloating: false
            
            // Load bar position and auto-hide settings
            Process {
                id: barPositionLoader
                running: true
                command: ["sh", "-c", "cat ~/.config/quickshell/settings.json 2>/dev/null || echo '{}'"]
                
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
                                    barAtBottom = settings.bar.position === "bottom"
                                }
                                if (settings.bar.autoHide !== undefined) {
                                    barAutoHide = settings.bar.autoHide
                                }
                                if (settings.bar.floating !== undefined) {
                                    barFloating = settings.bar.floating
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
            
            anchors {
                top: !barAtBottom
                bottom: barAtBottom
                left: true
                right: true
            }
            
            implicitHeight: 42
            color: "transparent"
            
            margins {
                top: barAutoHide && !barHovered ? (barAtBottom ? 0 : -implicitHeight) : (barFloating && !barAtBottom ? 8 : 0)
                bottom: barAutoHide && !barHovered ? (barAtBottom ? -implicitHeight : 0) : (barFloating && barAtBottom ? 8 : 0)
                left: barFloating ? 8 : 0
                right: barFloating ? 8 : 0
            }

            Behavior on margins.top {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.bottom {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.left {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.right {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            // Explicitly enable interaction
            visible: true
            exclusiveZone: barAutoHide ? 0 : height
            
            // Mouse detection area for auto-hide
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: barAtBottom ? 0 : -10
                anchors.bottomMargin: barAtBottom ? -10 : 0
                hoverEnabled: true
                propagateComposedEvents: true
                enabled: barAutoHide
                z: 100
                
                onEntered: barHovered = true
                onExited: barHovered = false
                onClicked: function(mouse) { mouse.accepted = false }
            }
            
            Bar {
                id: bar
                anchors.fill: parent
                
                // Connect clock toggle signal to shellRoot
                Connections {
                    target: bar.clockComponent
                    function onToggleCalendar() {
                        shellRoot.calendarVisible = !shellRoot.calendarVisible
                        console.log("Calendar toggled via Connections:", shellRoot.calendarVisible)
                    }
                }
                
                // Connect launcher toggle signal (Arch button)
                Connections {
                    target: bar.archComponent
                    function onToggleLauncher() {
                        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                        console.log("AppLauncher toggled:", shellRoot.appLauncherVisible)
                    }
                }
                
                // Connect power menu toggle signal
                Connections {
                    target: bar.powerComponent
                    function onTogglePowerMenu() {
                        shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
                        console.log("PowerMenu toggled:", shellRoot.powerMenuVisible)
                    }
                }
                
                // Connect settings button click signal
                Connections {
                    target: bar.settingsButtonComponent
                    function onClicked() {
                        shellRoot.settingsVisible = !shellRoot.settingsVisible
                        console.log("Settings toggled:", shellRoot.settingsVisible)
                    }
                }
                
                // Connect clipboard toggle signal
                Connections {
                    target: bar
                    function onToggleClipboard() {
                        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                        console.log("Clipboard toggled:", shellRoot.clipboardVisible)
                    }
                }
                
                // Connect control center toggle signal
                Connections {
                    target: bar
                    function onToggleControlCenter() {
                        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
                        console.log("ControlCenter toggled:", shellRoot.controlCenterVisible)
                    }
                }
            }
        }
    }
}
