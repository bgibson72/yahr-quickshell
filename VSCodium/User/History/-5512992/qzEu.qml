import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: updatesArea
    
    property int updateCount: 0
    
    width: contentRect.width + 20
    height: 42
    
    color: "transparent"
    
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
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Read data from checkupdates:", data)
                let count = parseInt(data.trim()) || 0
                console.log("Parsed update count:", count)
                updatesArea.updateCount = count
            }
        }
        
        onStarted: {
            console.log("Update check process started")
        }
        
        onExited: (exitCode, exitStatus) => {
            console.log("Process exited with code:", exitCode, "status:", exitStatus)
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
}
