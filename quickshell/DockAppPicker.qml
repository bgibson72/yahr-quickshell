import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

// Compact app picker popup for pinning applications to the Dock.
// Reuses the same list-apps.sh discovery script as AppLauncher.qml.
Item {
    id: root

    signal appSelected(string desktopId, string name, string icon, string exec, bool terminal)
    signal requestClose()

    property var pinnedIds: []   // desktopIds already pinned, shown as disabled/checked

    width: 360
    height: 440

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: ThemeManager.bgBase
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Row {
            width: parent.width
            Text {
                text: "Pin an Application"
                font.family: ThemeManager.uiFont
                font.pixelSize: 14
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
                width: parent.width - 24
            }
            Text {
                text: "✕"
                font.pixelSize: 14
                color: ThemeManager.fgSecondary
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 34
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

        ListView {
            id: appListView
            width: parent.width
            height: parent.height - 34 - 24 - 20
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

    Component.onCompleted: appLoader.running = true

    Process {
        id: appLoader
        running: false
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/list-apps.sh"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { appLoader.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const lines = buffer.split('\n')
                const apps = []
                for (const line of lines) {
                    if (line.trim().length === 0) continue
                    const parts = line.split('|')
                    if (parts.length >= 6) {
                        apps.push({
                            name: parts[0],
                            icon: parts[2],
                            exec: parts[3],
                            terminal: parts[4].toLowerCase() === 'true',
                            desktopId: parts[5]
                        })
                    }
                }
                root.allApps = apps
                root.filterApps()
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
}
