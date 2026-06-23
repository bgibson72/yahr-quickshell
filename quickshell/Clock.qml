import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: clockArea

    width: clockRow.width + 40
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
    property bool showWeatherInBar: false

    property string barWeatherIcon: "\ue302"
    property string barWeatherTemp: "--"

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.width { NumberAnimation { duration: 200 } }

    function getWeatherNFIcon(emoji) {
        if (!emoji) return "\ue30d"
        if (emoji.indexOf("\u2600") >= 0) return "\ue30d"
        if (emoji.indexOf("\u26C5") >= 0 || emoji.indexOf("\u2601") >= 0) return "\ue302"
        if (emoji.indexOf("\u{1F324}") >= 0) return "\ue302"
        if (emoji.indexOf("\u{1F325}") >= 0) return "\ue312"
        if (emoji.indexOf("\u{1F326}") >= 0) return "\ue309"
        if (emoji.indexOf("\u{1F327}") >= 0) return "\ue308"
        if (emoji.indexOf("\u26C8") >= 0 || emoji.indexOf("\u{1F329}") >= 0) return "\ue30f"
        if (emoji.indexOf("\u{1F328}") >= 0 || emoji.indexOf("\u2744") >= 0) return "\ue30a"
        if (emoji.indexOf("\u{1F32B}") >= 0) return "\ue313"
        if (emoji.indexOf("\u{1F32C}") >= 0) return "\ue34b"
        return "\ue30d"
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: dateText
            font.family: ThemeManager.uiFont
            font.pixelSize: ThemeManager.barLarge ? 16 : 13
            color: ThemeManager.fgPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: barWeatherIconText
            visible: clockArea.showWeatherInBar
            text: clockArea.barWeatherIcon
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.barLarge ? 15 : 12
            color: ThemeManager.accentBlue
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: barWeatherTempText
            visible: clockArea.showWeatherInBar
            text: clockArea.barWeatherTemp
            font.family: ThemeManager.uiFont
            font.pixelSize: ThemeManager.barLarge ? 16 : 13
            color: ThemeManager.fgPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: timeText
            font.family: ThemeManager.uiFont
            font.pixelSize: ThemeManager.barLarge ? 16 : 13
            color: ThemeManager.fgPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { settingsLoader.running = true }
    }

    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { settingsLoader.buffer += data }
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
                    if (settings.bar) {
                        const newShowWeather = settings.bar.showWeatherInBar === true
                        if (newShowWeather && !clockArea.showWeatherInBar) {
                            weatherProcess.running = true
                        }
                        clockArea.showWeatherInBar = newShowWeather
                    }
                } catch (e) {
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
        id: weatherTimer
        interval: 600000
        running: clockArea.showWeatherInBar
        repeat: true
        triggeredOnStart: true
        onTriggered: { weatherProcess.running = true }
    }

    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t'"]
        running: false
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { weatherProcess.buffer += data }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                const parts = weatherProcess.buffer.trim().split("|")
                if (parts.length >= 2) {
                    clockArea.barWeatherIcon = clockArea.getWeatherNFIcon(parts[0].trim())
                    clockArea.barWeatherTemp = parts[1].trim().replace(/^\+/, "")
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
                let timeStr = clockArea.showSeconds
                    ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                    : `${hours.toString().padStart(2, '0')}:${minutes}`
                dateText.text = dateStr
                timeText.text = timeStr
            } else {
                let ampm = hours >= 12 ? 'PM' : 'AM'
                hours = hours % 12
                hours = hours ? hours : 12
                hours = hours.toString().padStart(2, '0')
                let timeStr = clockArea.showSeconds
                    ? `${hours}:${minutes}:${seconds}`
                    : `${hours}:${minutes}`
                dateText.text = dateStr
                timeText.text = `${timeStr} ${ampm}`
            }
        }
    }
}
