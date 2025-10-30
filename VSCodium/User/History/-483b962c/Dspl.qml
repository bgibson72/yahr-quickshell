import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: wallpaperWindow
    
    implicitWidth: 1000
    implicitHeight: 700
    
    visible: false
    color: "transparent"
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    mask: Region { item: bgRect }
    exclusiveZone: 0
    
    property string currentTheme: ""
    property string wallpaperDir: ""
    
    function show() {
        loadCurrentTheme()
        loadWallpapers()
        wallpaperWindow.visible = true
        bgRect.forceActiveFocus()
    }
    
    function hide() {
        wallpaperWindow.visible = false
    }
    
    function loadCurrentTheme() {
        // Read current theme from file
        const themeFile = Quickshell.env("HOME") + "/.config/hypr/.current-theme"
        currentTheme = "TokyoNight" // fallback
        
        themeProcess.running = true
    }
    
    Process {
        id: themeProcess
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/.current-theme"]
        
        stdout: SplitParser {
            onRead: data => {
                const theme = data.trim()
                if (theme.length > 0) {
                    currentTheme = theme
                }
                updateWallpaperDir()
            }
        }
    }
    
    function updateWallpaperDir() {
        const base = Quickshell.env("HOME") + "/Pictures/Wallpapers/"
        wallpaperDir = base + currentTheme
        console.log("Updated wallpaper directory to:", wallpaperDir)
        loadWallpapers()
    }
    
    function loadWallpapers() {
        console.log("Loading wallpapers from:", wallpaperDir)
        wallpaperModel.clear()
        wallpaperLoader.running = true
    }
    
    Process {
        id: wallpaperLoader
        running: false
        command: ["sh", "-c", "find '" + wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0"]
        
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
    
    // Background overlay
    Rectangle {
        anchors.fill: parent
        color: "#80000000"  // Semi-transparent black
        
        MouseArea {
            anchors.fill: parent
            onClicked: wallpaperWindow.hide()
        }
    }
    
    Rectangle {
        id: bgRect
        anchors.centerIn: parent
        width: 1000
        height: 700
        color: ThemeManager.surface0
        radius: 24
        border.width: 2
        border.color: ThemeManager.accentBlue
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
                
                Row {
                    anchors.fill: parent
                    spacing: 10
                    
                    Text {
                        text: ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 24
                        color: ThemeManager.accentBlue
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Wallpaper Picker - " + currentTheme
                        font.family: "Maple Mono NF"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { 
                        width: parent.width - 500
                        height: 1
                    }
                    
                    // Close button
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: closeMouseArea.containsMouse ? ThemeManager.accentRed : ThemeManager.surface1
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
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
            }
            
            // Wallpaper Grid
            Rectangle {
                width: parent.width
                height: parent.height - 65
                color: ThemeManager.surface1
                radius: 16
                
                GridView {
                    id: gridView
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    cellWidth: 240
                    cellHeight: 180
                    
                    clip: true
                    
                    model: wallpaperModel
                    
                    delegate: Rectangle {
                        width: gridView.cellWidth - 10
                        height: gridView.cellHeight - 10
                        color: mouseArea.containsMouse ? ThemeManager.accentBlue : ThemeManager.surface2
                        radius: 12
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5
                            
                            // Thumbnail
                            Rectangle {
                                width: parent.width
                                height: parent.height - 30
                                color: ThemeManager.surface0
                                radius: 8
                                clip: true
                                
                                Image {
                                    id: thumbnail
                                    anchors.fill: parent
                                    source: "file://" + model.path
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    cache: true
                                    asynchronous: true
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"
                                        border.width: 1
                                        border.color: ThemeManager.border1
                                        radius: 8
                                    }
                                }
                            }
                            
                            // Filename
                            Text {
                                width: parent.width
                                height: 25
                                text: model.name
                                font.family: "Maple Mono NF"
                                font.pixelSize: 11
                                color: mouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
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
                        policy: ScrollBar.AsNeeded
                        
                        contentItem: Rectangle {
                            implicitWidth: 8
                            radius: 4
                            color: ThemeManager.accentBlue
                        }
                    }
                }
            }
        }
    }
    
    function setWallpaper(path) {
        console.log("Setting wallpaper:", path)
        
        // Check if swww-daemon is running
        swwwCheck.running = true
        
        // Set wallpaper
        Qt.callLater(() => {
            Quickshell.execDetached([
                "swww", "img", path,
                "--transition-type", "grow",
                "--transition-pos", "0.5,0.5",
                "--transition-duration", "2"
            ])
            
            // Show notification
            Quickshell.execDetached([
                "notify-send", "Wallpaper Changed", 
                path.split('/').pop()
            ])
            
            // Close picker
            wallpaperWindow.hide()
        })
    }
    
    Process {
        id: swwwCheck
        running: false
        command: ["pgrep", "-x", "swww-daemon"]
        
        onExited: (code, status) => {
            if (code !== 0) {
                // Start swww-daemon if not running
                Quickshell.execDetached(["swww-daemon"])
            }
        }
    }
}
