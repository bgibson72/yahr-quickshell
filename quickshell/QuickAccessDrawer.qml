import QtQuick
import QtQuick.Layouts

Item {
    id: drawer
    
    property bool expanded: false
    property alias settingsButton: settingsButton
    
    implicitWidth: expanded ? 276 : 32
    implicitHeight: 35
    
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
                color: chevronMouse.pressed
                    ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.45)
                    : chevronMouse.containsMouse
                        ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                        : Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.20)

                border.width: chevronMouse.containsMouse || chevronMouse.pressed ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.width { NumberAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: drawer.expanded ? "\uf054" : "\uf077"
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
            }
            
            // Quick access buttons - only visible when expanded
            Item {
                Layout.preferredWidth: drawer.expanded ? 236 : 0
                Layout.preferredHeight: 32
                clip: true
                visible: drawer.expanded
                
                RowLayout {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    
                    KittyButton {}
                    FilesButton {}
                    FirefoxButton {}
                    WallpaperButton {}
                    ScreenshotButton {}
                    SettingsButton {
                        id: settingsButton
                    }
                }
            }
        }
    }
}
