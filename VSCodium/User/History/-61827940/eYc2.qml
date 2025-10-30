import QtQuick

Rectangle {
    id: testClock
    
    width: 200
    height: 30
    color: testMouseArea.containsMouse ? "lightblue" : "blue"
    
    Text {
        anchors.centerIn: parent
        text: "TEST CLOCK"
        color: "white"
    }
    
    MouseArea {
        id: testMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.CrossCursor
        
        onContainsMouseChanged: {
            console.log("TEST CLOCK hover:", containsMouse)
        }
        
        onClicked: {
            console.log("TEST CLOCK clicked!")
        }
    }
}