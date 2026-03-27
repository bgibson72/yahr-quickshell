import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: clockArea
    
    width: clockText.width + 40
    height: parent.height - 10
    
    color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
    radius: 6
    border.width: mouseArea.containsMouse ? 1 : 0
    border.color: Qt.rgba(1, 1, 1, 0.18)

    signal toggleCalendar()

    property bool use24Hour: false
    property bool showSeconds: false
    property bool dateFormatDMY: false
    property bool dateLong: false
    property bool showDayOfWeek: false

    Behavior on color {
        ColorAnimation { duration: 200 }
    }
    Behavior on border.width {
        NumberAnimation { duration: 200 }
    }
    
    Text {
        id: clockText
        anchors.centerIn: parent
        font.family: "Sen"
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
                        clockArea.dateFormatDMY = settings.general.dateFormat === "DMY"
                        clockArea.dateLong = settings.general.dateLong === true
                        clockArea.showDayOfWeek = settings.general.showDayOfWeek === true
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
            let dayNum = now.getDate()
            let year = now.getFullYear()
            let hours = now.getHours()
            let minutes = now.getMinutes().toString().padStart(2, '0')
            let seconds = now.getSeconds().toString().padStart(2, '0')

            // Build date string
            let dateStr
            if (clockArea.dateLong) {
                const monthNames = ["January", "February", "March", "April", "May", "June",
                                    "July", "August", "September", "October", "November", "December"]
                const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                const monthName = monthNames[now.getMonth()]
                let longDate
                if (clockArea.dateFormatDMY) {
                    longDate = `${dayNum} ${monthName} ${year}`
                } else {
                    longDate = `${monthName} ${dayNum}, ${year}`
                }
                if (clockArea.showDayOfWeek) {
                    longDate = `${dayNames[now.getDay()]}, ${longDate}`
                }
                dateStr = longDate
            } else {
                if (clockArea.dateFormatDMY) {
                    dateStr = `${day}/${month}/${year}`
                } else {
                    dateStr = `${month}/${day}/${year}`
                }
            }

            if (clockArea.use24Hour) {
                // 24-hour format
                let timeStr = clockArea.showSeconds 
                    ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                    : `${hours.toString().padStart(2, '0')}:${minutes}`
                clockText.text = `${dateStr}  ${timeStr}`
            } else {
                // 12-hour format with AM/PM
                let ampm = hours >= 12 ? 'PM' : 'AM'
                hours = hours % 12
                hours = hours ? hours : 12
                hours = hours.toString().padStart(2, '0')
                let timeStr = clockArea.showSeconds 
                    ? `${hours}:${minutes}:${seconds}`
                    : `${hours}:${minutes}`
                clockText.text = `${dateStr}  ${timeStr} ${ampm}`
            }
        }
    }
}
