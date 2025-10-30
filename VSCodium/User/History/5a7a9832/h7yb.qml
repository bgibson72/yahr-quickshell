import QtQuick

MouseArea {
    id: clockArea
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
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
    
    // You can add calendar popup on click
    onClicked: {
        // TODO: Implement calendar popup
        console.log("Clock clicked - calendar popup not yet implemented")
    }
}
