import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
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
    

    
    // Simple test popup overlay
    Rectangle {
        id: testPopup
        width: 300
        height: 200
        color: "yellow"
        border.color: "black"
        border.width: 3
        
        x: 200
        y: 60
        z: 1000
        
        visible: clockComponent.popupVisible
        
        Text {
            anchors.centerIn: parent
            text: "TEST POPUP VISIBLE!"
            font.pixelSize: 20
            color: "black"
        }
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
