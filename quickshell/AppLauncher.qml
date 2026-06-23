import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 1000
    height: 600
    color: ThemeManager.bgBase
    radius: ThemeManager.hyprRounding
    border.width: ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true

    property bool isVisible: false
    property bool enableBlur: false
    property bool showWidgetBorders: true
    property int widgetBorderWidth: 1

    property int selectedIndex: -1
    property int hoverIndex: -1
    property string searchText: ""
    property bool hasLoadedApps: false
    property bool isGridView: true
    property bool isNarrow: root.width < 600

    signal requestClose()
    signal openSettings()

    focus: true

    // ── App data models ──
    ListModel { id: appListModel }
    ListModel { id: filteredModel }

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
        for (const app of apps) {
            filteredModel.append(app)
        }
    }

    // ── Keyboard navigation ──
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

    // ── Load blur/border settings ──
    Process {
        id: blurSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => { blurSettingsLoader.buffer += data }
        }
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general && settings.general.enableBlur !== undefined)
                        root.enableBlur = settings.general.enableBlur
                    if (settings.general && settings.general.showWidgetBorders !== undefined)
                        root.showWidgetBorders = settings.general.showWidgetBorders !== false
                    if (settings.general && settings.general.widgetBorderWidth !== undefined)
                        root.widgetBorderWidth = settings.general.widgetBorderWidth
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // ── Load apps ──
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
                updateFilteredModel()
            }
        }
        onRunningChanged: {
            if (!running) appLoader.running = false
        }
    }

    function loadApps() {
        appListModel.clear()
        appLoader.running = true
    }

    // ── Power action timer ──
    Timer {
        id: powerTimer
        interval: 150
        property string pendingAction: ""
        onTriggered: {
            let cmd = []
            if      (pendingAction === "lock")     cmd = ["hyprlock"]
            else if (pendingAction === "logout")   cmd = ["bash", "-c", "loginctl kill-session $(loginctl show-user $USER -p Display --value)"]
            else if (pendingAction === "suspend")  cmd = ["systemctl", "suspend"]
            else if (pendingAction === "reboot")   cmd = ["systemctl", "reboot"]
            else if (pendingAction === "shutdown") cmd = ["systemctl", "poweroff"]
            if (cmd.length > 0) Quickshell.execDetached(cmd)
            pendingAction = ""
        }
    }

    function executePowerAction(action) {
        root.requestClose()
        powerTimer.pendingAction = action
        powerTimer.start()
    }

    function launchApp(command, needsTerminal) {
        root.requestClose()
        Qt.callLater(() => {
            if (needsTerminal)
                Quickshell.execDetached(["kitty", "-e", "sh", "-c", command])
            else
                Quickshell.execDetached(["sh", "-c", command])
        })
    }

    // ══════════════════════════════════════════════════════
    //  RIGHT: Power sidebar
    // ══════════════════════════════════════════════════════

    Rectangle {
        id: sidebarCard
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: 72
        color: Qt.rgba(1, 1, 1, 0.05)
        radius: ThemeManager.hyprRounding - 2
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)

    Item {
        id: sidebar
        anchors.fill: parent

        // Settings button - top right corner
        Rectangle {
            width: 36
            height: 36
            radius: 8
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 12
            color: settingsLauncherArea.containsMouse
                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                : Qt.rgba(1, 1, 1, 0.06)
            border.width: settingsLauncherArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "\uf013"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: settingsLauncherArea.containsMouse ? ThemeManager.accentBlue : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.6)
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: settingsLauncherArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.requestClose()
                    root.openSettings()
                }
            }
        }

        // All power actions grouped together, vertically centered
        Column {
            anchors.centerIn: parent
            spacing: 6

            // Lock
            Rectangle {
                width: 48; height: 48; radius: 12
                color: lockArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                    : "transparent"
                border.width: lockArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "󰌾"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: lockArea.containsMouse
                        ? ThemeManager.accentBlue
                        : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    id: lockArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.executePowerAction("lock")
                }
            }

            // Logout
            Rectangle {
                width: 48; height: 48; radius: 12
                color: logoutArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                    : "transparent"
                border.width: logoutArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "󰍃"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: logoutArea.containsMouse
                        ? ThemeManager.accentBlue
                        : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    id: logoutArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.executePowerAction("logout")
                }
            }

            // Suspend
            Rectangle {
                width: 48; height: 48; radius: 12
                color: suspendArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25)
                    : "transparent"
                border.width: suspendArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "󰒲"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: suspendArea.containsMouse
                        ? ThemeManager.accentBlue
                        : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    id: suspendArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.executePowerAction("suspend")
                }
            }

            // Divider between session and system actions
            Rectangle {
                width: 36
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Reboot
            Rectangle {
                width: 48; height: 48; radius: 12
                color: rebootArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25)
                    : "transparent"
                border.width: rebootArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "󰜉"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: rebootArea.containsMouse
                        ? ThemeManager.accentRed
                        : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    id: rebootArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.executePowerAction("reboot")
                }
            }

            // Shutdown
            Rectangle {
                width: 48; height: 48; radius: 12
                color: shutdownArea.containsMouse
                    ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25)
                    : "transparent"
                border.width: shutdownArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "󰐥"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: shutdownArea.containsMouse
                        ? ThemeManager.accentRed
                        : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    id: shutdownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.executePowerAction("shutdown")
                }
            }
        }

    }  // Item sidebar

    }  // sidebarCard

    // ══════════════════════════════════════════════════════
    //  LEFT: Search bar + App grid/list
    // ══════════════════════════════════════════════════════

    Rectangle {
        id: mainCard
        anchors.left: parent.left
        anchors.right: sidebarCard.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.rightMargin: 6
        color: Qt.rgba(1, 1, 1, 0.04)
        radius: ThemeManager.hyprRounding - 2
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)
        clip: true

    Item {
        id: mainContent
        anchors.fill: parent

        // ── Search bar ──
        Rectangle {
            id: searchBarRect
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            height: 44
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 10
            border.width: 1
            border.color: searchField.activeFocus
                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.65)
                : Qt.rgba(1, 1, 1, 0.12)
            Behavior on border.color { ColorAnimation { duration: 150 } }

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
                    font.family: ThemeManager.uiFont
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
                        if (filteredModel.count > 0)
                            root.launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                    }
                    Keys.onEnterPressed: {
                        if (filteredModel.count > 0)
                            root.launchApp(filteredModel.get(0).appCommand, filteredModel.get(0).needsTerminal)
                    }
                }
            }
        }

        // ── App content area ──
        Item {
            id: appContentArea
            anchors.top: searchBarRect.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.bottomMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            // ── Grid view ──
            GridView {
                id: appGridView
                anchors.fill: parent
                anchors.bottomMargin: 38
                clip: true
                visible: root.isGridView
                model: filteredModel

                property int cols: root.isNarrow ? 4 : 6
                cellWidth: Math.floor(width / cols)
                cellHeight: root.isNarrow ? 130 : 120

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Item {
                    width: appGridView.cellWidth
                    height: appGridView.cellHeight

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 12

                        Rectangle {
                            width: root.isNarrow ? 76 : 64
                            height: root.isNarrow ? 76 : 64
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: gridItemArea.pressed
                                ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
                                : gridItemArea.containsMouse
                                    ? Qt.rgba(1, 1, 1, 0.10)
                                    : "transparent"
                            radius: 14
                            border.width: gridItemArea.containsMouse ? 1 : 0
                            border.color: Qt.rgba(1, 1, 1, 0.22)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Item {
                                anchors.centerIn: parent
                                width: root.isNarrow ? 54 : 44
                                height: root.isNarrow ? 54 : 44

                                Image {
                                    id: gridIcon
                                    anchors.fill: parent
                                    sourceSize: Qt.size(root.isNarrow ? 54 : 44, root.isNarrow ? 54 : 44)
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                                    visible: status === Image.Ready
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰣆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: root.isNarrow ? 34 : 28
                                    color: ThemeManager.fgPrimary
                                    visible: !gridIcon.visible
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: model.appName
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }

                    MouseArea {
                        id: gridItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }

            // ── List view ──
            ListView {
                id: appListView
                anchors.fill: parent
                anchors.bottomMargin: 38
                clip: true
                visible: !root.isGridView
                model: filteredModel
                spacing: 2

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: listItem
                    width: appListView.width
                    height: 52
                    radius: 10
                    color: listItemArea.containsMouse
                        ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.12)
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    // Icon
                    Item {
                        id: listIconHolder
                        width: 36
                        height: 36
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: listIcon
                            anchors.fill: parent
                            sourceSize: Qt.size(36, 36)
                            smooth: true
                            fillMode: Image.PreserveAspectFit
                            source: model.appIcon.startsWith('/') ? "file://" + model.appIcon : ""
                            visible: status === Image.Ready
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "󰣆"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            color: ThemeManager.fgPrimary
                            visible: !listIcon.visible
                        }
                    }

                    // Name + description
                    Column {
                        anchors.left: listIconHolder.right
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Text {
                            width: parent.width
                            text: model.appName
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: model.appDescription
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 11
                            color: Qt.rgba(ThemeManager.fgSecondary.r, ThemeManager.fgSecondary.g, ThemeManager.fgSecondary.b, 0.60)
                            visible: model.appDescription !== "" && model.appDescription !== model.appName
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: listItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launchApp(model.appCommand, model.needsTerminal)
                    }
                }
            }

            // ── View toggle buttons (bottom-left) ──
            Row {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                spacing: 4

                // Grid view button (Font Awesome table-cells)
                Rectangle {
                    width: 36; height: 36; radius: 8
                    color: root.isGridView
                        ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.28)
                        : (gridToggleHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                    border.width: root.isGridView ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.50)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf00a"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 19
                        color: root.isGridView
                            ? ThemeManager.accentBlue
                            : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: gridToggleHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isGridView = true
                    }
                }

                // List view button (Font Awesome table-list)
                Rectangle {
                    width: 36; height: 36; radius: 8
                    color: !root.isGridView
                        ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.28)
                        : (listToggleHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                    border.width: !root.isGridView ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.50)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf00b"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 19
                        color: !root.isGridView
                            ? ThemeManager.accentBlue
                            : Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.45)
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: listToggleHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isGridView = false
                    }
                }
            }
        }
    }  // mainContent

    }  // mainCard

}
