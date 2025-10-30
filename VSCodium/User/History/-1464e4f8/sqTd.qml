import QtQuick
import Quickshell

Rectangle {
    id: archButton
    
    width: 60
    height: 35
    
    // Color states: normal, hover, pressed
    color: {
        if (mouseArea.pressed) return Qt.darker("#7aa2f7", 1.4)  // Darker when pressed
        else if (mouseArea.containsMouse) return "#9d7cd8"      // Purple on hover
        else return "#7aa2f7"                                   // Blue normal
    }
    
    radius: 6
    
    // Scale effect - smaller when pressed to simulate "pressing in"
    scale: mouseArea.pressed ? 0.92 : 1.0
    
    // Subtle shadow effect when pressed
    opacity: mouseArea.pressed ? 0.8 : 1.0
    
    Text {
        anchors.centerIn: parent
        text: "󰣇"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 20
        color: "#1a1b26"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor  // Pointer finger cursor
        
        onClicked: {
            console.log("ARCH BUTTON CLICKED!")
            // Try using a timer to delay execution
            launchTimer.start()
        }
        
        onPressed: console.log("ARCH BUTTON PRESSED DOWN")
        onReleased: console.log("ARCH BUTTON RELEASED")
        onEntered: console.log("ENTERED ARCH BUTTON - cursor should be pointer")
        onExited: console.log("EXITED ARCH BUTTON")
    }
    
    // Smooth animations
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
    }
    
    Behavior on opacity {
        NumberAnimation { duration: 100 }
    }
    
    Timer {
        id: launchTimer
        interval: 100
        repeat: false
        
        onTriggered: {
            console.log("Timer triggered, testing available methods...")
            // Let's see what methods are available on Quickshell
            console.log("Quickshell object:", Quickshell)
            console.log("Available properties:", Object.getOwnPropertyNames(Quickshell))
            
            // Try different potential method names
            if (typeof Quickshell.exec === 'function') {
                console.log("Trying Quickshell.exec")
                Quickshell.exec("wofi", ["--show", "drun"])
            } else if (typeof Quickshell.spawn === 'function') {
                console.log("Trying Quickshell.spawn") 
                Quickshell.spawn("wofi", ["--show", "drun"])
            } else if (typeof Quickshell.execDetached === 'function') {
                console.log("Trying Quickshell.execDetached")
                Quickshell.execDetached("wofi")
            } else {
                console.log("No execution methods found on Quickshell object")
            }
        }
    }
}
