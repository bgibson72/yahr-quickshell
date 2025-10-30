import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: themeSwitcher

    property var themes: []
    property int selectedIndex: -1  // Start with nothing selected
    property int hoverIndex: -1  // Track mouse hover separately
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
                // Don't auto-select current theme, let user navigate with keyboard/mouse
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
            
            implicitWidth: 320
            implicitHeight: themeSwitcher.isVisible ? 500 : 0
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
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
                Keys.onUpPressed: {
                    themeSwitcher.hoverIndex = -1  // Clear hover when using keyboard
                    if (themeSwitcher.selectedIndex === -1) {
                        themeSwitcher.selectedIndex = themeSwitcher.themes.length - 1  // Go to last if nothing selected
                    } else if (themeSwitcher.selectedIndex > 0) {
                        themeSwitcher.selectedIndex--
                    }
                    themeListView.positionViewAtIndex(themeSwitcher.selectedIndex, ListView.Contain)
                }
                Keys.onDownPressed: {
                    themeSwitcher.hoverIndex = -1  // Clear hover when using keyboard
                    if (themeSwitcher.selectedIndex === -1) {
                        themeSwitcher.selectedIndex = 0  // Go to first if nothing selected
                    } else if (themeSwitcher.selectedIndex < themeSwitcher.themes.length - 1) {
                        themeSwitcher.selectedIndex++
                    }
                    themeListView.positionViewAtIndex(themeSwitcher.selectedIndex, ListView.Contain)
                }
                Keys.onReturnPressed: {
                    if (themeSwitcher.selectedIndex === -1) return  // Nothing selected
                    if (themeSwitcher.selectedIndex >= 0 && themeSwitcher.selectedIndex < themeSwitcher.themes.length) {
                        themeSwitcher.applyTheme(themeSwitcher.themes[themeSwitcher.selectedIndex])
                        themeSwitcher.isVisible = false
                    }
                }
                
                Component.onCompleted: {
                    if (themeSwitcher.isVisible) {
                        forceActiveFocus()
                    }
                }
                
                onVisibleChanged: {
                    if (visible) {
                        themeSwitcher.selectedIndex = -1  // Start with nothing selected
                        themeSwitcher.hoverIndex = -1  // Reset hover on open
                        forceActiveFocus()
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    // Header
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: "Select Theme"
                        font.family: "MapleMono NF"
                        font.pixelSize: ThemeManager.fontSizeLarge
                        font.weight: Font.DemiBold
                        color: ThemeManager.fgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    // Inner card for theme list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: ThemeManager.surface0
                        radius: 12
                    
                    // Theme List
                    ListView {
                        id: themeListView
                        anchors.fill: parent
                        anchors.margins: 8
                        model: themeSwitcher.themes
                        currentIndex: themeSwitcher.selectedIndex
                        spacing: 6
                        clip: true
                        
                        delegate: Rectangle {
                            width: themeListView.width
                            height: 46
                            radius: 8
                            color: {
                                if (themeSwitcher.hoverIndex === index) return ThemeManager.accentBlue
                                if (themeSwitcher.hoverIndex === -1 && themeSwitcher.selectedIndex === index) return ThemeManager.accentBlue
                                return "transparent"
                            }
                            
                            MouseArea {
                                id: themeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onEntered: {
                                    themeSwitcher.hoverIndex = index
                                }
                                onExited: {
                                    themeSwitcher.hoverIndex = -1
                                }
                                
                                onClicked: {
                                    themeSwitcher.selectedIndex = index;
                                    themeSwitcher.applyTheme(modelData);
                                    themeSwitcher.isVisible = false;
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.family: "MapleMono NF"
                                font.pixelSize: ThemeManager.fontSizeNormal
                                font.weight: Font.Medium
                                color: {
                                    if (themeSwitcher.hoverIndex === index) return ThemeManager.bgBase
                                    if (themeSwitcher.hoverIndex === -1 && themeSwitcher.selectedIndex === index) return ThemeManager.bgBase
                                    return ThemeManager.fgPrimary
                                }
                                z: 1
                            }
                        }
                    }
                }
                }
            }
        }
    }
}
