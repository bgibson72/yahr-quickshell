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
    
    // File-based IPC watcher for theme switcher keybind
    Process {
        id: themeSwitcherWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-themeswitcher.sock ]; then echo toggle; while [ -f /tmp/quickshell-themeswitcher.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.themeSwitcherVisible = !shellRoot.themeSwitcherVisible
                    console.log("Theme switcher toggled via keybind:", shellRoot.themeSwitcherVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for app launcher keybind
    Process {
        id: appLauncherWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-applauncher.sock ]; then echo toggle; while [ -f /tmp/quickshell-applauncher.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                    console.log("App launcher toggled via keybind:", shellRoot.appLauncherVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for calendar keybind
    Process {
        id: calendarWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-calendar.sock ]; then echo toggle; while [ -f /tmp/quickshell-calendar.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.calendarVisible = !shellRoot.calendarVisible
                    console.log("Calendar toggled via keybind:", shellRoot.calendarVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for power menu keybind
    Process {
        id: powerMenuWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-powermenu.sock ]; then echo toggle; while [ -f /tmp/quickshell-powermenu.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
                    console.log("Power menu toggled via keybind:", shellRoot.powerMenuVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for screenshot widget keybind
    Process {
        id: screenshotWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-screenshot.sock ]; then echo toggle; while [ -f /tmp/quickshell-screenshot.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.screenshotVisible = !shellRoot.screenshotVisible
                    console.log("Screenshot widget toggled via keybind:", shellRoot.screenshotVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for settings widget keybind
    Process {
        id: settingsWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-settings.sock ]; then echo toggle; while [ -f /tmp/quickshell-settings.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.settingsVisible = !shellRoot.settingsVisible
                    console.log("Settings widget toggled via keybind:", shellRoot.settingsVisible)
                }
            }
        }
    }
    
    // File-based IPC watcher for clipboard keybind
    Process {
        id: clipboardWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-clipboard.sock ]; then echo toggle; while [ -f /tmp/quickshell-clipboard.sock ]; do sleep 0.05; done; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                    console.log("Clipboard toggled via keybind:", shellRoot.clipboardVisible)
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
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
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
                propagateComposedEvents: false
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 586
                height: 120
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.powerMenuVisible ? 0 : -400
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                PowerMenu {
                    id: powerMenu
                    anchors.fill: parent
                    isVisible: shellRoot.powerMenuVisible
                    opacity: shellRoot.powerMenuVisible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("PowerMenu requested close")
                        shellRoot.powerMenuVisible = false
                    }
                    
                    // Stop clicks from reaching the background MouseArea
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {}
                        propagateComposedEvents: false
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
                
                // Prevent clicks from reaching the background
                propagateComposedEvents: false
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 500
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.clipboardVisible ? 0 : -800
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                ClipboardPanel {
                    id: clipboardPanel
                    anchors.fill: parent
                    isVisible: shellRoot.clipboardVisible
                    opacity: shellRoot.clipboardVisible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("ClipboardPanel requested close")
                        shellRoot.clipboardVisible = false
                    }
                    
                    // Stop clicks from reaching the background MouseArea
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {}  // Absorb clicks
                        propagateComposedEvents: false
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
                height: 540
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: shellRoot.controlCenterVisible ? 6 : -600
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
            
            // Load bar position setting
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
                            if (settings.bar && settings.bar.position) {
                                barAtBottom = settings.bar.position === "bottom"
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
                top: 0
                bottom: 0
                left: 0
                right: 0
            }
            
            // Explicitly enable interaction
            visible: true
            exclusiveZone: height
            
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
