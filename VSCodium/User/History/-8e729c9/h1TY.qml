import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    property alias clockComponent: clockComponent
    property var shellRoot: null
    
    Component.onCompleted: {
        // Find ShellRoot by objectName
        let item = parent
        while (item) {
            if (item.objectName === "shellRoot") {
                shellRoot = item
                console.log("Bar found ShellRoot!")
                break
            }
            item = item.parent
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
