import QtQuick
import Quickshell

MouseArea {
    id: audioArea
    
    property int volume: 50
    property bool muted: false
    
    width: contentRect.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: 40
        height: 32
        
        color: audioArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            id: audioText
            anchors.centerIn: parent
            text: {
                if (audioArea.muted) return "󰝟"
                else if (audioArea.volume >= 66) return "󰕾"
                else if (audioArea.volume >= 33) return "󰖀"
                else return "󰕿"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: audioArea.muted ? ThemeManager.border0 : ThemeManager.accentYellow
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    
    onClicked: {
        Quickshell.execDetached("pavucontrol")
    }
    
    onWheel: (wheel) => {
        let delta = wheel.angleDelta.y > 0 ? 5 : -5
        Quickshell.execDetached("pactl", ["set-sink-volume", "@DEFAULT_SINK@", (delta > 0 ? "+" : "") + delta + "%"])
    }
}
