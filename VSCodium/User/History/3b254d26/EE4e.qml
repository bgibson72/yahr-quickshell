import QtQuick
import QtQuick.Layouts

Item {
    id: drawer
    
    property bool expanded: false
    
    // Calculate width based on expanded state
    implicitWidth: expanded ? chevronButton.width + (quickAccessRow.children.length * 32) + ((quickAccessRow.children.length - 1) * 4) + 8 : chevronButton.width
    implicitHeight: 32
    
    Behavior on implicitWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    
    // Container for the drawer content
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            
            // Chevron toggle button
            Rectangle {
                id: chevronButton
                width: 32
                height: 26
                radius: 6
                color: chevronMouse.containsMouse ? 
                    Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.3) :
                    Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.2)
                
                Text {
                    anchors.centerIn: parent
                    text: drawer.expanded ? "" : ""  // right chevron when expanded, up chevron when collapsed
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: ThemeManager.fgPrimary
                }
                
                MouseArea {
                    id: chevronMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        drawer.expanded = !drawer.expanded
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            // Quick access buttons row - slides out from chevron position
            RowLayout {
                id: quickAccessRow
                spacing: 4
                visible: drawer.expanded
                opacity: drawer.expanded ? 1.0 : 0.0
                
                // Scale and slide animation - starts small at chevron position, expands outward
                transform: [
                    Scale {
                        origin.x: 0  // Scale from left edge (chevron position)
                        origin.y: quickAccessRow.height / 2
                        xScale: drawer.expanded ? 1.0 : 0.1
                        yScale: drawer.expanded ? 1.0 : 0.8
                        
                        Behavior on xScale {
                            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                        }
                        Behavior on yScale {
                            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                        }
                    },
                    Translate {
                        x: drawer.expanded ? 0 : -quickAccessRow.width * 0.5
                        
                        Behavior on x {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                ]
                
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                KittyButton {}
                FilesButton {}
                FirefoxButton {}
                WallpaperButton {}
                ScreenshotButton {}
                ThemeButton {}
            }
        }
    }
}