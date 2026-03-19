import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 1000
    height: 600
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
    radius: 20
    border.width: 1
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true

    property bool isVisible: false
    property bool enableBlur: false

    property int selectedIndex: -1
    property int hoverIndex: -1
    property string searchText: ""
    property bool hasLoadedApps: false

    signal requestClose()

    focus: true

    // Filtered model for search
    ListModel {
        id: filteredModel
    }

    function updateFilteredModel() {
        filteredModel.clear()
        const search = searchText.toLowerCase()

        let apps = []
        for (let i = 0; i < appListModel.count; i++) {
            const app = appListModel.get(i)
            if (search === "" ||
                app.appName.toLowerCase().includes(search) ||
                app.appDescription.toLowerCase().includes(search)) {
                apps.push({
                    appName: app.appName,
                    appDescription: app.appDescription,
                    appIcon: app.appIcon,
                    appCommand: app.appCommand,
                    needsTerminal: app.needsTerminal
                })
            }
        }

        apps.sort((a, b) => a.appName.toLowerCase().localeCompare(b.appName.toLowerCase()))

        for (let app of apps) {
            filteredModel.append(app)
        }
    }

    // Keyboard navigation
    Keys.onEscapePressed: {
        if (searchText !== "") {
            searchText = ""
            searchField.text = ""
        } else {
            requestClose()
        }
    }

    Keys.onPressed: (event) => {
        if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z && !event.modifiers) {
            searchField.forceActiveFocus()
        }
    }

    onIsVisibleChanged: {
        if (isVisible) {
            selectedIndex = -1
            hoverIndex = -1
            searchText = ""
            searchField.text = ""
            if (!hasLoadedApps) {
                hasLoadedApps = true
                loadApps()
            }
            blurSettingsLoader.running = true
        }
    }

    onSearchTextChanged: updateFilteredModel()

    // Load blur setting
    Process {
        id: blurSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                blurSettingsLoader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        root.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Process to load apps
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
                    if (parts.length >= 4) {
                        appListModel.append({
                            appName: parts[0],
                            appDescription: parts[1],
                            appIcon: parts[2],
                            appCommand: parts[3],
                            needsTerminal: parts.length >= 5 ? (parts[4].toLowerCase() === 'true') : false
                        })
                    }
                }
                console.log("Loaded", appListModel.count, "applications")
                updateFilteredModel()
            }
        }

        onRunningChanged: {
            if (!running) {
                appLoader.running = false
            }
        }
    }

    function loadApps() {
        appListModel.clear()
        appLoader.running = true
    }

    Component.onCompleted: {
        // Apps will load when first opened via onIsVisibleChanged
    }

    // ── Top specular gradient – simulates light catching the glass edge ──
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        radius: parent.radius
        color: "transparent"
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.07) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.00) }
        }
    }

    // ── Bottom fade – adds depth to the panel ──
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        radius: parent.radius
        color: "transparent"
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.00) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.12) }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // ── Search field ──
        Rectangle {
            width: parent.width
            height: 44
            color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.35)
            radius: 12
            border.width: 1
            border.color: searchField.activeFocus
                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.65)
                : Qt.rgba(1, 1, 1, 0.12)

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Qt.rgba(ThemeManager.fgSecondary.r, ThemeManager.fgSecondary.g, ThemeManager.fgSecondary.b, 0.55)
                }

                TextInput {
                    id: searchField
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Sen"
                    font.pixelSize: 13
                    color: ThemeManager.fgPrimary
                    selectionColor: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.45)
                    selectedTextColor: ThemeManager.fgPrimary

                    Text {
                        anchors.fill: parent
                        text: "Search applications..."
                        font: searchField.font
                        color: Qt.rgba(ThemeManager.fgTertiary.r, ThemeManager.fgTertiary.g, ThemeManager.fgTertiary.b, 0.50)
                        visible: !searchField.text && !searchField.activeFocus
                    }

                    onTextChanged: root.searchText = text

                    Keys.onReturnPressed: {
                        if (filteredModel.count > 0) {
                            launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                        }
                    }
                    Keys.onEnterPressed: {
                        if (filteredModel.count > 0) {
                            launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                        }
                    }
                }
            }
        }

        // ── App grid ──
        Item {
            width: parent.width
            height: parent.height - 58

            // Base grid (all apps)
            GridView {
                id: gridView
                anchors.fill: parent
                cellWidth: width / 6
                cellHeight: 120
                clip: true
                visible: root.searchText === ""

                model: ListModel {
                    id: appListModel
                }

                delegate: Item {
                    width: gridView.cellWidth
                    height: gridView.cellHeight

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 12

                        // Glass icon card
                        Rectangle {
                            width: 68
                            height: 68
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: appMouseArea.pressed
                                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
                                : appMouseArea.containsMouse
                                    ? Qt.rgba(1, 1, 1, 0.10)
                                    : "transparent"
                            radius: 14
                            border.width: appMouseArea.containsMouse ? 1 : 0
                            border.color: Qt.rgba(1, 1, 1, 0.22)

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Item {
                                anchors.centerIn: parent
                                width: 48
                                height: 48

                                Image {
                                    id: appIconImage
                                    anchors.fill: parent
                                    sourceSize.width: 48
                                    sourceSize.height: 48
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 32
                                    color: ThemeManager.fgPrimary
                                    visible: !appIconImage.visible
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: model.appName
                            font.family: "Sen"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }

                    MouseArea {
                        id: appMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }

            // Filtered grid (search results)
            GridView {
                id: filteredGridView
                anchors.fill: parent
                cellWidth: width / 6
                cellHeight: 120
                clip: true
                visible: root.searchText !== ""

                model: filteredModel

                delegate: Item {
                    width: filteredGridView.cellWidth
                    height: filteredGridView.cellHeight

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 12

                        Rectangle {
                            width: 68
                            height: 68
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: filteredMouseArea.pressed
                                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
                                : filteredMouseArea.containsMouse
                                    ? Qt.rgba(1, 1, 1, 0.10)
                                    : "transparent"
                            radius: 14
                            border.width: filteredMouseArea.containsMouse ? 1 : 0
                            border.color: Qt.rgba(1, 1, 1, 0.22)

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.30)
                                visible: filteredMouseArea.containsMouse
                                radius: parent.radius
                            }

                            Item {
                                anchors.centerIn: parent
                                width: 48
                                height: 48

                                Image {
                                    id: filteredIconImage
                                    anchors.fill: parent
                                    sourceSize.width: 48
                                    sourceSize.height: 48
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 32
                                    color: ThemeManager.fgPrimary
                                    visible: !filteredIconImage.visible
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: model.appName
                            font.family: "Sen"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }

                    MouseArea {
                        id: filteredMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }
        }
    }

    function launchApp(command, needsTerminal) {
        console.log("Launching app:", command, "(Terminal:", needsTerminal, ")")
        root.requestClose()
        Qt.callLater(() => {
            if (needsTerminal) {
                Quickshell.execDetached(["hyprctl", "dispatch", "exec", "kitty -e sh -c '" + command + "'"])
            } else {
                Quickshell.execDetached(["hyprctl", "dispatch", "exec", command])
            }
        })
    }
}
