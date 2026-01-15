import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 586
    height: 120
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentBlue
    antialiasing: true
    
    property bool isVisible: false
    property int hoverIndex: -1
    property bool enableBlur: false
    
    signal requestClose()
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    onIsVisibleChanged: {
        if (isVisible) {
            hoverIndex = -1
            root.forceActiveFocus()
            if (executeTimer.running) {
                executeTimer.stop()
                executeTimer.pendingAction = ""
            }
            blurSettingsLoader.running = true
        }
    }
    
    // Load blur setting
    Process {
        id: blurSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                blurSettingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        root.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {}
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Row {
        anchors.centerIn: parent
        spacing: 16
        
        // Lock
        Rectangle {
            width: 70
            height: 70
            color: lockMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰌾"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: lockMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: lockMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("lock")
            }
        }
        
        // Logout
        Rectangle {
            width: 70
            height: 70
            color: logoutMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰍃"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: logoutMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("logout")
            }
        }
        
        // Suspend
        Rectangle {
            width: 70
            height: 70
            color: suspendMouseArea.containsMouse ? ThemeManager.accentBlue : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰒲"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: suspendMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: suspendMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("suspend")
            }
        }
        
        // Reboot
        Rectangle {
            width: 70
            height: 70
            color: rebootMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: rebootMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: rebootMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("reboot")
            }
        }
        
        // Shutdown
        Rectangle {
            width: 70
            height: 70
            color: shutdownMouseArea.containsMouse ? ThemeManager.accentRed : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: shutdownMouseArea.containsMouse ? ThemeManager.bgBase : ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: shutdownMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("shutdown")
            }
        }
        
        // Cancel
        Rectangle {
            width: 70
            height: 70
            color: cancelMouseArea.containsMouse ? ThemeManager.surface0 : "transparent"
            radius: 12
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰜺"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }
            
            MouseArea {
                id: cancelMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestClose()
            }
        }
    }
    
    Timer {
        id: executeTimer
        interval: 150
        property string pendingAction: ""
        onTriggered: {
            let command = []
            if (pendingAction === "lock") command = ["hyprlock"]
            else if (pendingAction === "logout") command = ["bash", "-c", "loginctl kill-session $(loginctl show-user $USER -p Display --value)"]
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
        root.requestClose()
        executeTimer.pendingAction = action
        executeTimer.start()
    }
}
