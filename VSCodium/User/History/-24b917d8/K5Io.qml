import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 200
    height: 420
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property int selectedIndex: -1  // Start with nothing selected
    property int hoverIndex: -1  // Track mouse hover separately
    property var actions: ["lock", "logout", "suspend", "reboot", "shutdown", "cancel"]
    
    signal requestClose()
    
    focus: true
    
    // Keyboard navigation
    Keys.onUpPressed: {
        hoverIndex = -1  // Clear hover when using keyboard
        if (selectedIndex === -1) {
            selectedIndex = actions.length - 1  // Go to last item if nothing selected
        } else if (selectedIndex > 0) {
            selectedIndex--
        }
    }
    
    Keys.onDownPressed: {
        hoverIndex = -1  // Clear hover when using keyboard
        if (selectedIndex === -1) {
            selectedIndex = 0  // Go to first item if nothing selected
        } else if (selectedIndex < actions.length - 1) {
            selectedIndex++
        }
    }
    
    Keys.onReturnPressed: {
        if (selectedIndex === -1) return  // Nothing selected
        if (selectedIndex === 5) {  // Cancel
            root.requestClose()
        } else if (selectedIndex >= 0 && selectedIndex < actions.length) {
            executeAction(actions[selectedIndex])
        }
    }
    
    Keys.onEnterPressed: {
        if (selectedIndex === -1) return  // Nothing selected
        if (selectedIndex === 5) {  // Cancel
            root.requestClose()
        } else if (selectedIndex >= 0 && selectedIndex < actions.length) {
            executeAction(actions[selectedIndex])
        }
    }
    
    // Reset selection when widget becomes visible
    onIsVisibleChanged: {
        console.log("PowerMenu isVisible changed:", isVisible)
        if (isVisible) {
            selectedIndex = -1  // Start with nothing selected
            hoverIndex = -1  // Reset hover on open
            root.forceActiveFocus()
            // Cancel any pending timer actions
            if (executeTimer.running) {
                executeTimer.stop()
                executeTimer.pendingAction = ""
            }
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        // Title
        Rectangle {
            width: parent.width
            height: 36
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "Power"
                font.family: "MapleMono NF"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: ThemeManager.fgPrimary
            }
            
            // Close button
            Rectangle {
                width: 28
                height: 28
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 6
                color: closeMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
                border.width: 1
                border.color: closeMouseArea.containsMouse ? ThemeManager.accentRed : ThemeManager.fgSecondary
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.family: "Maple Mono NF"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: closeMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
                }
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
            }
        }
        
        // Inner card for power options
        Rectangle {
            width: parent.width
            height: parent.height - 48
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
            
            // Lock
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 0) return ThemeManager.accentBlue
                    if (root.hoverIndex === -1 && root.selectedIndex === 0) return ThemeManager.accentBlue
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰌾"  // lock icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 0) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 0) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Lock"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 0) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 0) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: lockMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 0 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: executeAction("lock")
                }
            }
            
                        // Logout
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 1) return ThemeManager.accentBlue
                    if (root.hoverIndex === -1 && root.selectedIndex === 1) return ThemeManager.accentBlue
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰍃"  // logout icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 1) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 1) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Logout"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 1) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 1) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 1 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: executeAction("logout")
                }
            }
            
            // Suspend
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 2) return ThemeManager.accentBlue
                    if (root.hoverIndex === -1 && root.selectedIndex === 2) return ThemeManager.accentBlue
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰒲"  // sleep/suspend icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 2) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 2) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Suspend"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 2) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 2) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: suspendMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 2 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: executeAction("suspend")
                }
            }
            
            // Reboot
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 3) return ThemeManager.accentRed
                    if (root.hoverIndex === -1 && root.selectedIndex === 3) return ThemeManager.accentRed
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰜉"  // restart icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 3) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 3) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Reboot"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 3) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 3) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: rebootMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 3 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: executeAction("reboot")
                }
            }
            
            // Shutdown
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 4) return ThemeManager.accentRed
                    if (root.hoverIndex === -1 && root.selectedIndex === 4) return ThemeManager.accentRed
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰐥"  // power icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 4) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 4) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Shutdown"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 4) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 4) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: shutdownMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 4 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: executeAction("shutdown")
                }
            }
            
            // Cancel
            Rectangle {
                width: parent.width
                height: 46
                color: {
                    if (root.hoverIndex === 5) return ThemeManager.accentBlue
                    if (root.hoverIndex === -1 && root.selectedIndex === 5) return ThemeManager.accentBlue
                    return "transparent"
                }
                radius: 8
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰜺"  // close/cancel icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: {
                            if (root.hoverIndex === 5) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 5) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Cancel"
                        font.family: "MapleMono NF"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: {
                            if (root.hoverIndex === 5) return ThemeManager.bgBase
                            if (root.hoverIndex === -1 && root.selectedIndex === 5) return ThemeManager.bgBase
                            return ThemeManager.fgPrimary
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                MouseArea {
                    id: cancelMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: { root.hoverIndex = 5 }
                    onExited: { root.hoverIndex = -1 }
                    onClicked: {
                        console.log("Cancel clicked, requesting close")
                        root.requestClose()
                    }
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
}
