import QtQuick
import Quickshell
import Quickshell.Io

// Dock widget — a pinned-application launcher bar that can be docked to any
// screen edge (top/bottom/left/right), aligned to the start/center/end of
// that edge, and toggled between a docked (edge-to-edge) or floating
// (rounded, inset) appearance — mirroring Bar.qml's floating semantics.
Item {
    id: dock

    // ---- Configuration (bound from shell.qml, sourced from settings.json) ----
    property string position: "bottom"     // "top" | "bottom" | "left" | "right"
    property string alignment: "center"    // "start" | "center" | "end"
    property bool floating: true
    property string backgroundStyle: "translucent"  // "transparent" | "translucent" | "opaque"
    property real dockOpacity: 0.70
    property bool showBorder: false
    property int iconSize: 48
    // Each entry: { name, icon, exec, terminal, desktopId }
    property var pinnedApps: []

    readonly property bool isHorizontal: position === "top" || position === "bottom"
    readonly property int padding: 10
    readonly property int itemSpacing: 10

    signal launchRequested(string execCmd, bool needsTerminal)
    signal unpinRequested(string desktopId)
    signal pinPickerRequested()

    // Hyprland's actual border thickness — the dock's border (when enabled)
    // follows this rather than the separate per-widget border setting used
    // elsewhere, per the design requirement.
    property int hyprBorderSize: 1

    Process {
        id: hyprBorderLoader
        running: false
        command: ["hyprctl", "getoption", "general:border_size", "-j"]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => { hyprBorderLoader.buffer += data }
        }
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const result = JSON.parse(buffer)
                    if (result.int !== undefined) dock.hyprBorderSize = result.int
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
        triggeredOnStart: true
        onTriggered: hyprBorderLoader.running = true
    }

    implicitWidth: isHorizontal ? contentRow.width + padding * 2 : contentColumn.width + padding * 2
    implicitHeight: isHorizontal ? contentRow.height + padding * 2 : contentColumn.height + padding * 2

    // ---- Background ----
    Rectangle {
        id: background
        anchors.fill: parent
        radius: dock.floating ? dock.hyprBorderSize + 11 : 0
        color: {
            if (dock.backgroundStyle === "transparent") return "transparent"
            if (dock.backgroundStyle === "opaque") return ThemeManager.bgBase
            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, dock.dockOpacity)
        }
        border.width: dock.showBorder ? dock.hyprBorderSize : 0
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.45)

        // Accent line when docked (edge-to-edge) without a border, matching Bar.qml's convention
        Rectangle {
            visible: !dock.showBorder && !dock.floating
            color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
            anchors {
                left: dock.position !== "left" ? parent.left : undefined
                right: dock.position !== "right" ? parent.right : undefined
                top: dock.position !== "top" ? parent.top : undefined
                bottom: dock.position !== "bottom" ? parent.bottom : undefined
            }
            width: dock.isHorizontal ? parent.width : 1
            height: dock.isHorizontal ? 1 : parent.height
        }
    }

    // ---- Horizontal layout (top/bottom dock) ----
    Row {
        id: contentRow
        visible: dock.isHorizontal
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dock.alignment === "start" ? parent.left : undefined
        anchors.right: dock.alignment === "end" ? parent.right : undefined
        anchors.horizontalCenter: dock.alignment === "center" ? parent.horizontalCenter : undefined
        anchors.leftMargin: dock.alignment === "start" ? dock.padding : 0
        anchors.rightMargin: dock.alignment === "end" ? dock.padding : 0
        spacing: dock.itemSpacing

        Repeater {
            model: dock.pinnedApps
            delegate: dockItemDelegate
        }

        DockAddButton {
            iconSize: dock.iconSize
            onClicked: dock.pinPickerRequested()
        }
    }

    // ---- Vertical layout (left/right dock) ----
    Column {
        id: contentColumn
        visible: !dock.isHorizontal
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: dock.alignment === "start" ? parent.top : undefined
        anchors.bottom: dock.alignment === "end" ? parent.bottom : undefined
        anchors.verticalCenter: dock.alignment === "center" ? parent.verticalCenter : undefined
        anchors.topMargin: dock.alignment === "start" ? dock.padding : 0
        anchors.bottomMargin: dock.alignment === "end" ? dock.padding : 0
        spacing: dock.itemSpacing

        Repeater {
            model: dock.pinnedApps
            delegate: dockItemDelegate
        }

        DockAddButton {
            iconSize: dock.iconSize
            onClicked: dock.pinPickerRequested()
        }
    }

    Component {
        id: dockItemDelegate

        Item {
            id: dockItem
            required property var modelData
            width: dock.iconSize
            height: dock.iconSize

            property bool hovered: itemArea.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: dockItem.hovered ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            scale: dockItem.hovered ? 1.12 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Image {
                id: icon
                anchors.centerIn: parent
                width: dock.iconSize - 12
                height: dock.iconSize - 12
                sourceSize: Qt.size(dock.iconSize - 12, dock.iconSize - 12)
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: modelData.icon && modelData.icon.startsWith('/') ? "file://" + modelData.icon : ""
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                text: "󰣆"
                font.family: "Symbols Nerd Font"
                font.pixelSize: dock.iconSize * 0.55
                color: ThemeManager.fgPrimary
                visible: !icon.visible
            }

            // Tooltip
            Rectangle {
                visible: dockItem.hovered
                color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.95)
                radius: 6
                width: tooltipText.implicitWidth + 16
                height: tooltipText.implicitHeight + 8
                anchors.horizontalCenter: parent.horizontalCenter
                y: dock.position === "bottom" ? -height - 8
                   : dock.position === "top" ? parent.height + 8
                   : 0
                x: dock.position === "left" ? parent.width + 8
                   : dock.position === "right" ? -width - 8
                   : (width - parent.width) / -2

                Text {
                    id: tooltipText
                    anchors.centerIn: parent
                    text: modelData.name || ""
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 11
                    color: ThemeManager.fgPrimary
                }
            }

            MouseArea {
                id: itemArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        unpinPopup.visible = !unpinPopup.visible
                    } else {
                        unpinPopup.visible = false
                        dock.launchRequested(modelData.exec, modelData.terminal === true)
                    }
                }
            }

            // Lightweight custom context menu (matches the codebase's
            // convention of hand-rolled overlays rather than QtQuick.Controls Menu).
            // Auto-dismisses after a few seconds so it never gets stuck open.
            Rectangle {
                id: unpinPopup
                visible: false
                z: 200
                width: unpinLabel.implicitWidth + 24
                height: unpinLabel.implicitHeight + 16
                radius: 8
                color: ThemeManager.bgBase
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.15)
                anchors.horizontalCenter: parent.horizontalCenter
                y: dock.position === "bottom" ? -height - 8 : parent.height + 8

                Timer {
                    running: unpinPopup.visible
                    interval: 4000
                    onTriggered: unpinPopup.visible = false
                }

                Text {
                    id: unpinLabel
                    anchors.centerIn: parent
                    text: "Unpin from Dock"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 12
                    color: ThemeManager.fgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        unpinPopup.visible = false
                        dock.unpinRequested(modelData.desktopId)
                    }
                }
            }
        }
    }
}
