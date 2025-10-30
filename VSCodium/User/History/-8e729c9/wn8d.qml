import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    // Global mouse area to close popup when clicking outside
    MouseArea {
        anchors.fill: parent
        enabled: calendarPopup.popupVisible
        z: -1  // Put this behind other elements
        
        onPressed: {
            console.log("Global mouse area clicked - closing popup")
            clockComponent.hidePopup()
            mouse.accepted = true
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
    
    // Debug test button
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 120
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        height: 30
        color: testMouseArea.containsMouse ? "green" : "blue"
        radius: 4
        
        Text {
            anchors.centerIn: parent
            text: "TEST"
            color: "white"
        }
        
        MouseArea {
            id: testMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                console.log("Test button clicked!")
            }
            
            onContainsMouseChanged: {
                console.log("Test button hover:", containsMouse)
            }
        }
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
