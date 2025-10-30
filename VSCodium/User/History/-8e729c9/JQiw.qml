import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    property alias clockComponent: clockComponent
    property var rootShell: null  // Will be set by parent
    
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
        
        onToggleCalendar: {
            if (root.rootShell) {
                root.rootShell.calendarVisible = !root.rootShell.calendarVisible
                console.log("Bar received toggle, calendar now:", root.rootShell.calendarVisible)
            } else {
                console.log("ERROR: rootShell is null in Bar")
            }
        }
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
            PowerButton {}
        }
    }
}
