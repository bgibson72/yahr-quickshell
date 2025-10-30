import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shellRoot
    property bool calendarVisible: false
    property bool notificationCenterVisible: false
    property bool dndEnabled: false
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
    
    function toggleNotificationCenter() {
        console.log("IPC: Toggling notification center")
        shellRoot.notificationCenterVisible = !shellRoot.notificationCenterVisible
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
    
    // File-based IPC watcher for notification center keybind
    Process {
        id: notificationCenterWatcher
        running: true
        command: ["sh", "-c", "while true; do if [ -f /tmp/quickshell-notification-center-toggle ]; then cat /tmp/quickshell-notification-center-toggle; rm /tmp/quickshell-notification-center-toggle; fi; sleep 0.1; done"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line === "toggle") {
                    shellRoot.notificationCenterVisible = !shellRoot.notificationCenterVisible
                    console.log("Notification center toggled via keybind:", shellRoot.notificationCenterVisible)
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
            }
            
            margins {
                top: 42  // Position at bottom edge of 42px bar
                left: (screen.width - 750) / 2  // Center horizontally
                right: (screen.width - 750) / 2  // Center horizontally
            }
            
            implicitWidth: 750
            implicitHeight: shellRoot.calendarVisible ? 420 : 0
            
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
    
    // Notification Center popup - anchored on right edge
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.notificationCenterVisible
            
            anchors {
                top: true
                right: true
                bottom: true
            }
            
            margins {
                top: 42  // Position below bar
                right: 8  // Small margin from screen edge
                bottom: 8
            }
            
            implicitWidth: shellRoot.notificationCenterVisible ? 450 : 0
            implicitHeight: screen.height - 42 - 16  // Full height minus bar and margins
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            
            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            NotificationCenter {
                id: notificationCenterComponent
                anchors.fill: parent
                isVisible: shellRoot.notificationCenterVisible
                
                onRequestClose: {
                    shellRoot.notificationCenterVisible = false
                }
                
                onDndStateChanged: function(enabled) {
                    // Update the notification indicator's DND state
                    if (bar && bar.notificationComponent) {
                        bar.notificationComponent.dndMode = enabled
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
            }
            
            margins {
                top: 42  // Position at bottom edge of 42px bar
                left: 8  // Align with left edge near Arch button
            }
            
            implicitWidth: 400
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
                right: true
            }
            
            margins {
                top: 42  // Position at bottom edge of 42px bar
                right: 8  // Align with right edge near power button
            }
            
            implicitWidth: 200
            implicitHeight: shellRoot.powerMenuVisible ? 420 : 0
            
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
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitHeight: 42
            color: ThemeManager.bgBaseAlpha
            
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
                
                // Connect notification indicator click signal
                Connections {
                    target: bar.notificationComponent
                    function onClicked() {
                        shellRoot.notificationCenterVisible = !shellRoot.notificationCenterVisible
                        console.log("Notification Center toggled:", shellRoot.notificationCenterVisible)
                    }
                }
            }
        }
    }
}
