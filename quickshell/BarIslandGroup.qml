import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string section: "left"
    property string layoutPreset: "default"
    property bool showQuickLaunch: true
    property bool showSystemTray: true
    property bool showBorder: false
    property int widgetBorderWidth: 1
    property int hyprRounding: 12
    property string backgroundStyle: "opaque"
    property real barOpacity: 0.70
    property int islandHeight: ThemeManager.barLarge ? 43 : 36

    signal toggleClipboard()
    signal toggleControlCenter()
    signal toggleCalendar()
    signal toggleLauncher()

    implicitWidth: contentRow.implicitWidth
    implicitHeight: islandHeight

    function islandColor() {
        if (backgroundStyle === "transparent") {
            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.45)
        }
        if (backgroundStyle === "opaque") {
            return ThemeManager.bgBase
        }
        return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, barOpacity)
    }

    property real islandRadius: Math.max(8, hyprRounding - 2)
    property color islandBorderColor: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)

    RowLayout {
        id: contentRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Item {
            visible: root.section === "left" && root.layoutPreset === "default"
            implicitWidth: archLeft.width + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            ArchButton {
                id: archLeft
                anchors.centerIn: parent
                onToggleLauncher: root.toggleLauncher()
            }
        }

        Item {
            visible: root.section === "left"
            implicitWidth: workspaceBar.implicitWidth + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            WorkspaceBar {
                id: workspaceBar
                anchors.centerIn: parent
            }
        }

        Item {
            visible: root.section === "left" && root.showQuickLaunch
            implicitWidth: quickLaunch.implicitWidth + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            QuickAccessDrawer {
                id: quickLaunch
                anchors.centerIn: parent
                forceExpanded: true
                hideChevron: true
            }
        }

        Item {
            visible: root.section === "center" && root.layoutPreset === "default"
            implicitWidth: centerClock.width + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            Clock {
                id: centerClock
                anchors.centerIn: parent
                onToggleCalendar: root.toggleCalendar()
            }
        }

        Item {
            visible: root.section === "center" && root.layoutPreset === "center-menu"
            implicitWidth: centerArch.width + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            ArchButton {
                id: centerArch
                anchors.centerIn: parent
                onToggleLauncher: root.toggleLauncher()
            }
        }

        Item {
            visible: root.section === "right" && root.showSystemTray
            implicitWidth: rightTray.width + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            TrayDrawer {
                id: rightTray
                anchors.centerIn: parent
                showTray: root.showSystemTray
                onToggleClipboard: root.toggleClipboard()
                onToggleControlCenter: root.toggleControlCenter()
            }
        }

        Item {
            visible: root.section === "right" && root.layoutPreset === "center-menu"
            implicitWidth: rightClock.width + 12
            implicitHeight: root.islandHeight
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: root.islandRadius
                color: root.islandColor()
                border.width: root.showBorder ? root.widgetBorderWidth : 1
                border.color: root.islandBorderColor
            }

            Clock {
                id: rightClock
                anchors.centerIn: parent
                onToggleCalendar: root.toggleCalendar()
            }
        }
    }
}