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
        
        Connections {
            target: clockComponent
            function onPopupVisibleChanged() {
                if (clockComponent.popupVisible) {
                    calendarPopup.show(clockComponent)
                } else {
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
