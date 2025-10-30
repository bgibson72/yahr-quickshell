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
        color: audioArea.containsMouse ? "#33467c" : "#292e42"
        
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
            font.pixelSize: 16
            color: audioArea.muted ? "#565f89" : "#e0af68"
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    
    // Monitor volume with pactl
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            let proc = Process.exec("sh", ["-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"])
            proc.finished.connect(() => {
                audioArea.volume = parseInt(proc.stdout.trim()) || 0
            })
            
            let muteProc = Process.exec("sh", ["-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0"])
            muteProc.finished.connect(() => {
                audioArea.muted = muteProc.stdout.trim() === "1"
            })
        }
    }
    
    onClicked: {
        Process.execute("pavucontrol")
    }
    
    // Mouse wheel to adjust volume
    onWheel: (wheel) => {
        let delta = wheel.angleDelta.y > 0 ? 5 : -5
        Process.execute("pactl", ["set-sink-volume", "@DEFAULT_SINK@", (delta > 0 ? "+" : "") + delta + "%"])
    }
}
