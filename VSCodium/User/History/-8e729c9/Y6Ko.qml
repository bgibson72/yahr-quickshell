import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    property alias clockComponent: clockComponent
    property alias launcherComponent: launcherComponent
    property alias powerComponent: powerComponent
    
    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        ArchButton {}
        WorkspaceBar {}
        Separator {}
        QuickAccessDrawer {
            id: launcherComponent
        }
    }
    
    // CENTER SECTION - Absolutely centered
    Clock {
        id: clockComponent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -28
        anchors.verticalCenter: parent.verticalCenter
    }

    

    
    // RIGHT SECTION
    Item {
        anchors.right: parent.right
        anchors.rightMargin: 8
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
            PowerButton {
                id: powerComponent
            }
        }
    }
}
