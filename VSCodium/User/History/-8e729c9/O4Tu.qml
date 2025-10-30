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
    

    
    // Calendar and Weather popup
    CalendarWeatherPopup {
        id: calendarPopup
        popupVisible: clockComponent.popupVisible
        
        // Position popup at fixed location for testing
        x: 100
        y: 60
        z: 1000
        
        Component.onCompleted: {
            console.log("CalendarWeatherPopup created successfully")
        }
        
        Connections {
            target: clockComponent
            function onPopupVisibleChanged() {
                console.log("Clock popupVisible changed to:", clockComponent.popupVisible)
                if (clockComponent.popupVisible) {
                    console.log("Calling calendarPopup.show()")
                    calendarPopup.show(clockComponent)
                } else {
                    console.log("Calling calendarPopup.hide()")
                    calendarPopup.hide()
                }
            }
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
