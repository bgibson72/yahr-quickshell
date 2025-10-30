import QtQuick
import Quickshell

Rectangle {
    id: clockArea
    
    width: clockText.width + 40
    height: parent.height - 10
    
    color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
    radius: 6
    
    signal toggleCalendar()
    
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
}
