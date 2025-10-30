import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    // Debug: Change bar background based on popup state
    Rectangle {
        anchors.fill: parent
        color: clockComponent.popupVisible ? "darkblue" : "transparent"
        opacity: 0.3
        z: -1
    }
    
    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        ArchButton {}
        WorkspaceBar {}
        Separator {}
        QuickAccessDrawer {}
    }
    
    // CENTER SECTION - Absolutely centered
    Clock {
        id: clockComponent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -28
        anchors.verticalCenter: parent.verticalCenter
    }
    

    

    
    // RIGHT SECTION
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        
        Updates {}
        SystemTray {}
        PowerButton {}
    }
}
