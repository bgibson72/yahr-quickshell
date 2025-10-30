import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: themeSwitcher

    property var themes: []
    property int selectedIndex: 0
    property string currentTheme: ""

    Process {
        id: themeLoader
        running: true
        command: ["bash", "-c", "ls ~/.config/hypr/themes/*.conf | xargs -n1 basename | sed 's/.conf$//' | sort"]

        stdout: SplitParser {
            onRead: data => {
                const themeList = data.trim().split('\n').filter(t => t.length > 0);
                themeSwitcher.themes = themeList;
                
                // Load current theme
                const currentThemeProc = new Process();
                currentThemeProc.running = true;
                currentThemeProc.command = ["cat", Qt.resolvedUrl("~/.config/hypr/.current-theme").toString().replace("file://", "")];
                currentThemeProc.stdout.connect(function(currentData) {
                    const current = currentData.trim();
                    themeSwitcher.currentTheme = current;
                    const idx = themeList.indexOf(current);
                    if (idx >= 0) {
                        themeSwitcher.selectedIndex = idx;
                    }
                });
            }
        }
    }

    function applyTheme(themeName) {
        const proc = new Process();
        proc.running = true;
        proc.command = [
            "bash", "-c",
            `. ~/.config/quickshell/theme-switcher-quickshell 2>/dev/null; apply_theme "$HOME/.config/hypr/themes/${themeName}.conf" "${themeName}"`
        ];
        console.log("Applying theme:", themeName);
    }

    PanelWindow {
        id: themeSwitcherWindow
        
        anchors {
            top: true
            right: true
        }
        
        margins {
            top: 42
            right: 8
        }
        
        width: 280
        height: visible ? contentHeight : 0
        
        property int contentHeight: 420
        visible: false
        
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        mask: Region {
            item: backgroundRect
        }
        
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: ThemeManager.bgBase
            radius: 8
            border.width: 2
            border.color: ThemeManager.accentBlue
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 0
                
                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Select Theme"
                        font.pixelSize: ThemeManager.fontSizeLarge
                        font.weight: Font.DemiBold
                        color: ThemeManager.fgPrimary
                    }
                }
                
                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.bottomMargin: 4
                    color: ThemeManager.surface1
                }
                
                // Theme List
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: themeListView
                        anchors.fill: parent
                        model: themeSwitcher.themes
                        currentIndex: themeSwitcher.selectedIndex
                        spacing: 4
                        clip: true
                        
                        delegate: Rectangle {
                            width: themeListView.width
                            height: 46
                            radius: 8
                            color: themeSwitcher.selectedIndex === index ? ThemeManager.accentBlue : "transparent"
                            
                            MouseArea {
                                id: themeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    themeSwitcher.selectedIndex = index;
                                    themeSwitcher.applyTheme(modelData);
                                    themeSwitcherWindow.visible = false;
                                }
                            }
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: themeMouseArea.containsMouse && themeSwitcher.selectedIndex !== index 
                                    ? ThemeManager.surface1 
                                    : "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: ThemeManager.fontSizeNormal
                                font.weight: themeSwitcher.selectedIndex === index ? Font.DemiBold : Font.Medium
                                color: themeSwitcher.selectedIndex === index ? ThemeManager.bgBase : ThemeManager.fgPrimary
                            }
                        }
                    }
                }
            }
        }
    }
}
