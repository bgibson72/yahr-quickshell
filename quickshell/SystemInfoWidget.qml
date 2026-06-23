import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 900
    height: 700
    color: ThemeManager.bgBase
    radius: ThemeManager.hyprRounding
    border.width: ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true
    
    property bool isVisible: false
    property bool enableBlur: false
    property bool showWidgetBorders: true
    property int widgetBorderWidth: 1
    property int currentTab: 0
    
    signal requestClose()
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    // Load blur setting
    onIsVisibleChanged: {
        if (isVisible) {
            blurSettingsLoader.running = true
        }
    }
    
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
                    if (settings.general && settings.general.showWidgetBorders !== undefined) {
                        root.showWidgetBorders = settings.general.showWidgetBorders !== false
                    }
                    if (settings.general && settings.general.widgetBorderWidth !== undefined) {
                        root.widgetBorderWidth = settings.general.widgetBorderWidth
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // Tab Bar
        Rectangle {
            width: parent.width
            height: 50
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 10
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

            Row {
                id: tabBarRow
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                property real tabWidth: (width - spacing * 2) / 3

                // Calendar Tab
                Rectangle {
                    width: tabBarRow.tabWidth
                    height: parent.height
                    radius: 8
                    color: root.currentTab === 0 ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30) : "transparent"
                    border.width: root.currentTab === 0 ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 0
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\uf073"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: ThemeManager.accentBlue
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Calendar"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Weather Tab
                Rectangle {
                    width: tabBarRow.tabWidth
                    height: parent.height
                    radius: 8
                    color: root.currentTab === 1 ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30) : "transparent"
                    border.width: root.currentTab === 1 ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 1
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\ue302"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: ThemeManager.accentBlue
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Weather"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // System Tab
                Rectangle {
                    width: tabBarRow.tabWidth
                    height: parent.height
                    radius: 8
                    color: root.currentTab === 2 ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30) : "transparent"
                    border.width: root.currentTab === 2 ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 2
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\uf108"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: ThemeManager.accentBlue
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "System"
                            font.family: ThemeManager.uiFont
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

            }
        }
        
        // Tab Content
        Rectangle {
            width: parent.width
            height: parent.height - 66
            color: "transparent"
            
            // Calendar Tab Content
            CalendarTab {
                id: calendarTab
                anchors.fill: parent
                visible: root.currentTab === 0
                active: root.isVisible && root.currentTab === 0
            }
            
            // Weather Tab Content
            WeatherTab {
                id: weatherTab
                anchors.fill: parent
                visible: root.currentTab === 1
                active: root.isVisible && root.currentTab === 1
            }
            
            // System Tab Content
            SystemTab {
                id: systemTab
                anchors.fill: parent
                visible: root.currentTab === 2
                active: root.isVisible && root.currentTab === 2
            }
        }
    }

}
