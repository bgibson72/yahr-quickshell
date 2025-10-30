import QtQuick
import QtQuick.Layouts

Item {
    id: drawer
    
    property bool expanded: false
    signal toggleLauncher()
    
    // Calculate width based on expanded state
    implicitWidth: expanded ? chevronButton.width + (quickAccessRow.children.length * 32) + ((quickAccessRow.children.length - 1) * 4) + 8 : chevronButton.width
    implicitHeight: 35
    
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
                height: 32
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
                        console.log("Chevron clicked, toggling drawer")
                        drawer.expanded = !drawer.expanded
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            // Quick access buttons row - slides out from chevron position
            Item {
                width: drawer.expanded ? 220 : 0  // 6 buttons * 32px + 5 gaps * 4px = 212px, rounded to 220
                height: 32
                clip: true  // This ensures buttons don't show when width is 0
                visible: drawer.expanded  // Hide completely when collapsed to prevent click blocking
                
                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                RowLayout {
                    id: quickAccessRow
                    spacing: 4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: drawer.expanded ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
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
}