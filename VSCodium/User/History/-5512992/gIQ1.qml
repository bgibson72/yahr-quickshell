import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

MouseArea {
    id: updatesArea
    
    property int updateCount: 0
    
    width: updatesText.width + 20
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.rightMargin: 10
        color: updatesArea.containsMouse ? "#33467c" : "#292e42"
        radius: 8
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Row {
            id: updatesText
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "󰚰"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: "#7aa2f7"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: updatesArea.updateCount.toString()
                font.family: "MapleMono NF"
                font.pixelSize: 12
                color: "#7aa2f7"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    Timer {
        interval: 3600000  // 1 hour
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            let proc = Process.exec("sh", ["-c", "checkupdates 2>/dev/null | wc -l"])
            proc.finished.connect(() => {
                updatesArea.updateCount = parseInt(proc.stdout.trim()) || 0
            })
        }
    }
    
    onClicked: {
        Process.execute("kitty", ["-e", "sh", "-c", "sudo pacman -Syu; echo Done - Press enter to exit; read"])
    }
}
