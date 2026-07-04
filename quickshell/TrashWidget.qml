import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 480
    height: 620
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, ThemeManager.widgetOpacity)
    radius: ThemeManager.hyprRounding
    border.width: ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    layer.enabled: true
    layer.effect: WidgetShadowEffect {}

    property bool isVisible: false
    property var items: []
    property var selectedNames: ([])
    signal requestClose()

    focus: true

    Keys.onEscapePressed: root.requestClose()

    onIsVisibleChanged: {
        if (isVisible) {
            selectedNames = []
            refresh()
        }
    }

    function refresh() {
        trashListLoader.buffer = ""
        trashListLoader.running = true
    }

    function isSelected(name) {
        return root.selectedNames.indexOf(name) !== -1
    }

    function toggleSelected(name) {
        const idx = root.selectedNames.indexOf(name)
        if (idx === -1) root.selectedNames = root.selectedNames.concat([name])
        else root.selectedNames = root.selectedNames.filter(n => n !== name)
    }

    function restoreOne(name) {
        trashActionProcess.pendingRefresh = true
        trashActionProcess.command = ["bash", Quickshell.env("HOME") + "/.config/quickshell/trash-manager.sh", "restore", name]
        trashActionProcess.running = true
    }

    function deleteOne(name) {
        trashActionProcess.pendingRefresh = true
        trashActionProcess.command = ["bash", Quickshell.env("HOME") + "/.config/quickshell/trash-manager.sh", "delete", name]
        trashActionProcess.running = true
    }

    function restoreSelected() {
        const names = root.selectedNames.slice()
        root.selectedNames = []
        for (let i = 0; i < names.length; i++) {
            trashActionProcess.pendingRefresh = (i === names.length - 1)
            trashActionProcess.command = ["bash", Quickshell.env("HOME") + "/.config/quickshell/trash-manager.sh", "restore", names[i]]
            trashActionProcess.running = true
        }
    }

    function emptyTrash() {
        root.selectedNames = []
        trashActionProcess.pendingRefresh = true
        trashActionProcess.command = ["bash", Quickshell.env("HOME") + "/.config/quickshell/trash-manager.sh", "empty"]
        trashActionProcess.running = true
    }

    function humanSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB"
    }

    function formatDate(iso) {
        // DeletionDate is "YYYY-MM-DDTHH:MM:SS" (no timezone, local time)
        const d = new Date(iso)
        if (isNaN(d.getTime())) return iso
        return Qt.formatDateTime(d, "MMM d, h:mm AP")
    }

    // Load trash contents
    Process {
        id: trashListLoader
        running: false
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/trash-manager.sh", "list"]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => { trashListLoader.buffer += data }
        }
        onRunningChanged: {
            if (!running && buffer.trim() !== "") {
                try {
                    root.items = JSON.parse(buffer)
                } catch (e) {
                    root.items = []
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Runs restore/delete/empty actions one at a time
    Process {
        id: trashActionProcess
        running: false
        property bool pendingRefresh: false
        onRunningChanged: {
            if (!running && pendingRefresh) {
                pendingRefresh = false
                root.refresh()
            }
        }
    }

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
                    text: "\uf1f8"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Trash"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 36
                height: 36
                radius: 8
                color: closeMouseArea.containsMouse ? ThemeManager.surface1 : "transparent"
                Layout.alignment: Qt.AlignVCenter

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
                    font.pixelSize: 16
                    color: ThemeManager.fgPrimary
                }
            }
        }

        // List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: ThemeManager.surface0
            radius: 12

            ListView {
                id: trashListView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                clip: true
                model: root.items

                delegate: Rectangle {
                    width: trashListView.width
                    height: 62
                    radius: 8
                    color: itemArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                    border.width: 1
                    border.color: root.isSelected(modelData.name) ? ThemeManager.accentBlue : ThemeManager.surface2

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        anchors.rightMargin: 128
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleSelected(modelData.name)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            Layout.alignment: Qt.AlignVCenter
                            color: root.isSelected(modelData.name) ? ThemeManager.accentBlue : "transparent"
                            border.width: 1
                            border.color: root.isSelected(modelData.name) ? ThemeManager.accentBlue : ThemeManager.surface2

                            Text {
                                anchors.centerIn: parent
                                visible: root.isSelected(modelData.name)
                                text: "\u2713"
                                font.pixelSize: 12
                                color: ThemeManager.bgBase
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleSelected(modelData.name)
                            }
                        }

                        Text {
                            text: modelData.isDir ? "\uf07b" : "\uf15b"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
                            color: ThemeManager.fgSecondary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: ThemeManager.fgPrimary
                                elide: Text.ElideMiddle
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.formatDate(modelData.deletionDate) + "  \u00b7  " + root.humanSize(modelData.size)
                                    + "  \u00b7  " + modelData.origPath
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 10
                                color: ThemeManager.fgTertiary
                                elide: Text.ElideMiddle
                            }
                        }

                        Rectangle {
                            width: 60
                            height: 26
                            radius: 6
                            Layout.alignment: Qt.AlignVCenter
                            color: restoreArea.containsMouse ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: "Restore"
                                font.family: ThemeManager.uiFont
                                font.pixelSize: 10
                                color: restoreArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                            }

                            MouseArea {
                                id: restoreArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.restoreOne(modelData.name)
                            }
                        }

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 6
                            Layout.alignment: Qt.AlignVCenter
                            color: deleteArea.containsMouse ? ThemeManager.accentRed : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: "\uf1f8"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 12
                                color: deleteArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                            }

                            MouseArea {
                                id: deleteArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.deleteOne(modelData.name)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Trash is empty"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 14
                    color: ThemeManager.fgTertiary
                    visible: trashListView.count === 0
                }
            }
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: `${trashListView.count} item${trashListView.count !== 1 ? "s" : ""}`
                    + (root.selectedNames.length > 0 ? `  \u00b7  ${root.selectedNames.length} selected` : "")
                font.family: ThemeManager.uiFont
                font.pixelSize: 12
                color: ThemeManager.fgSecondary
            }

            Rectangle {
                visible: root.selectedNames.length > 0
                width: restoreSelectedLabel.implicitWidth + 24
                height: 32
                radius: 8
                color: restoreSelectedArea.containsMouse ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.08)

                Text {
                    id: restoreSelectedLabel
                    anchors.centerIn: parent
                    text: "Restore Selected"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 12
                    color: restoreSelectedArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                }

                MouseArea {
                    id: restoreSelectedArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.restoreSelected()
                }
            }

            Rectangle {
                width: emptyLabel.implicitWidth + 24
                height: 32
                radius: 8
                color: emptyConfirming ? ThemeManager.accentRed
                    : (emptyArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25) : Qt.rgba(1, 1, 1, 0.08))
                property bool emptyConfirming: false

                Timer {
                    running: parent.emptyConfirming
                    interval: 3000
                    onTriggered: parent.emptyConfirming = false
                }

                Text {
                    id: emptyLabel
                    anchors.centerIn: parent
                    text: parent.emptyConfirming ? "Click again to confirm" : "Empty Trash"
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 12
                    color: ThemeManager.fgPrimary
                }

                MouseArea {
                    id: emptyArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (parent.emptyConfirming) {
                            parent.emptyConfirming = false
                            root.emptyTrash()
                        } else {
                            parent.emptyConfirming = true
                        }
                    }
                }
            }
        }
    }
}
