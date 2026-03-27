import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

PanelWindow {
    id: wallpaperWindow
    
    width: 1080
    height: 760
    
    visible: false
    color: "transparent"
    
    exclusiveZone: 0
    
    property string currentTheme: ""
    property string wallpaperDir: ""
    property bool showAllWallpapers: false
    property string pendingWallpaperPath: ""
    
    function show() {
        loadCurrentTheme()
        wallpaperWindow.visible = true
        bgRect.forceActiveFocus()
    }
    
    function hide() {
        wallpaperWindow.visible = false
    }
    
    function loadCurrentTheme() {
        // Always reload theme from file when showing picker
        console.log("Loading current theme...")
        wallpaperModel.clear()  // Clear old wallpapers immediately
        currentTheme = ""       // Reset to avoid stale value

        // Load settings first; themeProcess is started from settingsLoader.onRunningChanged
        // so that showAllWallpapers is always set before updateWallpaperDir() runs.
        settingsLoader.running = false
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
                    const settings = JSON.parse(buffer)
                    if (settings.wallpaper && settings.wallpaper.showAllWallpapers !== undefined) {
                        showAllWallpapers = settings.wallpaper.showAllWallpapers
                        console.log("Wallpaper filter mode:", showAllWallpapers ? "All wallpapers" : "Themed only")
                    } else {
                        showAllWallpapers = false
                    }
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                    showAllWallpapers = false
                }
                buffer = ""
                // Chain: now that settings are loaded, read the current theme
                themeProcess.running = false
                themeProcess.running = true
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: themeProcess
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/.current-theme"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                themeProcess.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const theme = buffer.trim()
                if (theme.length > 0) {
                    currentTheme = theme
                } else {
                    currentTheme = "TokyoNight" // fallback for empty file
                }
                buffer = ""
                updateWallpaperDir()
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    function updateWallpaperDir() {
        const base = Quickshell.env("HOME") + "/Pictures/Wallpapers/"
        if (showAllWallpapers) {
            wallpaperDir = base
            console.log("Updated wallpaper directory to:", wallpaperDir, "(all wallpapers)")
        } else {
            wallpaperDir = base + currentTheme
            console.log("Updated wallpaper directory to:", wallpaperDir, "(themed only)")
        }
        loadWallpapers()
    }
    
    function loadWallpapers() {
        console.log("Loading wallpapers from:", wallpaperDir)
        wallpaperModel.clear()
        // Stop any previously running wallpaper loader
        wallpaperLoader.running = false
        wallpaperLoader.running = true
    }
    
    Process {
        id: wallpaperLoader
        running: false
        command: ["sh", "-c", "find '" + wallpaperDir + "' " + (showAllWallpapers ? "" : "-maxdepth 1 ") + "-type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0"]
        
        stdout: SplitParser {
            splitMarker: "\0"
            onRead: data => {
                const path = data.trim()
                if (path.length > 0) {
                    console.log("Found wallpaper:", path)
                    wallpaperModel.append({
                        path: path,
                        name: path.split('/').pop()
                    })
                }
            }
        }
    }
    
    ListModel {
        id: wallpaperModel
    }
    
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
        radius: 24
        border.width: 1
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
        clip: true
        focus: true
        
        // Add keyboard handling
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true
                wallpaperWindow.hide()
            }
        }
        
        // Prevent clicks from passing through to background
        MouseArea {
            anchors.fill: parent
            onClicked: {
                parent.forceActiveFocus()
                // Consume click, don't close
            }
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Header
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                
                Text {
                    text: ""
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 24
                    color: ThemeManager.accentBlue
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }
                
                Text {
                    text: "Wallpaper Picker - " + (showAllWallpapers ? "All Wallpapers" : currentTheme)
                    font.family: "Sen"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 35
                }
                
                // Close button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: closeMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.30) : Qt.rgba(1, 1, 1, 0.07)
                    border.width: closeMouseArea.containsMouse ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: "Sen"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                    }
                    
                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wallpaperWindow.hide()
                    }
                }
            }
            
            // Wallpaper Grid
            Rectangle {
                width: parent.width
                height: 650  // Height for exactly 3 rows: 3 * 210 + 20px margins
                color: "transparent"
                radius: 16
                
                GridView {
                    id: gridView
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    cellWidth: 250
                    cellHeight: 210
                    
                    clip: true
                    
                    model: wallpaperModel
                    
                    delegate: Rectangle {
                        width: gridView.cellWidth - 10
                        height: gridView.cellHeight - 10
                        color: "transparent"
                        radius: 12
                        
                        // Thumbnail image with rounded corners
                        Image {
                            id: thumbnail
                            anchors.fill: parent
                            anchors.margins: 3
                            source: "file://" + model.path
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            cache: true
                            asynchronous: true
                            sourceSize.width: 240
                            sourceSize.height: 200
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: thumbnail.width
                                    height: thumbnail.height
                                    radius: 10
                                }
                            }
                            
                            // Show loading/error state
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.error("Failed to load image:", model.path)
                                }
                            }
                        }
                        
                        // Fallback for failed images
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.07)
                            visible: thumbnail.status === Image.Error || thumbnail.status === Image.Null
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: "󰋩"  // broken image icon
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 48
                                    color: ThemeManager.fgSecondary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Text {
                                    text: "Failed to load"
                                    font.family: "Sen"
                                    font.pixelSize: 10
                                    color: ThemeManager.fgSecondary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        
                        // Loading indicator
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.07)
                            visible: thumbnail.status === Image.Loading
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰔟"  // loading spinner icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 48
                                color: ThemeManager.accentBlue
                            }
                        }
                        
                        // Border overlay - only shows on hover
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            color: "transparent"
                            border.width: mouseArea.containsMouse ? 3 : 0
                            border.color: ThemeManager.accentBlue
                            radius: 10
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                setWallpaper(model.path)
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: wallpaperModel.count > 12 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        
                        contentItem: Rectangle {
                            implicitWidth: 8
                            radius: 4
                            color: ThemeManager.accentBlue
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
            radius: 24
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
            radius: 24
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.12) }
            }
            z: 10
        }
    }

    function setWallpaper(path) {
        console.log("Setting wallpaper:", path)
        pendingWallpaperPath = path
        // Check daemon status first; applyWallpaper() is called from swwwCheck.onExited
        swwwCheck.running = true
    }

    function applyWallpaper() {
        const path = pendingWallpaperPath
        if (!path) return
        pendingWallpaperPath = ""

        Quickshell.execDetached([
            "awww", "img", path,
            "--transition-type", "grow",
            "--transition-pos", "0.5,0.5",
            "--transition-duration", "2"
        ])

        // Persist last wallpaper path so autostart can restore it on next login
        Quickshell.execDetached(["bash", "-c",
            'printf "%s" "$1" > ~/.config/quickshell/last-wallpaper', "--", path])

        sddmSyncTimer.start()

        Quickshell.execDetached([
            "notify-send", "Wallpaper Changed",
            path.split('/').pop()
        ])

        wallpaperWindow.hide()
    }
    
    Timer {
        id: sddmSyncTimer
        interval: 500  // Wait 500ms for swww to complete
        repeat: false
        onTriggered: {
            // Sync SDDM theme with new wallpaper
            const sddmSync = Quickshell.env("HOME") + "/.config/quickshell/sync-sddm-theme.sh"
            Quickshell.execDetached(["sh", "-c", sddmSync])
        }
    }

    // If swww-daemon wasn't running, give it time to initialize before applying
    Timer {
        id: daemonStartTimer
        interval: 800
        repeat: false
        onTriggered: applyWallpaper()
    }

    Process {
        id: swwwCheck
        running: false
        command: ["pgrep", "-x", "awww-daemon"]
        
        onExited: (code, status) => {
            if (code !== 0) {
                // Daemon not running — start it and wait for it to initialize
                Quickshell.execDetached(["awww-daemon"])
                daemonStartTimer.start()
            } else {
                // Daemon already running — safe to apply immediately
                applyWallpaper()
            }
        }
    }
}
