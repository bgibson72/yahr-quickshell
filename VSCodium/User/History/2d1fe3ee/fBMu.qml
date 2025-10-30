import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: themeSwitcher

    property var themes: []
    property int selectedIndex: 0
    property string currentTheme: ""
    property bool isVisible: false
    property string themeBuffer: ""

    // Process to load theme list
    Process {
        id: themeLoader
        running: true
        command: ["bash", "-c", "ls ~/.config/hypr/themes/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//' | sort"]
        
        stdout: SplitParser {
            onRead: data => {
                // Accumulate all lines
                themeSwitcher.themeBuffer += data + "\n";
            }
        }
        
        onExited: {
            // Process complete buffer when command finishes
            const lines = themeSwitcher.themeBuffer.trim().split('\n').filter(t => t.length > 0);
            console.log("Loaded", lines.length, "themes:", lines.join(", "));
            themeSwitcher.themes = lines;
            themeSwitcher.themeBuffer = "";  // Clear buffer
        }
    }
    
    Process {
        id: currentThemeLoader
        running: true
        command: ["bash", "-c", "cat ~/.config/hypr/.current-theme 2>/dev/null || echo 'Nord'"]
        
        stdout: SplitParser {
            onRead: data => {
                const current = data.trim();
                themeSwitcher.currentTheme = current;
                const idx = themeSwitcher.themes.indexOf(current);
                if (idx >= 0) {
                    themeSwitcher.selectedIndex = idx;
                }
            }
        }
    }

    function applyTheme(themeName) {
        console.log("Applying theme:", themeName);
        Quickshell.execDetached([
            "bash", "-c",
            `. ~/.config/quickshell/theme-switcher-quickshell 2>/dev/null; apply_theme "$HOME/.config/hypr/themes/${themeName}.conf" "${themeName}"`
        ]);
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: themeSwitcherWindow
            property var modelData
            screen: modelData
            
            visible: themeSwitcher.isVisible
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            margins {
                top: (screen.height - 500) / 2  // Center vertically
                left: (screen.width - 320) / 2   // Center horizontally
                right: (screen.width - 320) / 2  // Center horizontally
            }
            
            width: 320
            height: themeSwitcher.isVisible ? 500 : 0
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            
            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: ThemeManager.bgBase
                radius: 12
                border.width: 3
                border.color: ThemeManager.accentBlue
                antialiasing: true
                
                focus: true
                Keys.onEscapePressed: {
                    themeSwitcher.isVisible = false
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
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
                                    themeSwitcher.isVisible = false;
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
