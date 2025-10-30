import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 200
    height: 340
    color: ThemeManager.surface0
    radius: 16
    
    property bool isVisible: false
    property int selectedIndex: -1  // Hover state only
    
    signal requestClose()
    

    
    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        // Title
        Text {
            width: parent.width
            height: 36
            text: "Power"
            font.family: "MapleMono NF"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: ThemeManager.fgPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        // Power options column
        Column {
            width: parent.width
            spacing: 8
            
            // Lock
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 0 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 0 ? ThemeManager.accentBlue : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰌾"  // lock icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Lock"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 0
                    onClicked: executeAction("lock")
                }
            }
            
            // Logout
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 1 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 1 ? ThemeManager.accentBlue : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰍃"  // logout icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Logout"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 1
                    onClicked: executeAction("logout")
                }
            }
            
            // Suspend
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 2 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 2 ? ThemeManager.accentBlue : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰒲"  // sleep/suspend icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Suspend"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 2
                    onClicked: executeAction("suspend")
                }
            }
            
            // Reboot
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 3 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 3 ? ThemeManager.accentRed : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰜉"  // restart icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Reboot"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 3
                    onClicked: executeAction("reboot")
                }
            }
            
            // Shutdown
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 4 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 4 ? ThemeManager.accentRed : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰐥"  // power icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Shutdown"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 4
                    onClicked: executeAction("shutdown")
                }
            }
            
            // Cancel
            Rectangle {
                width: parent.width
                height: 46
                color: selectedIndex === 5 ? ThemeManager.surface2 : ThemeManager.surface1
                radius: 12
                border.width: 1
                border.color: selectedIndex === 5 ? ThemeManager.accentBlue : "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰜺"  // close/cancel icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Cancel"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: selectedIndex = 5
                    onClicked: {
                        console.log("Cancel clicked, requesting close")
                        root.requestClose()
                    }
                }
            }
        }
    }
    
    // ESC key to close
    Keys.onEscapePressed: {
        console.log("ESC pressed, requesting close")
        root.requestClose()
    }
    
    Timer {
        id: executeTimer
        interval: 150
        property string pendingAction: ""
        onTriggered: {
            let command = []
            if (pendingAction === "lock") command = ["hyprlock"]
            else if (pendingAction === "logout") command = ["hyprctl", "dispatch", "exit"]
            else if (pendingAction === "suspend") command = ["systemctl", "suspend"]
            else if (pendingAction === "reboot") command = ["systemctl", "reboot"]
            else if (pendingAction === "shutdown") command = ["systemctl", "poweroff"]
            
            if (command.length > 0) {
                console.log("Executing command:", command.join(" "))
                Quickshell.execDetached(command)
            }
            pendingAction = ""
        }
    }
    
    function executeAction(action) {
        console.log("Executing power action:", action)
        
        // Request closure
        root.requestClose()
        
        // Use timer to ensure window closes before executing
        executeTimer.pendingAction = action
        executeTimer.start()
    }
    
    Component.onCompleted: {
        // Force initial state
        if (!isVisible) {
            selectedIndex = -1
        }
    }
    
    onIsVisibleChanged: {
        console.log("PowerMenu isVisible changed:", isVisible)
        if (isVisible) {
            selectedIndex = -1  // Reset hover state
            // Cancel any pending timer actions
            if (executeTimer.running) {
                executeTimer.stop()
                executeTimer.pendingAction = ""
            }
        }
    }
}
