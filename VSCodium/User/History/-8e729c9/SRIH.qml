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
    

    
    // Inline calendar overlay - positioned within the same parent
    Rectangle {
        id: inlineCalendar
        width: 420
        height: 350
        
        // Position it overlapping the bar itself for now (we know this area is visible)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.topMargin: 50
        
        z: 1000
        visible: clockComponent.popupVisible
        
        color: ThemeManager.surface0
        border.color: ThemeManager.border0
        border.width: 2
        radius: 12
        
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.9
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuart }
        }
        
        // Simplified calendar content for testing
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📅 Calendar Widget"
                font.family: "MapleMono NF"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 40
                
                // Weather section
                Column {
                    spacing: 8
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🌤️"
                        font.pixelSize: 32
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "22°C"
                        font.family: "MapleMono NF"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Partly Cloudy"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
                
                // Time section
                Column {
                    spacing: 8
                    
                    Text {
                        id: popupTime
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "12:34 PM"
                        font.family: "MapleMono NF"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Tuesday, October 15, 2024"
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
            }
            
            // Calendar grid placeholder
            Rectangle {
                width: 200
                height: 150
                anchors.horizontalCenter: parent.horizontalCenter
                color: ThemeManager.surface1
                radius: 6
                border.color: ThemeManager.border0
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "Calendar Grid\n(Interactive calendar\nwould go here)"
                    font.family: "MapleMono NF"
                    font.pixelSize: 11
                    color: ThemeManager.fgSecondary
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        
        // Update time when popup is shown
        Timer {
            interval: 1000
            running: parent.visible
            repeat: true
            triggeredOnStart: true
            
            onTriggered: {
                let now = new Date()
                let hours = now.getHours()
                const minutes = now.getMinutes().toString().padStart(2, '0')
                const ampm = hours >= 12 ? 'PM' : 'AM'
                hours = hours % 12
                hours = hours ? hours : 12
                
                popupTime.text = `${hours}:${minutes} ${ampm}`
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
