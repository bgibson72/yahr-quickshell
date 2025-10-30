import QtQuick
import Quickshell

MouseArea {
    id: audioArea
    
    property int volume: 50
    property bool muted: false
    
    width: 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        color: audioArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            anchors.centerIn: parent
            text: {
                if (audioArea.muted) return "󰝟"
                else if (audioArea.volume >= 66) return "󰕾"
                else if (audioArea.volume >= 33) return "󰖀"
                else return "󰕿"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
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
