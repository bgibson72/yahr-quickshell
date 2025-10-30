import QtQuick
import Quickshell

Rectangle {
    id: archButton
    
    width: 60
    height: 35
    
    // Color states: normal, hover, pressed
    color: {
        if (mouseArea.pressed) return Qt.darker(ThemeManager.accentBlue, 1.4)  // Darker when pressed
        else if (mouseArea.containsMouse) return ThemeManager.accentPurple      // Purple on hover
        else return ThemeManager.accentBlue                                     // Blue normal
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
        color: ThemeManager.bgBase
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
            console.log("Timer triggered, launching wofi with correct syntax...")
            // According to docs: execDetached takes a single list parameter
            Quickshell.execDetached(["wofi", "--show", "drun"])
        }
    }
}
