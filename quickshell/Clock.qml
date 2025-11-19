import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: clockArea
    
    width: clockText.width + 40
    height: parent.height - 10
    
    color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
    radius: 6
    
    signal toggleCalendar()
    
    property bool use24Hour: false
    property bool showSeconds: false
    
    Behavior on color {
        ColorAnimation { duration: 200 }
    }
    
    Text {
        id: clockText
        anchors.centerIn: parent
        font.family: "MapleMono NF"
        font.pixelSize: 13
        color: ThemeManager.fgPrimary
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            toggleCalendar()
            console.log("Calendar toggle signal emitted")
        }
    }
    
    // Load settings periodically
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            settingsLoader.running = true
        }
    }
    
    // Settings loader
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                settingsLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general) {
                        clockArea.use24Hour = settings.general.clockFormat24hr === true
                        clockArea.showSeconds = settings.general.showSeconds === true
                    }
                } catch (e) {
                    // Use defaults on error
                    clockArea.use24Hour = false
                    clockArea.showSeconds = false
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            let now = new Date()
            let month = (now.getMonth() + 1).toString().padStart(2, '0')
            let day = now.getDate().toString().padStart(2, '0')
            let year = now.getFullYear()
            let hours = now.getHours()
            let minutes = now.getMinutes().toString().padStart(2, '0')
            let seconds = now.getSeconds().toString().padStart(2, '0')
            
            if (clockArea.use24Hour) {
                // 24-hour format
                let timeStr = clockArea.showSeconds 
                    ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                    : `${hours.toString().padStart(2, '0')}:${minutes}`
                clockText.text = `${month}/${day}/${year}  ${timeStr}`
            } else {
                // 12-hour format with AM/PM
                let ampm = hours >= 12 ? 'PM' : 'AM'
                hours = hours % 12
                hours = hours ? hours : 12
                hours = hours.toString().padStart(2, '0')
                let timeStr = clockArea.showSeconds 
                    ? `${hours}:${minutes}:${seconds}`
                    : `${hours}:${minutes}`
                clockText.text = `${month}/${day}/${year}  ${timeStr} ${ampm}`
            }
        }
    }
}
