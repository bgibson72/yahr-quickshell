import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 586
    height: 120
    color: ThemeManager.bgBase
    radius: ThemeManager.hyprRounding
    border.width: ThemeManager.showWidgetBorders ? ThemeManager.widgetBorderWidth : 0
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true
    
    property bool isVisible: false
    property int hoverIndex: -1
    property bool enableBlur: false
    property bool showWidgetBorders: true
    property int widgetBorderWidth: 1
    
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
                    if (settings.general && settings.general.showWidgetBorders !== undefined) {
                        root.showWidgetBorders = settings.general.showWidgetBorders !== false
                    }
                    if (settings.general && settings.general.widgetBorderWidth !== undefined) {
                        root.widgetBorderWidth = settings.general.widgetBorderWidth
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
            color: lockMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: lockMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰌾"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
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
            color: logoutMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: logoutMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰍃"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
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
            color: suspendMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: suspendMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰒲"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
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
            color: rebootMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25) : "transparent"
            radius: 12
            border.width: rebootMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
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
            color: shutdownMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25) : "transparent"
            radius: 12
            border.width: shutdownMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
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
            color: cancelMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
            radius: 12
            border.width: cancelMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.18)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.width {
                NumberAnimation { duration: 150 }
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
