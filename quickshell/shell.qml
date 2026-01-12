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
            }
            
            margins {
                top: 42
                left: modelData.width / 2 - 270
            }
            
            implicitWidth: 540
            implicitHeight: 432
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            
            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            CalendarWidget {
                anchors.fill: parent
                isVisible: shellRoot.calendarVisible
                
                onRequestClose: {
                    shellRoot.calendarVisible = false
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
            }
            
            margins {
                top: modelData.height / 2 - 300
                left: modelData.width / 2 - 500
            }
            
            implicitWidth: 1000
            implicitHeight: shellRoot.appLauncherVisible ? 600 : 0
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            AppLauncher {
                anchors.fill: parent
                isVisible: shellRoot.appLauncherVisible
                
                onRequestClose: {
                    shellRoot.appLauncherVisible = false
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
            }
            
            margins {
                top: (modelData.height - 120) / 2
                left: (modelData.width - 586) / 2
            }
            
            implicitWidth: 586
            implicitHeight: 120
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            // Force close if the widget requests it but window is stuck open
            Timer {
                interval: 200
                running: !shellRoot.powerMenuVisible && visible
                onTriggered: {
                    console.log("Force closing stuck PowerMenu window")
                    shellRoot.powerMenuVisible = false
                }
            }
            
            PowerMenu {
                id: powerMenu
                anchors.fill: parent
                isVisible: shellRoot.powerMenuVisible
                
                onRequestClose: {
                    console.log("PowerMenu requested close")
                    shellRoot.powerMenuVisible = false
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
                left: (screen.width - 700) / 2
            }
            
            implicitWidth: 700
            implicitHeight: 600
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            SettingsWidget {
                anchors.fill: parent
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
            }
        }
    }
}
