import QtQuick
import Quickshell
import Quickshell.Io

MouseArea {
    id: updatesArea
    
    property int updateCount: 0
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: updatesText.width + 16
        height: parent.height - 10
        
        color: updatesArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Row {
            id: updatesText
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "󰚰"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: updatesArea.updateCount.toString()
                font.family: "MapleMono NF"
                font.pixelSize: 13
                color: ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    Process {
        id: updateCheckProcess
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: updateTimer.triggered || updateTimer.running
        
        onExited: {
            if (stdout) {
                updatesArea.updateCount = parseInt(stdout.trim()) || 0
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: 3600000  // 1 hour
        running: true
        repeat: true
        triggeredOnStart: true
        property bool triggered: false
        
        onTriggered: {
            triggered = !triggered
        }
    }
    
    onClicked: {
        Quickshell.execDetached("kitty", ["-e", "sh", "-c", "sudo pacman -Syu; echo Done - Press enter to exit; read"])
    }
}
