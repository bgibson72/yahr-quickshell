import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool active: false
    property bool showSeconds: false
    property bool use24HourFormat: true
    property string calendarPaths: "~/.config/quickshell/calendar.ics"
    property int refreshInterval: 15
    property bool hasLoadedOnce: false
    
    // Reload settings when panel becomes active
    onActiveChanged: {
        if (active) {
            settingsLoader.running = true
            // Lazy load: only load calendar events when first opened
            if (!hasLoadedOnce) {
                hasLoadedOnce = true
                calendarModel.loadEvents()
            }
        }
    }
    
    // Settings loader - delayed start for performance
    Component.onCompleted: {
        // Delay initial settings load by 1 second
        Qt.callLater(() => {
            settingsLoader.running = true
        })
    }
    
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
                        root.showSeconds = settings.general.showSeconds === true
                        root.use24HourFormat = settings.general.clockFormat24hr !== false
                        updateClock()
                    }
                    if (settings.calendar && settings.calendar.filePath) {
                        root.calendarPaths = settings.calendar.filePath
                        calendarModel.triggerCalendarLoad()
                    }
                    if (settings.calendar && settings.calendar.refreshInterval !== undefined) {
                        root.refreshInterval = settings.calendar.refreshInterval
                    }
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
                buffer = ""
            }
        }
    }
    
    function updateClock() {
        let now = new Date()
        let hours = now.getHours()
        let minutes = now.getMinutes().toString().padStart(2, '0')
        let seconds = now.getSeconds().toString().padStart(2, '0')
        
        if (root.use24HourFormat) {
            timeText.text = root.showSeconds 
                ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                : `${hours.toString().padStart(2, '0')}:${minutes}`
            periodText.text = ""
        } else {
            let period = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            timeText.text = root.showSeconds 
                ? `${hours.toString().padStart(2, '0')}:${minutes}:${seconds}`
                : `${hours.toString().padStart(2, '0')}:${minutes}`
            periodText.text = period
        }
        
        // Update date
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        const months = ["January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        dateText.text = `${days[now.getDay()]}, ${months[now.getMonth()]} ${now.getDate()}`
        yearText.text = now.getFullYear().toString()
    }
    
    Column {
        anchors.fill: parent
        spacing: 16
        
        // Top: Clock Banner (full width)
        Rectangle {
            width: parent.width
            height: 80
            color: ThemeManager.surface1
            radius: 12
            
            Row {
                anchors.centerIn: parent
                spacing: 24
                
                // Time
                Row {
                    spacing: 8
                    
                    Text {
                        id: timeText
                        font.family: "MapleMono NF"
                        font.pixelSize: 40
                        font.weight: Font.Bold
                        color: ThemeManager.accentBlue
                        text: "10:42:18"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        id: periodText
                        font.family: "MapleMono NF"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: ThemeManager.fgSecondary
                        text: "AM"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -8
                        visible: text !== ""
                    }
                }
                
                // Separator
                Rectangle {
                    width: 2
                    height: 50
                    color: ThemeManager.surface2
                }
                
                // Date
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        id: dateText
                        font.family: "MapleMono NF"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        text: "Sunday, January 19"
                    }
                    
                    Text {
                        id: yearText
                        font.family: "MapleMono NF"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                        text: "2026"
                    }
                }
            }
            
            Timer {
                interval: 1000
                running: root.active
                repeat: true
                triggeredOnStart: true
                onTriggered: root.updateClock()
            }
            
            // Auto-refresh timer for calendar data
            Timer {
                id: calendarRefreshTimer
                interval: root.refreshInterval * 60000  // Convert minutes to milliseconds
                running: root.active && root.refreshInterval > 0
                repeat: true
                triggeredOnStart: false
                onTriggered: {
                    console.log("🔄 Auto-refreshing calendar data...")
                    calendarModel.triggerCalendarLoad()
                }
            }
        }
        
        // Bottom: Calendar and Events Row
        Row {
            width: parent.width
            height: parent.height - 96
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
                spacing: 8
                
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
                            height: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // Calendar days
                    Repeater {
                        id: calendarRepeater
                        model: 42
                        
                        Rectangle {
                            width: (parent.parent.width - 24) / 7
                            height: 35
                            radius: 8
                            objectName: "calendarDay_" + index
                            
                            property int dayNumber: calendarModel.getDayNumber(index)
                            property bool isCurrentDay: calendarModel.isToday(index)
                            property bool isSelectedDay: calendarModel.isSelected(index)
                            property bool isValidDay: dayNumber > 0
                            property string dateKey: isValidDay ? `${calendarModel.currentYear}-${(calendarModel.currentMonth + 1).toString().padStart(2, '0')}-${dayNumber.toString().padStart(2, '0')}` : ""
                            property bool hasEvents: false
                            
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
                                    id: eventDot
                                    width: 6
                                    height: 6
                                    radius: 3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: parent.parent.parent.isCurrentDay ? ThemeManager.bgBase : ThemeManager.accentCyan
                                    visible: false
                                }
                            }
                        }
                    }
                }
                
                // Moon Phase and Sun Times
                Rectangle {
                    width: parent.width
                    height: 55
                    color: ThemeManager.surface0
                    radius: 8
                    
                    Row {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Moon Phase - left side
                        Item {
                            width: (parent.width - 2) / 2
                            height: parent.height
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: calendarModel.moonPhaseEmoji
                                    font.family: "Noto Color Emoji"
                                    font.pixelSize: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Column {
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        text: calendarModel.moonPhaseName
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        color: ThemeManager.fgPrimary
                                    }
                                    
                                    Text {
                                        text: calendarModel.moonIllumination
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgSecondary
                                    }
                                }
                            }
                        }
                        
                        // Separator
                        Rectangle {
                            width: 2
                            height: 36
                            color: ThemeManager.surface2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        // Sunrise/Sunset - right side
                        Item {
                            width: (parent.width - 2) / 2
                            height: parent.height
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 8
                                    
                                    Text {
                                        text: "🌅"
                                        font.family: "Noto Color Emoji"
                                        font.pixelSize: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: calendarModel.sunriseTime
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.accentYellow
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 8
                                    
                                    Text {
                                        text: "🌇"
                                        font.family: "Noto Color Emoji"
                                        font.pixelSize: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: calendarModel.sunsetTime
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 12
                                        color: ThemeManager.accentOrange
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Right: Events List
        Rectangle {
            width: (parent.width - 16) * 0.45
            height: parent.height
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
        property var allEventsCache: []  // Cache of all events with their dates
        property int eventsRevision: 0  // Increment to trigger grid updates
        
        // Moon phase and sun times
        property string moonPhaseName: "New Moon"
        property string moonPhaseEmoji: "🌑"
        property string moonIllumination: "0%"
        property string sunriseTime: "7:15 AM"
        property string sunsetTime: "4:50 PM"
        
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
            
            // Rebuild cache for new month
            if (allEventsCache.length > 0) {
                buildEventCacheForMonth(currentYear, currentMonth)
                eventsRevision++
            }
            
            updateMoonPhase()
            filterEventsForSelectedDay()
            // Update dots when month changes
            Qt.callLater(updateEventDots)
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
        
        function hasEventsOnDay(day, revision) {
            // Fast lookup using cached event dates (revision param tracks changes)
            if (!day || !eventDatesCache || typeof eventDatesCache !== 'object') {
                return false
            }
            let dateKey = `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
            return (eventDatesCache[dateKey] === true) || false
        }
        
        function selectDay(day) {
            selectedDay = day
            selectedDateText = getSelectedDateText()
            filterEventsForSelectedDay()
        }
        
        function filterEventsForSelectedDay() {
            let selectedDate = new Date(currentYear, currentMonth, selectedDay)
            let filtered = []
            
            for (let i = 0; i < allEventsCache.length; i++) {
                let evt = allEventsCache[i]
                
                // Check if event occurs on selected date
                if (evt.rrule) {
                    // Recurring event - check if it occurs on selected date
                    if (icalLoader.checkRecurringEvent(evt, selectedDate)) {
                        filtered.push(evt)
                    }
                } else if (evt.date) {
                    // Single event - check if date matches
                    let eventDate = new Date(evt.date)
                    if (eventDate.getDate() === selectedDate.getDate() &&
                        eventDate.getMonth() === selectedDate.getMonth() &&
                        eventDate.getFullYear() === selectedDate.getFullYear()) {
                        filtered.push(evt)
                    }
                }
            }
            
            eventsModel = filtered
            console.log("📅 Filtered events for", selectedDateText, ":", filtered.length, "events")
        }
        
        function loadEvents() {
            // Load settings first to get calendar paths, then trigger calendar load
            settingsLoader.running = true
        }
        
        function updateEventDots() {
            // Manually update each calendar day's hasEvents property and dot visibility
            let dotsShown = 0
            for (let i = 0; i < 42; i++) {
                let dayItem = calendarRepeater.itemAt(i)
                if (dayItem && dayItem.isValidDay) {
                    let hasEventOnDay = eventDatesCache[dayItem.dateKey] === true
                    dayItem.hasEvents = hasEventOnDay
                    // Find the event dot: Rectangle has [MouseArea, Column] as children
                    // Column has [Text, Rectangle(dot)] as children
                    if (dayItem.children && dayItem.children.length > 1) {
                        let column = dayItem.children[1]  // Column is second child (after MouseArea)
                        if (column && column.children && column.children.length > 1) {
                            let dot = column.children[1]  // Event dot is second child in Column
                            if (dot) {
                                dot.visible = hasEventOnDay
                                if (hasEventOnDay) dotsShown++
                            }
                        }
                    }
                }
            }
        }
        
        function buildEventCacheForMonth(year, month) {
            // Build event cache only for the specified month (much faster)
            let firstDay = new Date(year, month, 1)
            let lastDay = new Date(year, month + 1, 0)
            let currentDate = new Date(firstDay)
            
            while (currentDate <= lastDay) {
                let dateKey = `${currentDate.getFullYear()}-${(currentDate.getMonth() + 1).toString().padStart(2, '0')}-${currentDate.getDate().toString().padStart(2, '0')}`
                
                // Check all cached events for this date
                for (let i = 0; i < allEventsCache.length; i++) {
                    let evt = allEventsCache[i]
                    
                    if (evt.rrule) {
                        // Recurring event - check if it occurs on this date
                        if (icalLoader.checkRecurringEvent(evt, currentDate)) {
                            eventDatesCache[dateKey] = true
                            break  // Found an event on this date, move to next date
                        }
                    } else if (evt.date) {
                        // Single event - check if date matches
                        let eventDate = new Date(evt.date)
                        if (eventDate.getDate() === currentDate.getDate() &&
                            eventDate.getMonth() === currentDate.getMonth() &&
                            eventDate.getFullYear() === currentDate.getFullYear()) {
                            eventDatesCache[dateKey] = true
                            break  // Found an event on this date, move to next date
                        }
                    }
                }
                
                currentDate.setDate(currentDate.getDate() + 1)
            }
        }
        
        function triggerCalendarLoad() {
            let expandedPaths = root.calendarPaths.replace(/~/g, Quickshell.env("HOME"))
            let paths = expandedPaths.split(/[,;\s]+/).filter(p => p.trim() !== "")
            if (paths.length === 0) {
                paths = [Quickshell.env("HOME") + "/.config/quickshell/calendar.ics"]
            }
            console.log("📅 Loading calendar from:", paths.join(", "))
            
            // Detect if path is URL or local file
            let isUrl = paths.some(p => p.startsWith("http://") || p.startsWith("https://"))
            
            if (isUrl) {
                // Fetch from URL using curl
                let curlCommands = paths.map(p => {
                    if (p.startsWith("http://") || p.startsWith("https://")) {
                        return `curl -s -L "${p}"`
                    } else {
                        return `(test -f "${p}" && cat "${p}")`
                    }
                }).join(" ; echo ''; ")
                icalLoader.command = ["sh", "-c", curlCommands]
            } else {
                // Read local files
                let catCommands = paths.map(p => `(test -f "${p}" && cat "${p}" && echo "")`).join(" ; ")
                icalLoader.command = ["sh", "-c", catCommands]
            }
            
            icalLoader.running = true
        }
        
        function updateMoonPhase() {
            // Calculate moon phase based on current date
            let now = new Date()
            let year = now.getFullYear()
            let month = now.getMonth()
            let day = now.getDate()
            
            // Simplified moon phase calculation
            let c = 0; let e = 0; let jd = 0; let b = 0;
            
            if (month < 3) {
                year--
                month += 12
            }
            
            ++month
            c = 365.25 * year
            e = 30.6 * month
            jd = c + e + day - 694039.09  // Julian date
            jd /= 29.5305882  // Moon cycle
            b = parseInt(jd)
            jd -= b
            b = Math.round(jd * 8)
            
            if (b >= 8) b = 0
            
            // Set phase name and emoji
            const phases = [
                { name: "New Moon", emoji: "🌑", illumination: "0%" },
                { name: "Waxing Crescent", emoji: "🌒", illumination: "25%" },
                { name: "First Quarter", emoji: "🌓", illumination: "50%" },
                { name: "Waxing Gibbous", emoji: "🌔", illumination: "75%" },
                { name: "Full Moon", emoji: "🌕", illumination: "100%" },
                { name: "Waning Gibbous", emoji: "🌖", illumination: "75%" },
                { name: "Last Quarter", emoji: "🌗", illumination: "50%" },
                { name: "Waning Crescent", emoji: "🌘", illumination: "25%" }
            ]
            
            moonPhaseName = phases[b].name
            moonPhaseEmoji = phases[b].emoji
            moonIllumination = phases[b].illumination
        }
        
        Component.onCompleted: {
            updateMoonPhase()
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
                buffer = ""
            } else if (!running && buffer !== "") {
                console.log("📅 iCal file content length:", buffer.length, "characters")
                icalLoader.parseICalData(buffer)
            } else if (!running) {
                // Initialize empty cache if no data
                console.log("📅 No calendar data loaded")
                calendarModel.eventDatesCache = {}
                calendarModel.eventsModel = []
                calendarModel.updateEventDots()
            }
        }
        
        function parseICalData(icalContent) {
            let allEvents = []  // Store all events
            let eventDates = {}
            
            if (!icalContent || icalContent.trim() === "") {
                calendarModel.allEventsCache = allEvents
                calendarModel.eventsModel = []
                calendarModel.eventDatesCache = eventDates
                calendarModel.updateEventDots()
                return
            }
            
            // Fix malformed iCal files with no newlines by inserting them before keywords
            if (icalContent.indexOf('\n') === -1 && icalContent.indexOf('\r') === -1) {
                icalContent = icalContent
                    .replace(/BEGIN:/g, '\nBEGIN:')
                    .replace(/END:/g, '\nEND:')
                    .replace(/DTSTART/g, '\nDTSTART')
                    .replace(/DTEND/g, '\nDTEND')
                    .replace(/SUMMARY:/g, '\nSUMMARY:')
                    .replace(/DESCRIPTION:/g, '\nDESCRIPTION:')
                    .replace(/LOCATION:/g, '\nLOCATION:')
                    .replace(/UID:/g, '\nUID:')
                    .replace(/DTSTAMP:/g, '\nDTSTAMP:')
                    .replace(/CREATED:/g, '\nCREATED:')
                    .replace(/LAST-MODIFIED:/g, '\nLAST-MODIFIED:')
                    .replace(/SEQUENCE:/g, '\nSEQUENCE:')
                    .replace(/STATUS:/g, '\nSTATUS:')
                    .replace(/TRANSP:/g, '\nTRANSP:')
                    .replace(/VERSION:/g, '\nVERSION:')
                    .replace(/PRODID:/g, '\nPRODID:')
                    .replace(/CALSCALE:/g, '\nCALSCALE:')
                    .replace(/METHOD:/g, '\nMETHOD:')
                    .trim()
            }
            
            // Unfold iCal lines: lines starting with space are continuations
            let unfolded = icalContent.replace(/\r\n /g, '').replace(/\n /g, '').replace(/\r /g, '')
            
            // Split into lines - handle all line ending styles (\r\n, \n, \r)
            let lines = unfolded.split(/\r\n|\r|\n/)
            let currentEvent = null
            let totalEvents = 0
            
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim()
                
                if (line === "BEGIN:VEVENT") {
                    currentEvent = {
                        title: "",
                        description: "",
                        time: "",
                        date: null,
                        rrule: null,
                        color: ThemeManager.accentBlue
                    }
                } else if (line === "END:VEVENT" && currentEvent) {
                    // Store all events without filtering
                    if (currentEvent.date) {
                        totalEvents++
                        allEvents.push(currentEvent)
                    }
                    currentEvent = null
                } else if (currentEvent) {
                    if (line.startsWith("SUMMARY:")) {
                        currentEvent.title = line.substring(8)
                    } else if (line.startsWith("DESCRIPTION:")) {
                        currentEvent.description = line.substring(12)
                    } else if (line.startsWith("RRULE:")) {
                        // Parse recurrence rule
                        currentEvent.rrule = line.substring(6)
                    } else if (line.startsWith("DTSTART")) {
                        // Parse date: DTSTART:20260115T100000, DTSTART:20260115T100000Z (UTC), or DTSTART;VALUE=DATE:20260115
                        let dateMatch = line.match(/(\d{8})(T(\d{6})Z?)?/)
                        if (dateMatch) {
                            let dateStr = dateMatch[1]
                            let year = parseInt(dateStr.substring(0, 4))
                            let month = parseInt(dateStr.substring(4, 6)) - 1
                            let day = parseInt(dateStr.substring(6, 8))
                            
                            if (dateMatch[3]) {
                                let timeStr = dateMatch[3]
                                let hour = parseInt(timeStr.substring(0, 2))
                                let minute = parseInt(timeStr.substring(2, 4))
                                
                                // Check if time is in UTC (ends with Z)
                                if (line.includes('Z')) {
                                    // Convert UTC to local time
                                    let utcDate = new Date(Date.UTC(year, month, day, hour, minute))
                                    currentEvent.date = utcDate
                                    currentEvent.time = `${utcDate.getHours().toString().padStart(2, '0')}:${utcDate.getMinutes().toString().padStart(2, '0')}`
                                } else {
                                    // Local time
                                    currentEvent.date = new Date(year, month, day, hour, minute)
                                    currentEvent.time = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`
                                }
                            } else {
                                currentEvent.date = new Date(year, month, day)
                                currentEvent.time = "All day"
                            }
                        }
                    }
                }
            }
            
            // Store all events and build cache for current month only
            calendarModel.allEventsCache = allEvents
            calendarModel.eventDatesCache = {}  // Clear old cache
            
            console.log("📅 Parsed", totalEvents, "total events into cache")
            
            // Build event cache for current month (fast)
            calendarModel.buildEventCacheForMonth(calendarModel.currentYear, calendarModel.currentMonth)
            
            calendarModel.eventsRevision++
            
            // Filter events for the currently selected day
            calendarModel.filterEventsForSelectedDay()
            
            // Update visual indicators after parsing
            calendarModel.updateEventDots()
        }
        
        // Check if a recurring event occurs on a specific date
        function checkRecurringEvent(event, targetDate) {
            if (!event.rrule || !event.date) return false
            
            let startDate = new Date(event.date)
            
            // Parse RRULE components
            let rruleParts = event.rrule.split(';')
            let freq = null
            let until = null
            let byday = []
            let interval = 1
            let count = null
            
            for (let part of rruleParts) {
                let [key, value] = part.split('=')
                if (key === 'FREQ') freq = value
                else if (key === 'UNTIL') {
                    // Parse until date: 20250609T045959Z
                    let match = value.match(/(\d{4})(\d{2})(\d{2})/)
                    if (match) {
                        until = new Date(parseInt(match[1]), parseInt(match[2]) - 1, parseInt(match[3]))
                    }
                }
                else if (key === 'BYDAY') byday = value.split(',')
                else if (key === 'INTERVAL') interval = parseInt(value)
                else if (key === 'COUNT') count = parseInt(value)
            }
            
            // Check if target date is before start date
            if (targetDate < startDate) return false
            
            // Check if target date is after until date
            if (until && targetDate > until) return false
            
            // Handle FREQ=WEEKLY with BYDAY
            if (freq === 'WEEKLY' && byday.length > 0) {
                // Map day codes to day numbers (0=Sunday, 6=Saturday)
                let dayMap = {'SU': 0, 'MO': 1, 'TU': 2, 'WE': 3, 'TH': 4, 'FR': 5, 'SA': 6}
                let targetDay = targetDate.getDay()
                
                // Check if target day is in the BYDAY list
                let isDayMatch = false
                for (let day of byday) {
                    if (dayMap[day] === targetDay) {
                        isDayMatch = true
                        break
                    }
                }
                
                if (!isDayMatch) return false
                
                // Calculate weeks between start and target
                let daysDiff = Math.floor((targetDate - startDate) / (1000 * 60 * 60 * 24))
                let weeksDiff = Math.floor(daysDiff / 7)
                
                // Check interval
                if (weeksDiff % interval !== 0) {
                    // Not on the right interval, but check if it's within the same week as start
                    if (weeksDiff === 0 && targetDay >= startDate.getDay()) {
                        return true
                    }
                    return false
                }
                
                // Check COUNT if specified
                if (count !== null) {
                    let occurrences = Math.floor(weeksDiff / interval) + 1
                    if (occurrences > count) return false
                }
                
                return true
            }
            
            // Handle FREQ=DAILY
            if (freq === 'DAILY') {
                let daysDiff = Math.floor((targetDate - startDate) / (1000 * 60 * 60 * 24))
                if (daysDiff % interval !== 0) return false
                
                if (count !== null) {
                    let occurrences = Math.floor(daysDiff / interval) + 1
                    if (occurrences > count) return false
                }
                
                return true
            }
            
            // Handle FREQ=MONTHLY (basic - same day of month)
            if (freq === 'MONTHLY') {
                if (targetDate.getDate() !== startDate.getDate()) return false
                
                let monthsDiff = (targetDate.getFullYear() - startDate.getFullYear()) * 12 + 
                                (targetDate.getMonth() - startDate.getMonth())
                
                if (monthsDiff % interval !== 0) return false
                
                if (count !== null && monthsDiff / interval >= count) return false
                
                return true
            }
            
            // Handle FREQ=YEARLY
            if (freq === 'YEARLY') {
                if (targetDate.getDate() !== startDate.getDate() || 
                    targetDate.getMonth() !== startDate.getMonth()) return false
                
                let yearsDiff = targetDate.getFullYear() - startDate.getFullYear()
                if (yearsDiff % interval !== 0) return false
                
                if (count !== null && yearsDiff / interval >= count) return false
                
                return true
            }
            
            return false
        }
    }
    
    // Fetch sunrise/sunset times
    Process {
        id: sunTimesLoader
        running: false
        command: ["sh", "-c", "curl -s 'wttr.in/?format=j1' | grep -A 2 astronomy"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { sunTimesLoader.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    // Extract sunrise/sunset from wttr.in json
                    let fullData = buffer.replace(/.*"astronomy"/, '"astronomy"')
                    let jsonMatch = fullData.match(/"astronomy":\s*\[(.*?)\]/)
                    if (jsonMatch) {
                        let astronomyStr = "{" + jsonMatch[0] + "}"
                        let data = JSON.parse(astronomyStr)
                        if (data.astronomy && data.astronomy[0]) {
                            calendarModel.sunriseTime = data.astronomy[0].sunrise || "N/A"
                            calendarModel.sunsetTime = data.astronomy[0].sunset || "N/A"
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse sun times:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Timer {
        interval: 500
        running: root.active
        repeat: false
        triggeredOnStart: true
        onTriggered: sunTimesLoader.running = true
    }
}
