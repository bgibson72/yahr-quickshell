import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: themeSwitcher

    property var themes: []
    property int selectedIndex: 0
    property string currentTheme: ""
    property bool visible: false

    Component.onCompleted: {
        loadThemes();
    }

    function loadThemes() {
        // Use bash to load themes
        const proc = new Process({
            running: true,
            command: ["bash", "-c", "ls ~/.config/hypr/themes/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//' | sort"]
        });
        
        proc.finished.connect(() => {
            if (proc.exitCode === 0) {
                const themeList = proc.stdout.trim().split('\n').filter(t => t.length > 0);
                themes = themeList;
                
                // Load current theme
                const currentProc = new Process({
                    running: true,
                    command: ["bash", "-c", "cat ~/.config/hypr/.current-theme 2>/dev/null || echo 'Nord'"]
                });
                
                currentProc.finished.connect(() => {
                    if (currentProc.exitCode === 0) {
                        const current = currentProc.stdout.trim();
                        currentTheme = current;
                        const idx = themeList.indexOf(current);
                        if (idx >= 0) {
                            selectedIndex = idx;
                        }
                    }
                });
            }
        });
    }

    function applyTheme(themeName) {
        console.log("Applying theme:", themeName);
        const proc = new Process({
            running: true,
            command: ["bash", "-c", `. ~/.config/quickshell/theme-switcher-quickshell 2>/dev/null; apply_theme "$HOME/.config/hypr/themes/${themeName}.conf" "${themeName}"`]
        });
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: themeSwitcherWindow
            property var modelData
            screen: modelData
            
            anchors {
                top: true
                right: true
            }
            
            margins {
                top: 42
                right: 8
            }
            
            width: 280
            height: themeSwitcher.visible ? contentHeight : 0
            
            property int contentHeight: 420
            visible: themeSwitcher.visible
            
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
                    ListView {
                        id: themeListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 4
                        model: themeSwitcher.themes
                        currentIndex: themeSwitcher.selectedIndex
                        spacing: 4
                        clip: true
                        
                        delegate: Rectangle {
                            width: themeListView.width - 8
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
                                    themeSwitcher.visible = false;
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
