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
        // Lazy loading: Delay first update check by 10 seconds
        initialDelayTimer.start()
    }
    
    // Startup delay timer - wait 10 seconds before first update check
    Timer {
        id: initialDelayTimer
        interval: 10000  // 10 seconds
        running: false
        repeat: false
        onTriggered: {
            updateCheckProcess.running = true
            lastCheckTime = new Date()
            // Start the regular update timer
            updateTimer.running = true
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Updates clicked! Launching updater...")
            
            // Use a shell script to determine the best update command and launch it in kitty
            let updateScript = 'if command -v paru >/dev/null 2>&1; then ' +
                              'paru -Syu; ' +
                              'elif command -v yay >/dev/null 2>&1; then ' +
                              'yay -Syu; ' +
                              'else ' +
                              'sudo pacman -Syu; ' +
                              'fi; ' +
                              'echo ""; echo "Done - Press enter to exit"; read'
            
            console.log("Launching kitty with update command")
            
            // Launch kitty terminal with update command
            try {
                Quickshell.execDetached([
                    "kitty", 
                    "-e", 
                    "sh", 
                    "-c", 
                    updateScript
                ])
                console.log("Launched updater terminal successfully")
            } catch (error) {
                console.error("Failed to launch updater:", error)
            }
            
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
        // Use dedicated script that checks both official repos and AUR
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/check-updates.sh"]
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
        running: false  // Don't start until after initial delay
        repeat: true
        triggeredOnStart: false
        
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
    
    // Recheck after manual update installation
    Timer {
        id: recheckTimer
        interval: 10000  // 10 seconds after launching updater (gives time to close)
        running: false
        repeat: true  // Keep checking periodically
        
        property int checkCount: 0
        property int maxChecks: 30  // Check for up to 5 minutes (30 * 10 seconds)
        
        onTriggered: {
            checkCount++
            console.log("Rechecking updates after manual installation (attempt", checkCount, "of", maxChecks, ")...")
            lastCheckTime = new Date()
            updateCheckProcess.running = true
            
            // Stop checking after maxChecks attempts or if no updates remain
            if (checkCount >= maxChecks || updatesArea.updateCount === 0) {
                console.log("Stopping recheck timer")
                running = false
                checkCount = 0
            }
        }
        
        onRunningChanged: {
            if (running) {
                checkCount = 0
            }
        }
    }
}
