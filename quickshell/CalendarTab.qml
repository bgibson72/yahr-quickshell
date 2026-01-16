import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool active: false
    property bool showSeconds: false
    property bool use24HourFormat: true
    property string calendarPaths: "~/.config/quickshell/calendar.ics"
    
    Row {
        anchors.fill: parent
        spacing: 16
        
        // Left: Calendar
        Rectangle {
            width: (parent.width - 16) * 0.55
            height: parent.height
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                // Month/Year Header with Navigation
                Row {
                    width: parent.width
                    height: 40
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: prevMouseArea.containsMouse ? ThemeManager.surface2 : "transparent"
                        
                        MouseArea {
                            id: prevMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendarModel.changeMonth(-1)
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "◀"
                            font.pixelSize: 14
                            color: ThemeManager.fgPrimary
                        }
                    }
                    
                    Item { width: 1; height: 1 }
                    
                    Text {
                        width: parent.width - 80
                        height: parent.height
                        text: calendarModel.monthYearText
                        font.family: "MapleMono NF"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Item { width: 1; height: 1 }
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: nextMouseArea.containsMouse ? ThemeManager.surface2 : "transparent"
                        
                        MouseArea {
                            id: nextMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendarModel.changeMonth(1)
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            font.pixelSize: 14
                            color: ThemeManager.fgPrimary
                        }
                    }
                }
                
                // Calendar Grid
                Grid {
                    width: parent.width
                    columns: 7
                    columnSpacing: 4
                    rowSpacing: 4
                    
                    // Day headers
                    Repeater {
                        model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                        
                        Text {
                            text: modelData
                            font.family: "MapleMono NF"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: ThemeManager.accentBlue
                            width: (parent.parent.width - 24) / 7
                            height: 24
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // Calendar days
                    Repeater {
                        model: 42
                        
                        Rectangle {
                            width: (parent.parent.width - 24) / 7
                            height: 40
                            radius: 8
                            
                            property int dayNumber: calendarModel.getDayNumber(index)
                            property bool isCurrentDay: calendarModel.isToday(index)
                            property bool isSelectedDay: calendarModel.isSelected(index)
                            property bool isValidDay: dayNumber > 0
                            property bool hasEvents: isValidDay && calendarModel.hasEventsOnDay(dayNumber)
                            
                            color: {
                                if (isValidDay && isCurrentDay) return ThemeManager.accentBlue
                                if (isValidDay && isSelectedDay && !isCurrentDay) return ThemeManager.surface2
                                if (dayMouseArea.containsMouse && isValidDay) return Qt.rgba(ThemeManager.surface2.r, ThemeManager.surface2.g, ThemeManager.surface2.b, 0.5)
                                return "transparent"
                            }
                            
                            MouseArea {
                                id: dayMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: parent.isValidDay ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (parent.isValidDay) {
                                        calendarModel.selectDay(parent.dayNumber)
                                    }
                                }
                            }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: parent.parent.isValidDay ? parent.parent.dayNumber : ""
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    color: {
                                        if (parent.parent.isValidDay && parent.parent.isCurrentDay) return ThemeManager.bgBase
                                        if (!parent.parent.isValidDay) return ThemeManager.border0
                                        return ThemeManager.fgPrimary
                                    }
                                    font.weight: parent.parent.isValidDay && parent.parent.isCurrentDay ? Font.Bold : Font.Normal
                                }
                                
                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: parent.parent.parent.isCurrentDay ? ThemeManager.bgBase : ThemeManager.accentCyan
                                    visible: parent.parent.parent.hasEvents
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Right: Events List and Time
        Column {
            width: (parent.width - 16) * 0.45
            height: parent.height
            spacing: 16
            
            // Current Time
            Rectangle {
                width: parent.width
                height: 100
                color: ThemeManager.surface1
                radius: 12
                
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        id: timeDisplay
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 36
                        font.weight: Font.Bold
                        color: ThemeManager.accentBlue
                        text: "12:00"
                    }
                    
                    Text {
                        id: dateDisplay
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                        text: "Wednesday, January 15"
                    }
                }
                
                Timer {
                    interval: 1000
                    running: root.active
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: {
                        let now = new Date()
                        let hours = now.getHours()
                        let minutes = now.getMinutes().toString().padStart(2, '0')
                        let seconds = now.getSeconds().toString().padStart(2, '0')
                        
                        // Handle 12/24 hour format
                        if (!root.use24HourFormat) {
                            let ampm = hours >= 12 ? ' PM' : ' AM'
                            hours = hours % 12
                            if (hours === 0) hours = 12
                            timeDisplay.text = root.showSeconds ? `${hours}:${minutes}:${seconds}${ampm}` : `${hours}:${minutes}${ampm}`
                        } else {
                            timeDisplay.text = root.showSeconds ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}` : `${hours.toString().padStart(2, '0')}:${minutes}`
                        }
                        
                        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        const months = ["January", "February", "March", "April", "May", "June",
                                      "July", "August", "September", "October", "November", "December"]
                        dateDisplay.text = `${days[now.getDay()]}, ${months[now.getMonth()]} ${now.getDate()}`
                    }
                }
            }
            
            // Events List
            Rectangle {
                width: parent.width
                height: parent.height - 116
                color: ThemeManager.surface1
                radius: 12
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Row {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "📋"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: calendarModel.selectedDateText
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 2
                        color: ThemeManager.surface2
                    }
                    
                    // Events scroll area
                    ListView {
                        id: eventsListView
                        width: parent.width
                        height: parent.height - 60
                        clip: true
                        spacing: 8
                        
                        model: calendarModel.eventsModel
                        
                        delegate: Rectangle {
                            width: eventsListView.width
                            height: 70
                            color: ThemeManager.surface0
                            radius: 8
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                Rectangle {
                                    width: 4
                                    height: parent.height
                                    radius: 2
                                    color: modelData.color || ThemeManager.accentBlue
                                }
                                
                                Column {
                                    width: parent.width - 20
                                    spacing: 4
                                    
                                    Text {
                                        width: parent.width
                                        text: modelData.title || "Event"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                        color: ThemeManager.fgPrimary
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: modelData.time || "All day"
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.fgSecondary
                                    }
                                    
                                    Text {
                                        width: parent.width
                                        text: modelData.description || ""
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgTertiary
                                        elide: Text.ElideRight
                                        visible: text !== ""
                                    }
                                }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "No events for this day"
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgTertiary
                            visible: eventsListView.count === 0
                        }
                    }
                }
            }
        }
    }
    
    // Calendar Model
    QtObject {
        id: calendarModel
        
        property int currentMonth: new Date().getMonth()
        property int currentYear: new Date().getFullYear()
        property int selectedDay: new Date().getDate()
        property var eventsModel: []
        property string monthYearText: getMonthYearText()
        property string selectedDateText: getSelectedDateText()
        property var eventDatesCache: ({})  // Cache of dates with events for fast lookup
        
        function getMonthYearText() {
            const months = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
            return `${months[currentMonth]} ${currentYear}`
        }
        
        function getSelectedDateText() {
            const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return `${months[currentMonth]} ${selectedDay}, ${currentYear}`
        }
        
        function changeMonth(delta) {
            currentMonth += delta
            if (currentMonth > 11) {
                currentMonth = 0
                currentYear++
            } else if (currentMonth < 0) {
                currentMonth = 11
                currentYear--
            }
            monthYearText = getMonthYearText()
            loadEvents()
        }
        
        function getDayNumber(index) {
            let firstDay = new Date(currentYear, currentMonth, 1)
            let startOffset = firstDay.getDay()
            let dayNumber = index - startOffset + 1
            let lastDay = new Date(currentYear, currentMonth + 1, 0)
            let daysInMonth = lastDay.getDate()
            
            if (dayNumber >= 1 && dayNumber <= daysInMonth) {
                return dayNumber
            }
            return 0
        }
        
        function isToday(index) {
            let now = new Date()
            let dayNumber = getDayNumber(index)
            return dayNumber > 0 && 
                   dayNumber === now.getDate() && 
                   currentMonth === now.getMonth() && 
                   currentYear === now.getFullYear()
        }
        
        function isSelected(index) {
            let dayNumber = getDayNumber(index)
            return dayNumber > 0 && dayNumber === selectedDay
        }
        
        function hasEventsOnDay(day) {
            // Fast lookup using cached event dates
            let dateKey = `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
            return eventDatesCache[dateKey] === true
        }
        
        function selectDay(day) {
            selectedDay = day
            selectedDateText = getSelectedDateText()
            loadEvents()
        }
        
        function loadEvents() {
            // Load settings first to get calendar paths
            settingsLoader.running = true
        }
    }
    
    // iCal/Calendar file loader
    Process {
        id: icalLoader
        running: false
        command: ["sh", "-c", "echo ''"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                icalLoader.buffer += data
            }
        }
        
        onRunningChanged: {
            if (running) {
                // Build command to load calendar file(s)
                let expandedPaths = root.calendarPaths.replace(/~/g, Quickshell.env("HOME"))
                
                // Support multiple files separated by comma, semicolon, or space
                let paths = expandedPaths.split(/[,;\s]+/).filter(p => p.trim() !== "")
                
                if (paths.length === 0) {
                    paths = [Quickshell.env("HOME") + "/.config/quickshell/calendar.ics"]
                }
                
                // Build command to cat all files that exist
                let catCommands = paths.map(p => `test -f "${p}" && cat "${p}"`).join(" ; ")
                command = ["sh", "-c", catCommands + " || echo ''"]
                console.log("Loading calendars from:", paths.join(", "))
            } else if (!running && buffer !== "") {
                console.log("Calendar data loaded, size:", buffer.length)
                parseICalData(buffer)
                // Don't clear buffer - we need it for hasEventsOnDay checks
            }
        }
        
        function parseICalData(icalContent) {
            // Simple iCal parser for VEVENT entries
            let events = []
            let eventDates = {}
            
            if (!icalContent || icalContent.trim() === "") {
                calendarModel.eventsModel = events
                calendarModel.eventDatesCache = eventDates
                return
            }
            
            let lines = icalContent.split('\n')
            let currentEvent = null
            let selectedDate = new Date(calendarModel.currentYear, calendarModel.currentMonth, calendarModel.selectedDay)
            
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim()
                
                if (line === "BEGIN:VEVENT") {
                    currentEvent = {
                        title: "",
                        description: "",
                        time: "",
                        date: null,
                        color: ThemeManager.accentBlue
                    }
                } else if (line === "END:VEVENT" && currentEvent) {
                    // Check if event is on selected date
                    if (currentEvent.date) {
                        let eventDate = new Date(currentEvent.date)
                        
                        // Add to cache for fast lookup
                        let dateKey = `${eventDate.getFullYear()}-${(eventDate.getMonth() + 1).toString().padStart(2, '0')}-${eventDate.getDate().toString().padStart(2, '0')}`
                        eventDates[dateKey] = true
                        
                        if (eventDate.getDate() === selectedDate.getDate() &&
                            eventDate.getMonth() === selectedDate.getMonth() &&
                            eventDate.getFullYear() === selectedDate.getFullYear()) {
                            events.push(currentEvent)
                        }
                    }
                    currentEvent = null
                } else if (currentEvent) {
                    if (line.startsWith("SUMMARY:")) {
                        currentEvent.title = line.substring(8)
                    } else if (line.startsWith("DESCRIPTION:")) {
                        currentEvent.description = line.substring(12)
                    } else if (line.startsWith("DTSTART")) {
                        // Parse date: DTSTART:20260115T100000 or DTSTART;VALUE=DATE:20260115
                        let dateMatch = line.match(/(\d{8})(T(\d{6}))?/)
                        if (dateMatch) {
                            let dateStr = dateMatch[1]
                            let year = parseInt(dateStr.substring(0, 4))
                            let month = parseInt(dateStr.substring(4, 6)) - 1
                            let day = parseInt(dateStr.substring(6, 8))
                            currentEvent.date = new Date(year, month, day)
                            
                            if (dateMatch[3]) {
                                let timeStr = dateMatch[3]
                                let hour = parseInt(timeStr.substring(0, 2))
                                let minute = parseInt(timeStr.substring(2, 4))
                                currentEvent.time = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`
                            } else {
                                currentEvent.time = "All day"
                            }
                        }
                    }
                }
            }
            
            calendarModel.eventsModel = events
            calendarModel.eventDatesCache = eventDates
        }
    }
        // Settings loader for clock format and calendar paths
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
                        root.showSeconds = settings.general.showSeconds === true
                        root.use24HourFormat = settings.general.clockFormat24hr !== false
                    }
                    if (settings.calendar && settings.calendar.filePath) {
                        root.calendarPaths = settings.calendar.filePath
                    } else {
                        root.calendarPaths = "~/.config/quickshell/calendar.ics"
                    }
                    
                    // Now load calendar files
                    icalLoader.running = true
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
        // Initial load
    Component.onCompleted: {
        if (active) {
            settingsLoader.running = true
            calendarModel.loadEvents()
        }
    }
    
    onActiveChanged: {
        if (active) {
            settingsLoader.running = true
            calendarModel.loadEvents()
        }
    }
}
