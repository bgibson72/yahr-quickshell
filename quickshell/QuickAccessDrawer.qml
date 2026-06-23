import QtQuick
import QtQuick.Layouts

Item {
    id: drawer
    
    property bool expanded: false
    property bool forceExpanded: false
    property bool hideChevron: false

    signal toggleSettings()

    readonly property bool isExpanded: forceExpanded || expanded

    width: implicitWidth
    height: implicitHeight
    implicitWidth: isExpanded ? (hideChevron ? 176 : 212) : 32
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
                visible: !drawer.hideChevron
                width: visible ? 32 : 0
                height: visible ? 32 : 0
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
                    text: drawer.isExpanded ? "\uf054" : "\uf077"
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
                        if (drawer.forceExpanded) return
                        drawer.expanded = !drawer.expanded
                    }
                }
            }
            
            // Quick access buttons - only visible when expanded
            Item {
                Layout.preferredWidth: drawer.isExpanded ? 176 : 0
                Layout.preferredHeight: 32
                clip: true
                visible: drawer.isExpanded
                
                RowLayout {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    
                    KittyButton {}
                    FilesButton {}
                    FirefoxButton {}
                    ScreenshotButton {}
                    SettingsButton { onClicked: drawer.toggleSettings() }
                }
            }
        }
    }
}
