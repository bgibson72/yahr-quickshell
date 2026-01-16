import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool active: false
    
    Column {
        anchors.fill: parent
        spacing: 16
        
        // Current Weather (top half)
        Rectangle {
            width: parent.width
            height: (parent.height - 16) * 0.45
            color: ThemeManager.surface1
            radius: 12
            
            Row {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 32
                
                // Left: Icon and temp
                Column {
                    width: (parent.width - 32) * 0.4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16
                    
                    Text {
                        id: currentIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "⛅"
                        font.family: "Noto Color Emoji"
                        font.pixelSize: 80
                    }
                    
                    Text {
                        id: currentTemp
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "..."
                        font.family: "MapleMono NF"
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                    }
                    
                    Text {
                        id: currentCondition
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Loading..."
                        font.family: "MapleMono NF"
                        font.pixelSize: 18
                        color: ThemeManager.fgSecondary
                    }
                }
                
                // Right: Details
                Column {
                    width: (parent.width - 32) * 0.6
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20
                    
                    Text {
                        id: locationText
                        text: "📍 Loading location..."
                        font.family: "MapleMono NF"
                        font.pixelSize: 16
                        color: ThemeManager.fgPrimary
                        width: parent.width
                        elide: Text.ElideRight
                    }
                    
                    Grid {
                        columns: 2
                        columnSpacing: 40
                        rowSpacing: 16
                        
                        // Feels Like
                        Column {
                            spacing: 4
                            Text {
                                text: "Feels Like"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: feelsLike
                                text: "--"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                        
                        // Humidity
                        Column {
                            spacing: 4
                            Text {
                                text: "Humidity"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: humidity
                                text: "--"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentCyan
                            }
                        }
                        
                        // Wind Speed
                        Column {
                            spacing: 4
                            Text {
                                text: "Wind Speed"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: windSpeed
                                text: "--"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentGreen
                            }
                        }
                        
                        // Pressure
                        Column {
                            spacing: 4
                            Text {
                                text: "Pressure"
                                font.family: "MapleMono NF"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: pressure
                                text: "--"
                                font.family: "MapleMono NF"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                    }
                }
            }
        }
        
        // 5-Day Forecast (bottom half)
        Rectangle {
            width: parent.width
            height: (parent.height - 16) * 0.55
            color: ThemeManager.surface1
            radius: 12
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        text: "📊"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "5-Day Forecast"
                        font.family: "MapleMono NF"
                        font.pixelSize: 18
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
                
                // Forecast items
                Row {
                    width: parent.width
                    height: parent.height - 60
                    spacing: 12
                    
                    Repeater {
                        model: 5
                        
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: ThemeManager.surface0
                            radius: 10
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                
                                Text {
                                    id: dayLabel
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getDayLabel(index)
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }
                                
                                Text {
                                    id: forecastIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getIcon(index)
                                    font.family: "Noto Color Emoji"
                                    font.pixelSize: 40
                                }
                                
                                Column {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: forecastModel.getHighTemp(index)
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: ThemeManager.accentRed
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: forecastModel.getLowTemp(index)
                                        font.family: "MapleMono NF"
                                        font.pixelSize: 14
                                        color: ThemeManager.accentCyan
                                    }
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getCondition(index)
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                    width: parent.parent.width - 16
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Weather update timer
    Timer {
        interval: 300000 // 5 minutes
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: settingsLoader.running = true
    }
    
    // Load weather settings
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
                    let latitude = ""
                    let longitude = ""
                    let useFahrenheit = true
                    
                    if (settings.general) {
                        latitude = settings.general.weatherLatitude || ""
                        longitude = settings.general.weatherLongitude || ""
                        useFahrenheit = settings.general.useFahrenheit !== false
                    }
                    
                    const tempUnit = useFahrenheit ? "u" : "m"
                    let location = (latitude && longitude) ? `${latitude},${longitude}` : ""
                    
                    // Current weather
                    let weatherCmd = `curl -s "wttr.in/${location}?${tempUnit}&format=%c|%t|%C|%h|%w|%l|%f|%p"`
                    weatherProcess.command = ["sh", "-c", weatherCmd]
                    weatherProcess.running = true
                    
                    // Forecast - use wttr.in format v2 for better data
                    let forecastCmd = `curl -s "wttr.in/${location}?${tempUnit}&format=j1"`
                    forecastProcess.command = ["sh", "-c", forecastCmd]
                    forecastProcess.running = true
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Fetch current weather
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t|%C|%h|%w|%l|%f|%p'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split('|')
                if (parts.length >= 7) {
                    currentIcon.text = (parts[0] || "🌡️").trim()
                    let temp = (parts[1] || "N/A").trim()
                    currentTemp.text = temp.replace(/^\+/, "")
                    currentCondition.text = (parts[2] || "Unknown").trim()
                    humidity.text = (parts[3] || "--").trim()
                    windSpeed.text = (parts[4] || "--").trim()
                    locationText.text = "📍 " + (parts[5] || "Unknown").trim()
                    feelsLike.text = (parts[6] || "--").trim().replace(/^\+/, "")
                    pressure.text = (parts[7] || "--").trim()
                }
            }
        }
    }
    
    // Fetch forecast
    Process {
        id: forecastProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=j1'"]
        running: false
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { forecastProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const data = JSON.parse(buffer)
                    if (data.weather && Array.isArray(data.weather)) {
                        forecastModel.parseForecast(data.weather)
                    }
                } catch (e) {
                    console.error("Failed to parse forecast:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Forecast model
    QtObject {
        id: forecastModel
        
        property var forecast: []
        
        function parseForecast(weatherData) {
            forecast = []
            for (let i = 0; i < Math.min(5, weatherData.length); i++) {
                let day = weatherData[i]
                forecast.push({
                    date: day.date || "",
                    highTemp: day.maxtempF ? day.maxtempF + "°F" : day.maxtempC ? day.maxtempC + "°C" : "--",
                    lowTemp: day.mintempF ? day.mintempF + "°F" : day.mintempC ? day.mintempC + "°C" : "--",
                    condition: day.hourly && day.hourly[0] ? day.hourly[0].weatherDesc[0].value : "Unknown",
                    icon: getWeatherIcon(day.hourly && day.hourly[0] ? day.hourly[0].weatherCode : "")
                })
            }
        }
        
        function getWeatherIcon(code) {
            // Weather icon mapping based on weather codes
            const iconMap = {
                "113": "☀️", "116": "⛅", "119": "☁️", "122": "☁️", "143": "🌫️",
                "176": "🌦️", "179": "🌨️", "182": "🌨️", "185": "🌨️", "200": "⛈️",
                "227": "🌨️", "230": "❄️", "248": "🌫️", "260": "🌫️", "263": "🌦️",
                "266": "🌧️", "281": "🌧️", "284": "🌧️", "293": "🌦️", "296": "🌧️",
                "299": "🌧️", "302": "🌧️", "305": "🌧️", "308": "🌧️", "311": "🌧️",
                "314": "🌧️", "317": "🌧️", "320": "🌨️", "323": "🌨️", "326": "🌨️",
                "329": "❄️", "332": "❄️", "335": "❄️", "338": "❄️", "350": "🌨️",
                "353": "🌦️", "356": "🌧️", "359": "🌧️", "362": "🌨️", "365": "🌨️",
                "368": "🌨️", "371": "❄️", "374": "🌨️", "377": "🌨️", "386": "⛈️",
                "389": "⛈️", "392": "⛈️", "395": "❄️"
            }
            return iconMap[code] || "⛅"
        }
        
        function getDayLabel(index) {
            if (forecast.length <= index) return "..."
            if (index === 0) return "Today"
            if (index === 1) return "Tomorrow"
            
            const date = new Date()
            date.setDate(date.getDate() + index)
            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return days[date.getDay()]
        }
        
        function getIcon(index) {
            return forecast.length > index ? forecast[index].icon : "⛅"
        }
        
        function getHighTemp(index) {
            return forecast.length > index ? forecast[index].highTemp : "--"
        }
        
        function getLowTemp(index) {
            return forecast.length > index ? forecast[index].lowTemp : "--"
        }
        
        function getCondition(index) {
            return forecast.length > index ? forecast[index].condition : "..."
        }
    }
}
