import QtQuick
import Quickshell

MouseArea {
    id: clockArea
    
    width: clockText.width + 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    property var rootShell: null  // Will be set by parent Bar
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: clockText.width + 20
        height: parent.height - 10
        
        color: clockArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6

        
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
            let ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            hours = hours.toString().padStart(2, '0')
            
            clockText.text = `${month}/${day}/${year}  ${hours}:${minutes} ${ampm}`
        }
    }
    
    onClicked: {
        if (rootShell) {
            rootShell.calendarVisible = !rootShell.calendarVisible
            console.log("Calendar toggled to:", rootShell.calendarVisible)
        } else {
            console.log("ERROR: rootShell is null in Clock")
        }
    }
}
