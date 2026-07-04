import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Compact app picker popup for pinning applications to the Dock.
// Reuses the same list-apps.sh discovery script as AppLauncher.qml.
// Styled to match TrashWidget.qml (header, close button, list container).
Rectangle {
    id: root

    signal appSelected(string desktopId, string name, string icon, string exec, bool terminal)
    signal requestClose()

    property var pinnedIds: []   // desktopIds already pinned, shown as disabled/checked

    width: 360
    height: 440
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, ThemeManager.widgetOpacity)
    radius: ThemeManager.hyprRounding
    border.width: ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    layer.enabled: true
    layer.effect: WidgetShadowEffect {}

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "\uf08d"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Pin an Application"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: headerCloseBtn
                width: 28
                height: 28
                radius: 6
                Layout.alignment: Qt.AlignVCenter
                color: closeMouseArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.28)
                    : Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                border.color: closeMouseArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.55)
                    : Qt.rgba(1, 1, 1, 0.18)
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u2715"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 13
                    color: closeMouseArea.containsMouse ? ThemeManager.accentRed : ThemeManager.fgSecondary
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: 8
            color: Qt.rgba(1, 1, 1, 0.06)
            border.width: searchField.activeFocus ? 1 : 0
            border.color: ThemeManager.accentBlue

            TextInput {
                id: searchField
                anchors.fill: parent
                anchors.margins: 8
                font.family: ThemeManager.uiFont
                font.pixelSize: 12
                color: ThemeManager.fgPrimary
                clip: true
                onTextChanged: root.filterApps()

                Text {
                    text: "Search apps..."
                    font: searchField.font
                    color: ThemeManager.fgTertiary
                    visible: searchField.text.length === 0
                }
            }
        }

        // App list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: ThemeManager.surface0
            radius: 12

            ListView {
                id: appListView
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: ListModel { id: filteredModel }
                spacing: 2

                ScrollBar.vertical: ScrollBar {
                    policy: appListView.count > 8 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                }

                delegate: Rectangle {
                width: appListView.width
                height: 44
                radius: 8
                property bool isPinned: root.pinnedIds.indexOf(model.desktopId) !== -1
                color: rowArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 10

                    Image {
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize: Qt.size(32, 32)
                        smooth: true
                        fillMode: Image.PreserveAspectFit
                        source: model.icon && model.icon.startsWith('/') ? "file://" + model.icon : ""
                        visible: status === Image.Ready
                    }
                    Text {
                        text: "󰣆"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !(model.icon && model.icon.startsWith('/'))
                    }

                    Text {
                        text: model.name
                        font.family: ThemeManager.uiFont
                        font.pixelSize: 12
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 50
                        elide: Text.ElideRight
                    }
                }

                Text {
                    visible: isPinned
                    text: "Pinned"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 10
                    color: ThemeManager.accentGreen
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: isPinned ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (!isPinned) {
                            root.appSelected(model.desktopId, model.name, model.icon, model.exec, model.terminal)
                        }
                    }
                }
            }
            }
        }
    }

    property var allApps: []

    function filterApps() {
        const query = searchField.text.toLowerCase()
        filteredModel.clear()
        for (const app of allApps) {
            if (query.length === 0 || app.name.toLowerCase().indexOf(query) !== -1) {
                filteredModel.append(app)
            }
        }
    }

    Component.onCompleted: {
        root.allApps = []
        appLoader.running = true
    }

    Process {
        id: appLoader
        running: false
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/list-apps.sh"]

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n')
                for (const line of lines) {
                    if (line.trim().length === 0) continue
                    const parts = line.split('|')
                    if (parts.length >= 6) {
                        root.allApps.push({
                            name: parts[0],
                            icon: parts[2],
                            exec: parts[3],
                            terminal: parts[4].toLowerCase() === 'true',
                            desktopId: parts[5]
                        })
                    }
                }
                root.filterApps()
            }
        }
    }
}
