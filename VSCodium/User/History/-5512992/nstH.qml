import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: updatesArea
    
    property int updateCount: 0
    property var lastCheckTime: new Date()
    
    width: contentRect.width + 20
    height: 35
    
    color: "transparent"
    
    Component.onCompleted: {
        updateCheckProcess.running = true
        lastCheckTime = new Date()
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Updates clicked! Launching updater...")
            let proc = Quickshell.execDetached(["kitty", "-e", "sh", "-c", "sudo pacman -Syu; echo 'Done - Press enter to exit'; read"])
            // Trigger a recheck after a short delay (user might close terminal)
            recheckTimer.start()
        }
        
        Rectangle {
            id: contentRect
            anchors.centerIn: parent
            width: 60  // Wider for icon + number
            height: 32
            
            color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
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
    }
    
    Process {
        id: updateCheckProcess
        // Use checkupdates (from pacman-contrib) which syncs databases to /tmp and checks
        // This is safer than pacman -Sy and doesn't require root
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Read data from update check:", data)
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
            // Restart the check if it failed (might be network issue)
            if (exitCode !== 0 && !updateTimer.running) {
                // Don't spam retries, just wait for next timer interval
                console.log("Update check failed, will retry on next timer")
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: 3600000  // 1 hour
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            console.log("Update timer triggered")
            lastCheckTime = new Date()
            updateCheckProcess.running = true
        }
    }
    
    // Wake-from-sleep detection timer - checks every 5 minutes
    // If more than 10 minutes have passed since last check, we probably woke from sleep
    Timer {
        id: wakeDetectionTimer
        interval: 300000  // 5 minutes
        running: true
        repeat: true
        
        onTriggered: {
            let now = new Date()
            let timeSinceLastCheck = (now - lastCheckTime) / 1000 / 60  // minutes
            
            if (timeSinceLastCheck > 10) {
                console.log("Detected wake from sleep (", timeSinceLastCheck, "minutes since last check). Triggering update check...")
                lastCheckTime = now
                updateCheckProcess.running = true
            }
        }
    }
}
