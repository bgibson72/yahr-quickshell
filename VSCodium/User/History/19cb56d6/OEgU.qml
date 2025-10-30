import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: popup
    
    property bool popupVisible: false
    property var parentItem: null
    
    width: 600
    height: 400
    
    color: "red"  // Temporary: make it very obvious
    border.color: "blue"
    border.width: 5
    radius: 12
    
    // Debug text to make it obvious
    Text {
        anchors.centerIn: parent
        text: "CALENDAR POPUP IS HERE!"
        font.pixelSize: 24
        color: "white"
        z: 2000
    }
    
    visible: popupVisible
    opacity: popupVisible ? 1 : 0
    scale: popupVisible ? 1 : 0.9
    
    onVisibleChanged: {
        console.log("CalendarWeatherPopup visible changed to:", visible)
    }
    
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuart }
    }    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onPressed: event.accepted = false
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Weather Section (Left)
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 140
            color: ThemeManager.surface1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                
                // Current Weather
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        id: weatherIcon
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "Weather Icons"
                        font.pixelSize: 48
                        color: ThemeManager.accentBlue
                        text: "🌤️" // Default icon, will be updated
                    }
                    
                    Text {
                        id: currentTemp
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        text: "22°C"
                    }
                    
                    Text {
                        id: weatherDescription
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                        text: "Partly Cloudy"
                    }
                }
                
                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: ThemeManager.border0
                }
                
                // High/Low temperatures
                RowLayout {
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "MapleMono NF"
                            font.pixelSize: 10
                            color: ThemeManager.fgTertiary
                            text: "HIGH"
                        }
                        
                        Text {
                            id: highTemp
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: ThemeManager.accentRed
                            text: "26°"
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "MapleMono NF"
                            font.pixelSize: 10
                            color: ThemeManager.fgTertiary
                            text: "LOW"
                        }
                        
                        Text {
                            id: lowTemp
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "MapleMono NF"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: ThemeManager.accentBlue
                            text: "18°"
                        }
                    }
                }
                
                // Additional weather info
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            
                            Text {
                                font.family: "Material Design Icons"
                                font.pixelSize: 14
                                color: ThemeManager.accentCyan
                                text: "💨"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                id: windSpeed
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgSecondary
                                text: "5 km/h"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            
                            Text {
                                font.family: "Material Design Icons"
                                font.pixelSize: 14
                                color: ThemeManager.accentBlue
                                text: "💧"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                id: humidity
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgSecondary
                                text: "65%"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Calendar and Time Section (Right)
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 12
            
            // Digital Clock Display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: ThemeManager.surface1
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        id: digitalTime
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        text: "12:34"
                    }
                    
                    Text {
                        id: digitalDate
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "MapleMono NF"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                        text: "Tuesday, October 15, 2024"
                    }
                }
            }
            
            // Calendar Grid
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: ThemeManager.surface1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    // Calendar Header
                    RowLayout {
                        Layout.fillWidth: true
                        
                        MouseArea {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            Rectangle {
                                anchors.fill: parent
                                color: parent.containsMouse ? ThemeManager.surface2 : "transparent"
                                radius: 4
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                font.family: "Material Design Icons"
                                font.pixelSize: 16
                                color: ThemeManager.fgPrimary
                                text: "‹"
                            }
                            
                            onClicked: calendar.previousMonth()
                        }
                        
                        Text {
                            id: monthYear
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "MapleMono NF"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: ThemeManager.fgPrimary
                            horizontalAlignment: Text.AlignHCenter
                            text: "October 2024"
                        }
                        
                        MouseArea {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            Rectangle {
                                anchors.fill: parent
                                color: parent.containsMouse ? ThemeManager.surface2 : "transparent"
                                radius: 4
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                font.family: "Material Design Icons"
                                font.pixelSize: 16
                                color: ThemeManager.fgPrimary
                                text: "›"
                            }
                            
                            onClicked: calendar.nextMonth()
                        }
                    }
                    
                    // Day headers
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 4
                        
                        Repeater {
                            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                            
                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 25
                                font.family: "MapleMono NF"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: ThemeManager.fgTertiary
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // Calendar days
                    GridLayout {
                        id: calendar
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 2
                        columnSpacing: 2
                        
                        property int currentMonth: new Date().getMonth()
                        property int currentYear: new Date().getFullYear()
                        property int today: new Date().getDate()
                        property var calendarModel: []
                        
                        function previousMonth() {
                            currentMonth--
                            if (currentMonth < 0) {
                                currentMonth = 11
                                currentYear--
                            }
                            updateCalendar()
                        }
                        
                        function nextMonth() {
                            currentMonth++
                            if (currentMonth > 11) {
                                currentMonth = 0
                                currentYear++
                            }
                            updateCalendar()
                        }
                        
                        function updateCalendar() {
                            // Update month/year display
                            const months = ["January", "February", "March", "April", "May", "June",
                                          "July", "August", "September", "October", "November", "December"]
                            monthYear.text = months[currentMonth] + " " + currentYear
                            
                            // Build calendar model
                            let model = []
                            const firstDay = new Date(currentYear, currentMonth, 1).getDay()
                            const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
                            
                            // Add empty cells for days before month starts
                            for (let i = 0; i < firstDay; i++) {
                                model.push({ dayText: "", isCurrentMonth: false, isToday: false })
                            }
                            
                            // Add days of current month
                            for (let day = 1; day <= daysInMonth; day++) {
                                const isToday = (currentMonth === new Date().getMonth() && 
                                               currentYear === new Date().getFullYear() && 
                                               day === today)
                                model.push({
                                    dayText: day.toString(),
                                    isCurrentMonth: true,
                                    isToday: isToday
                                })
                            }
                            
                            calendarModel = model
                            dayRepeater.model = calendarModel
                        }
                        
                        Component.onCompleted: updateCalendar()
                        
                        Repeater {
                            id: dayRepeater
                            model: calendar.calendarModel
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 25
                                
                                property var dayData: modelData || { dayText: "", isCurrentMonth: false, isToday: false }
                                
                                color: dayData.isToday ? ThemeManager.accentBlue : 
                                       (mouseArea.containsMouse ? ThemeManager.surface2 : "transparent")
                                radius: 4
                                
                                Text {
                                    anchors.centerIn: parent
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 12
                                    font.weight: dayData.isToday ? Font.Bold : Font.Normal
                                    color: dayData.isToday ? ThemeManager.surface0 : 
                                           (dayData.isCurrentMonth ? ThemeManager.fgPrimary : ThemeManager.fgTertiary)
                                    text: dayData.dayText
                                }
                                
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        if (dayData.dayText !== "" && dayData.isCurrentMonth) {
                                            console.log("Selected date:", dayData.dayText)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    
    // Timer to update time and weather
    Timer {
        interval: 300000 // Update every 5 minutes (weather API is rate-limited)
        running: popup.popupVisible
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            updateTime()
            updateWeather()
            tempRangeProcess.running = true
        }
    }
    
    function updateTime() {
        const now = new Date()
        let hours = now.getHours()
        const minutes = now.getMinutes().toString().padStart(2, '0')
        const ampm = hours >= 12 ? 'PM' : 'AM'
        hours = hours % 12
        hours = hours ? hours : 12
        
        digitalTime.text = `${hours}:${minutes} ${ampm}`
        
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
        digitalDate.text = now.toLocaleDateString('en-US', options)
    }
    
    function updateWeather() {
        console.log("Fetching real weather data from wttr.in...")
        weatherProcess.running = true
    }
    
    // Process to fetch current weather
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?format=%c|%t|%C|%h|%w'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Weather data received:", data)
                const parts = data.trim().split('|')
                if (parts.length >= 5) {
                    // Parse wttr.in format: emoji|temp|condition|humidity|wind
                    weatherIcon.text = parts[0] || "�️"
                    currentTemp.text = parts[1] || "N/A"
                    weatherDescription.text = parts[2] || "Unknown"
                    humidity.text = parts[3] || "N/A"
                    windSpeed.text = parts[4] || "N/A"
                    
                    console.log("Weather updated successfully")
                } else {
                    console.log("Failed to parse weather data")
                    weatherIcon.text = "❓"
                    currentTemp.text = "N/A"
                    weatherDescription.text = "Weather unavailable"
                }
            }
        }
        
        onExited: (code, status) => {
            if (code !== 0) {
                console.log("Weather fetch failed with code:", code)
                weatherIcon.text = "❓"
                currentTemp.text = "N/A"
                weatherDescription.text = "Weather unavailable"
            }
        }
    }
    
    // Process to fetch high/low temperatures
    Process {
        id: tempRangeProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?format=%H|%L'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Temperature range data:", data)
                const parts = data.trim().split('|')
                if (parts.length >= 2) {
                    highTemp.text = parts[0] || "N/A"
                    lowTemp.text = parts[1] || "N/A"
                }
            }
        }
    }
    
    Component.onCompleted: {
        // Fetch weather on startup
        updateWeather()
        tempRangeProcess.running = true
    }
    
    function show(parent) {
        console.log("CalendarWeatherPopup.show() called")
        parentItem = parent
        popupVisible = true
        console.log("Popup set to visible, position:", x, y, "size:", width, height)
        updateTime()
        updateWeather()
    }
    
    function hide() {
        console.log("CalendarWeatherPopup.hide() called")
        popupVisible = false
    }
}