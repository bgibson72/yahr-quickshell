import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 800
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property bool enableBlur: false
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
            color: ThemeManager.surface0
            radius: 10
            
            Row {
                anchors.centerIn: parent
                spacing: 8
                
                // Calendar Tab
                Rectangle {
                    width: 150
                    height: 38
                    radius: 8
                    color: root.currentTab === 0 ? ThemeManager.accentBlue : "transparent"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 0
                    }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "📅"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: "Calendar"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: root.currentTab === 0 ? ThemeManager.bgBase : ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // Weather Tab
                Rectangle {
                    width: 150
                    height: 38
                    radius: 8
                    color: root.currentTab === 1 ? ThemeManager.accentBlue : "transparent"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 1
                    }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "⛅"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: "Weather"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: root.currentTab === 1 ? ThemeManager.bgBase : ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // System Tab
                Rectangle {
                    width: 150
                    height: 38
                    radius: 8
                    color: root.currentTab === 2 ? ThemeManager.accentBlue : "transparent"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = 2
                    }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "💻"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: "System"
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: root.currentTab === 2 ? ThemeManager.bgBase : ThemeManager.fgPrimary
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
