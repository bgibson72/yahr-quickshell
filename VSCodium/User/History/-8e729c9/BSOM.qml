import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    // Global mouse area to close popup when clicking outside
    MouseArea {
        anchors.fill: parent
        enabled: calendarPopup.popupVisible
        onPressed: {
            // Check if click is outside the popup and clock
            let clickInPopup = calendarPopup.contains(Qt.point(mouse.x - calendarPopup.x, mouse.y - calendarPopup.y))
            let clickInClock = clockComponent.contains(Qt.point(mouse.x - clockComponent.x, mouse.y - clockComponent.y))
            
            if (!clickInPopup && !clickInClock) {
                clockComponent.hidePopup()
            }
            mouse.accepted = false
        }
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
    
    // Calendar and Weather popup
    CalendarWeatherPopup {
        id: calendarPopup
        z: 1000
        popupVisible: clockComponent.popupVisible
        
        // Position popup below the bar
        x: clockComponent.x + clockComponent.width/2 - width/2
        y: parent.height + 10
        
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
