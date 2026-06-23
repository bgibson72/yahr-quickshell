import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

// Embeddable wallpaper picker — used as tab content inside SystemInfoWidget.
// All process logic mirrors WallpaperPicker.qml but adapted for any parent size.
Item {
    id: root

    property bool showWidgetBorders: true
    property int widgetBorderWidth: 1
    property string currentTheme: ""
    property string selectedTab: ""
    property string pendingWallpaperPath: ""

    // Trigger data load the first time this tab becomes visible
    onVisibleChanged: {
        if (visible && themeModel.count === 0) {
            loadCurrentTheme()
        }
    }

    // ---------- Public functions ----------

    function loadCurrentTheme() {
        wallpaperModel.clear()
        themeModel.clear()
        currentTheme = ""
        selectedTab = ""
        settingsLoader.running = false
        settingsLoader.running = true
    }

    function loadWallpapers() {
        wallpaperModel.clear()
        wallpaperLoader.running = false
        wallpaperLoader.running = true
    }

    function setWallpaper(path) {
        pendingWallpaperPath = path
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

        Quickshell.execDetached(["bash", "-c",
            'printf "%s" "$1" > ~/.config/quickshell/last-wallpaper', "--", path])

        sddmSyncTimer.start()

        Quickshell.execDetached([
            "notify-send", "Wallpaper Changed",
            path.split('/').pop()
        ])
    }

    // ---------- Processes ----------

    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { settingsLoader.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const s = JSON.parse(buffer)
                    if (s.general && s.general.showWidgetBorders !== undefined)
                        root.showWidgetBorders = s.general.showWidgetBorders !== false
                    if (s.general && s.general.widgetBorderWidth !== undefined)
                        root.widgetBorderWidth = s.general.widgetBorderWidth
                } catch (e) {
                    console.error("WallpaperPickerContent: failed to parse settings:", e)
                }
                buffer = ""
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
            onRead: data => { themeProcess.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const theme = buffer.trim()
                root.currentTheme = theme.length > 0 ? theme : "TokyoNight"
                buffer = ""
                themeListProcess.running = false
                themeListProcess.running = true
            } else if (running) {
                buffer = ""
            }
        }
    }

    Process {
        id: themeListProcess
        running: false
        command: ["sh", "-c",
            "find '" + Quickshell.env("HOME") + "/Pictures/Wallpapers' " +
            "-maxdepth 1 -mindepth 1 -type d -exec basename {} \\; | sort"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { themeListProcess.buffer += data + "\n" }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const lines = buffer.trim().split("\n")
                for (const line of lines) {
                    const name = line.trim()
                    if (name.length > 0) themeModel.append({ name: name })
                }
                buffer = ""
                let found = false
                for (let i = 0; i < themeModel.count; i++) {
                    if (themeModel.get(i).name === root.currentTheme) {
                        root.selectedTab = root.currentTheme
                        found = true
                        break
                    }
                }
                if (!found && themeModel.count > 0)
                    root.selectedTab = themeModel.get(0).name
                loadWallpapers()
            } else if (running) {
                buffer = ""
            }
        }
    }

    Process {
        id: wallpaperLoader
        running: false
        command: ["sh", "-c",
            "find '" + Quickshell.env("HOME") + "/Pictures/Wallpapers/" + root.selectedTab + "' " +
            "-maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0"]

        stdout: SplitParser {
            splitMarker: "\0"
            onRead: data => {
                const path = data.trim()
                if (path.length > 0)
                    wallpaperModel.append({ path: path, name: path.split('/').pop() })
            }
        }
    }

    Timer {
        id: sddmSyncTimer
        interval: 500
        repeat: false
        onTriggered: {
            const script = Quickshell.env("HOME") + "/.config/quickshell/sync-sddm-theme.sh"
            Quickshell.execDetached(["sh", "-c", script])
        }
    }

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
                Quickshell.execDetached(["awww-daemon"])
                daemonStartTimer.start()
            } else {
                applyWallpaper()
            }
        }
    }

    ListModel { id: themeModel }
    ListModel { id: wallpaperModel }

    // ---------- UI ----------

    // Theme tab strip — scrollable horizontally when many themes exist
    Rectangle {
        id: themeTabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56  // extra height gives breathing room between tab labels and scrollbar
        color: "transparent"
        radius: 10
        border.width: 0
        border.color: "transparent"

        ListView {
            id: themeTabList
            anchors.fill: parent
            anchors.margins: 4
            orientation: ListView.Horizontal
            spacing: 0
            clip: true
            model: themeModel

            // Allow horizontal scrolling if theme names don't fit
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitHeight: 4
                    radius: 2
                    color: ThemeManager.accentBlue
                }
            }

            delegate: Rectangle {
                id: themeTabDelegate
                // Reduce delegate height by 10 px so the scrollbar sits in its own space below
                height: themeTabList.height - 10
                // Each tab is at least 80 px wide so names aren't crushed on a narrow strip
                width: Math.max(80, themeTabList.width / Math.max(1, themeTabList.count))
                radius: 8

                property bool isActive: model.name === root.selectedTab

                color: isActive
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.22)
                    : (themeTabMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                Behavior on color { ColorAnimation { duration: 120 } }

                // Active underline
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    height: 2
                    radius: 1
                    color: ThemeManager.accentBlue
                    visible: themeTabDelegate.isActive
                }

                Text {
                    id: themeTabLabel
                    anchors.centerIn: parent
                    text: model.name
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 12
                    font.weight: themeTabDelegate.isActive ? Font.Bold : Font.Normal
                    color: themeTabDelegate.isActive ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                    elide: Text.ElideRight
                    width: parent.width - 8
                    horizontalAlignment: Text.AlignHCenter
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                MouseArea {
                    id: themeTabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.selectedTab !== model.name) {
                            root.selectedTab = model.name
                            loadWallpapers()
                        }
                    }
                }
            }
        }
    }

    // Wallpaper grid — fills remaining height, vertical scroll
    GridView {
        id: gridView
        anchors.top: themeTabBar.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // 3 columns; cell height is 16:9 of cell width
        readonly property int cols: 3
        cellWidth: Math.floor(width / cols)
        cellHeight: Math.floor(cellWidth * 9 / 16)

        clip: true
        model: wallpaperModel

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: ThemeManager.accentBlue
            }
        }

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 5
                color: "transparent"
                radius: 10

                Image {
                    id: wallThumbnail
                    anchors.fill: parent
                    anchors.margins: 2
                    source: "file://" + model.path
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: true
                    asynchronous: true
                    sourceSize.width: gridView.cellWidth - 10
                    sourceSize.height: gridView.cellHeight - 10

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: wallThumbnail.width
                            height: wallThumbnail.height
                            radius: 8
                        }
                    }

                    onStatusChanged: {
                        if (status === Image.Error)
                            console.error("WallpaperPickerContent: failed to load:", model.path)
                    }
                }

                // Failed-to-load placeholder
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.07)
                    visible: wallThumbnail.status === Image.Error || wallThumbnail.status === Image.Null

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰋩"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 28
                            color: ThemeManager.fgSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Failed to load"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 9
                            color: ThemeManager.fgSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Loading placeholder
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.07)
                    visible: wallThumbnail.status === Image.Loading

                    Text {
                        anchors.centerIn: parent
                        text: "󰔟"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 28
                        color: ThemeManager.accentBlue
                    }
                }

                // Hover border
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    color: "transparent"
                    border.width: tileHover.containsMouse ? 3 : 0
                    border.color: ThemeManager.accentBlue
                    radius: 8

                    Behavior on border.width { NumberAnimation { duration: 100 } }
                }

                MouseArea {
                    id: tileHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setWallpaper(model.path)
                }
            }
        }
    }
}
