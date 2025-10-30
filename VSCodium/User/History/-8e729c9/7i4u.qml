import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    required property var notificationService
    property bool dndEnabled: false
    
    property alias clockComponent: clockComponent
    property alias archComponent: archComponent
    property alias powerComponent: powerComponent
    property alias settingsButtonComponent: quickAccessDrawer.settingsButton
    property alias notificationComponent: notificationComponent
    
    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        ArchButton {
            id: archComponent
        }
        WorkspaceBar {}
        Separator {}
        QuickAccessDrawer {
            id: quickAccessDrawer
        }
    }
    
    // CENTER SECTION - Absolutely centered
    Clock {
        id: clockComponent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    

    
    // RIGHT SECTION
    Item {
        anchors.right: parent.right
        anchors.rightMargin: -2
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: rightRow.width
        
        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            
            Updates {}
            SystemTray {}
            NotificationIndicator {
                id: notificationComponent
                dndMode: root.dndEnabled
                onClicked: {
                    // Will be handled by Connections in shell.qml
                }
            }
            PowerButton {
                id: powerComponent
            }
        }
    }
}
