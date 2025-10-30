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
    
    Component.onCompleted: {
        updateCheckProcess.running = true
    }
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: 60  // Wider for icon + number
        height: 32
        
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
                color: updatesArea.updateCount > 0 ? ThemeManager.accentYellow : ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
            
            Text {
                text: updatesArea.updateCount.toString()
                font.family: "MapleMono NF"
                font.pixelSize: 13
                color: updatesArea.updateCount > 0 ? ThemeManager.accentYellow : ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
    }
    
    Process {
        id: updateCheckProcess
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        
        onExited: {
            console.log("Update check process exited. stdout:", stdout, "stderr:", stderr)
            if (stdout) {
                let count = parseInt(stdout.trim()) || 0
                console.log("Parsed update count:", count)
                updatesArea.updateCount = count
            }
        }
        
        onStarted: {
            console.log("Update check process started")
        }
    }
    
    Timer {
        id: updateTimer
        interval: 3600000  // 1 hour
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            updateCheckProcess.running = true
        }
    }
    
    onClicked: {
        Quickshell.execDetached(["kitty", "-e", "sh", "-c", "sudo pacman -Syu; echo Done - Press enter to exit; read"])
    }
}
