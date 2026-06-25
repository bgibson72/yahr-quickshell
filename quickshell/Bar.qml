import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Item {
    id: bar
    property string section: "full"
    
    property string backgroundStyle: "translucent"  // "opaque", "translucent", or "transparent"
    property bool enableBlur: false
    property string position: "top"  // "top" or "bottom"
    property real barOpacity: 0.70  // Dynamic opacity value from settings
    property bool showBorder: false
    property bool floating: false
    property bool showQuickLaunch: true
    property bool showSystemTray: true
    property int minWorkspaces: 4
    property string layoutPreset: "default"
    property string barStyle: "single"
    property int widgetBorderWidth: 1
    property int hyprRounding: 12  // Mirrors decoration:rounding from look-and-feel.conf
    property bool useIslands: bar.barStyle === "islands"
    property int islandHeight: ThemeManager.barLarge ? 43 : 36
    // Note: bar.visible is NOT bound to useIslands here. All child items already have their own
    // visibility conditions (e.g. "section === 'full' && !bar.useIslands"). Keeping the Bar Item
    // always in the Qt Quick scene graph ensures the Wayland layer-shell input region is properly
    // updated when switching between island and single bar styles. A root-level visible:false
    // removes the item from the scene graph, causing the input region to go stale and making
    // the quick-launch chevron unresponsive after switching from islands → single.
    implicitWidth: {
        if (section === "left") {
            return (layoutPreset === "default" ? defaultIslandLeftRow.implicitWidth : centeredIslandLeftRow.implicitWidth) + 16
        }
        if (section === "center") {
            return layoutPreset === "default"
                ? islandDefaultClockComponent.width + 12
                : islandAltArchComponent.width + 12
        }
        if (section === "right") {
            return islandsRightRow.implicitWidth + 8
        }
        return 0
    }
    implicitHeight: section === "full" ? 0 : (ThemeManager.barLarge ? 53 : 42)
    
    signal toggleClipboard()
    signal toggleControlCenter()
    signal toggleSettings()

    // Trigger an immediate settings reload (called from shell.qml onSettingsUpdated)
    function reloadBarSettings() {
        barSettingsLoader.running = true
        hyprRoundingLoader.running = true
    }
    
    // Load bar settings
    Process {
        id: barSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                barSettingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.bar) {
                        if (settings.bar.backgroundStyle !== undefined) {
                            bar.backgroundStyle = settings.bar.backgroundStyle
                        }
                        if (settings.bar.position !== undefined) {
                            bar.position = settings.bar.position
                        }
                        if (settings.bar.barOpacity !== undefined) {
                            bar.barOpacity = settings.bar.barOpacity
                        }
                        if (settings.bar.showBorder !== undefined) {
                            bar.showBorder = settings.bar.showBorder
                        }
                        if (settings.bar.floating !== undefined) {
                            bar.floating = settings.bar.floating
                        }
                        if (settings.bar.showQuickLaunch !== undefined) {
                            bar.showQuickLaunch = settings.bar.showQuickLaunch
                        }
                        if (settings.bar.showSystemTray !== undefined) {
                            bar.showSystemTray = settings.bar.showSystemTray
                        }
                        if (settings.bar.minWorkspaces !== undefined) {
                            bar.minWorkspaces = settings.bar.minWorkspaces
                        }
                        if (settings.bar.workspaceStyle !== undefined) {
                            ThemeManager.workspaceStyle = settings.bar.workspaceStyle
                        }
                        if (settings.bar.layoutPreset !== undefined) {
                            bar.layoutPreset = settings.bar.layoutPreset
                        }
                        if (settings.bar.barStyle !== undefined) {
                            bar.barStyle = settings.bar.barStyle
                        }
                    }
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        bar.enableBlur = settings.general.enableBlur
                    }
                    if (settings.general && settings.general.showWidgetBorders !== undefined) {
                        ThemeManager.showWidgetBorders = settings.general.showWidgetBorders !== false
                    }
                    if (settings.general && settings.general.widgetBorderWidth !== undefined) {
                        bar.widgetBorderWidth = settings.general.widgetBorderWidth
                        ThemeManager.widgetBorderWidth = settings.general.widgetBorderWidth
                    }
                    if (settings.hypr && settings.hypr.rounding !== undefined) {
                        bar.hyprRounding = settings.hypr.rounding
                        ThemeManager.hyprRounding = settings.hypr.rounding
                    }
                } catch (e) {
                    console.log("🎨 Error parsing bar settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Read window rounding from Hyprland look-and-feel.conf
    Process {
        id: hyprRoundingLoader
        running: false
        command: ["sh", "-c",
            `grep 'rounding = ' "$HOME/.config/hypr/look-and-feel.conf" | grep -oE '[0-9]+' | head -1`]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { hyprRoundingLoader.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const val = parseInt(buffer.trim())
                if (!isNaN(val)) {
                    bar.hyprRounding = val
                    ThemeManager.hyprRounding = val
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Auto-reload settings every second - delayed start for performance
    Timer {
        id: barSettingsTimer
        interval: 1000
        running: false  // Don't start immediately
        repeat: true
        onTriggered: {
            barSettingsLoader.running = true
            hyprRoundingLoader.running = true
        }
    }
    
    // Delayed initial settings load — only for the full-width bar.
    // Island section bars receive all props from shell.qml's immediate loader.
    Component.onCompleted: {
        if (section === "full") {
            Qt.callLater(() => {
                barSettingsLoader.running = true
                hyprRoundingLoader.running = true
                barSettingsTimer.running = true
            })
        }
    }
    
    // Background rectangle – glass style
    Rectangle {
        id: background
        visible: section === "full" && !bar.useIslands
        anchors.fill: parent
        color: {
            if (bar.backgroundStyle === "transparent") return "transparent"
            if (bar.backgroundStyle === "opaque") return ThemeManager.bgBase
            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, bar.barOpacity)
        }
        radius: bar.floating ? bar.hyprRounding : 0
        border.width: bar.showBorder ? bar.widgetBorderWidth : 0
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
        z: -1

        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on border.width { NumberAnimation { duration: 150 } }

        // Bottom edge accent line — only when docked without a full border
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
            visible: !bar.showBorder && !bar.floating
        }

        // Top specular highlight — only when no border is shown
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(1, 1, 1, 0.10)
            visible: !bar.showBorder
        }
    }

    QtObject {
        id: islandStyle
        property color bg: {
            if (bar.backgroundStyle === "transparent") return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.45)
            if (bar.backgroundStyle === "opaque") return ThemeManager.bgBase
            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, bar.barOpacity)
        }
        property color border: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
        property real radius: bar.hyprRounding
    }
    
    property var clockComponent: {
        if (!bar.useIslands || section === "full") {
            return bar.layoutPreset === "center-menu" ? singleAltClockComponent : singleDefaultClockComponent
        }
        if (section === "center" && bar.layoutPreset === "default") return islandDefaultClockComponent
        if (section === "right" && bar.layoutPreset === "center-menu") return islandAltClockComponent
        return null
    }
    property var archComponent: {
        if (!bar.useIslands || section === "full") {
            return bar.layoutPreset === "center-menu" ? singleAltArchComponent : singleDefaultArchComponent
        }
        if (section === "left" && bar.layoutPreset === "default") return islandDefaultArchComponent
        if (section === "center" && bar.layoutPreset === "center-menu") return islandAltArchComponent
        return null
    }
    
    // LEFT SECTION - default layout (single)
    RowLayout {
        visible: section === "full" && !bar.useIslands && bar.layoutPreset === "default"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        ArchButton {
            id: singleDefaultArchComponent
        }
        WorkspaceBar { minWorkspaces: bar.minWorkspaces }
        Separator {
            visible: bar.showQuickLaunch
        }
        QuickAccessDrawer {
            id: quickAccessDrawer
            visible: bar.showQuickLaunch
            onToggleSettings: bar.toggleSettings()
        }
    }

    // LEFT SECTION - centered menu layout (single)
    RowLayout {
        visible: section === "full" && !bar.useIslands && bar.layoutPreset === "center-menu"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        WorkspaceBar { minWorkspaces: bar.minWorkspaces }
        Separator {
            visible: bar.showQuickLaunch
        }
        QuickAccessDrawer {
            visible: bar.showQuickLaunch
            onToggleSettings: bar.toggleSettings()
        }
    }

    // LEFT SECTION - default layout (islands)
    Row {
        id: defaultIslandLeftRow
        visible: bar.useIslands && section === "left" && bar.layoutPreset === "default"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Item {
            width: islandDefaultArchComponent.width + 12
            height: bar.islandHeight

            Rectangle {
                anchors.fill: parent
                radius: islandStyle.radius
                color: islandStyle.bg
                border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                border.color: islandStyle.border
            }

            ArchButton {
                id: islandDefaultArchComponent
                anchors.centerIn: parent
            }
        }

        Item {
            width: islandWorkspaceDefault.implicitWidth + 12
            height: bar.islandHeight

            Rectangle {
                anchors.fill: parent
                radius: islandStyle.radius
                color: islandStyle.bg
                border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                border.color: islandStyle.border
            }

            WorkspaceBar {
                id: islandWorkspaceDefault
                anchors.centerIn: parent
                minWorkspaces: bar.minWorkspaces
            }
        }

        Item {
            visible: bar.showQuickLaunch
            width: visible ? islandQuickLaunchDefault.implicitWidth + 12 : 0
            height: bar.islandHeight

            Rectangle {
                anchors.fill: parent
                radius: islandStyle.radius
                color: islandStyle.bg
                border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                border.color: islandStyle.border
            }

            QuickAccessDrawer {
                id: islandQuickLaunchDefault
                anchors.centerIn: parent
                visible: parent.visible
                forceExpanded: true
                hideChevron: true
                onToggleSettings: bar.toggleSettings()
            }
        }
    }

    // LEFT SECTION - centered menu layout (islands)
    Row {
        id: centeredIslandLeftRow
        visible: bar.useIslands && section === "left" && bar.layoutPreset === "center-menu"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Item {
            width: islandWorkspaceCentered.implicitWidth + 12
            height: bar.islandHeight

            Rectangle {
                anchors.fill: parent
                radius: islandStyle.radius
                color: islandStyle.bg
                border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                border.color: islandStyle.border
            }

            WorkspaceBar {
                id: islandWorkspaceCentered
                anchors.centerIn: parent
                minWorkspaces: bar.minWorkspaces
            }
        }

        Item {
            visible: bar.showQuickLaunch
            width: visible ? islandQuickLaunchCentered.implicitWidth + 12 : 0
            height: bar.islandHeight

            Rectangle {
                anchors.fill: parent
                radius: islandStyle.radius
                color: islandStyle.bg
                border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                border.color: islandStyle.border
            }

            QuickAccessDrawer {
                id: islandQuickLaunchCentered
                anchors.centerIn: parent
                visible: parent.visible
                forceExpanded: true
                hideChevron: true
                onToggleSettings: bar.toggleSettings()
            }
        }
    }

    // CENTER SECTION - default layout (single)
    Clock {
        id: singleDefaultClockComponent
        visible: section === "full" && !bar.useIslands && bar.layoutPreset === "default"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    // CENTER SECTION - default layout (islands)
    Item {
        visible: bar.useIslands && section === "center" && bar.layoutPreset === "default"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: islandDefaultClockComponent.width + 12
        height: bar.islandHeight

        Rectangle {
            anchors.fill: parent
            radius: islandStyle.radius
            color: islandStyle.bg
            border.width: bar.showBorder ? bar.widgetBorderWidth : 0
            border.color: islandStyle.border
        }

        Clock {
            id: islandDefaultClockComponent
            anchors.centerIn: parent
        }
    }

    // CENTER SECTION - centered menu layout (single)
    ArchButton {
        id: singleAltArchComponent
        visible: section === "full" && !bar.useIslands && bar.layoutPreset === "center-menu"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    // CENTER SECTION - centered menu layout (islands)
    Item {
        visible: bar.useIslands && section === "center" && bar.layoutPreset === "center-menu"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: islandAltArchComponent.width + 12
        height: bar.islandHeight

        Rectangle {
            anchors.fill: parent
            radius: islandStyle.radius
            color: islandStyle.bg
            border.width: bar.showBorder ? bar.widgetBorderWidth : 0
            border.color: islandStyle.border
        }

        ArchButton {
            id: islandAltArchComponent
            anchors.centerIn: parent
        }
    }

    // CENTER-RIGHT SECTION - Media Player
    MediaPlayer {
        visible: section === "full" && !bar.useIslands && bar.layoutPreset === "default"
        anchors.left: singleDefaultClockComponent.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    
    // RIGHT SECTION (single)
    Item {
        visible: section === "full" && !bar.useIslands
        anchors.right: parent.right
        anchors.rightMargin: bar.floating ? 8 : 4
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: singleRightRow.width
        
        Row {
            id: singleRightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            TrayDrawer {
                id: trayDrawerComponent
                showTray: bar.showSystemTray
                onToggleClipboard: bar.toggleClipboard()
                onToggleControlCenter: bar.toggleControlCenter()
            }

            Clock {
                id: singleAltClockComponent
                visible: bar.layoutPreset === "center-menu"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // RIGHT SECTION (islands)
    Item {
        visible: bar.useIslands && section === "right"
        anchors.right: parent.right
        anchors.rightMargin: bar.floating ? 8 : 4
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: islandsRightRow.width

        Row {
            id: islandsRightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Item {
                visible: bar.showSystemTray
                width: visible ? islandTrayComponent.width + 12 : 0
                height: bar.islandHeight

                Rectangle {
                    anchors.fill: parent
                    radius: islandStyle.radius
                    color: islandStyle.bg
                    border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                    border.color: islandStyle.border
                }

                TrayDrawer {
                    id: islandTrayComponent
                    anchors.centerIn: parent
                    showTray: bar.showSystemTray
                    onToggleClipboard: bar.toggleClipboard()
                    onToggleControlCenter: bar.toggleControlCenter()
                }
            }

            Item {
                visible: bar.layoutPreset === "center-menu"
                width: visible ? islandAltClockComponent.width + 12 : 0
                height: bar.islandHeight

                Rectangle {
                    anchors.fill: parent
                    radius: islandStyle.radius
                    color: islandStyle.bg
                    border.width: bar.showBorder ? bar.widgetBorderWidth : 0
                    border.color: islandStyle.border
                }

                Clock {
                    id: islandAltClockComponent
                    anchors.centerIn: parent
                }
            }
        }
    }
}
