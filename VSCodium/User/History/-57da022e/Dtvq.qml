import QtQuick
import Quickshell
import Quickshell.Services.Network

MouseArea {
    id: networkArea
    
    property string connectionType: "disconnected"
    property int signalStrength: 0
    property string ipAddress: ""
    property string essid: ""
    
    width: 40
    height: parent.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        color: networkArea.containsMouse ? "#33467c" : "#292e42"
        radius: 0
        
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 8
            radius: 8
            color: parent.color
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            anchors.centerIn: parent
            text: {
                if (networkArea.connectionType === "wifi") {
                    // Signal strength icons
                    if (networkArea.signalStrength >= 80) return "󰤨"
                    else if (networkArea.signalStrength >= 60) return "󰤥"
                    else if (networkArea.signalStrength >= 40) return "󰤢"
                    else if (networkArea.signalStrength >= 20) return "󰤟"
                    else return "󰤯"
                } else if (networkArea.connectionType === "ethernet") {
                    return "󰈀"
                } else {
                    return "󰌙"
                }
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: {
                if (networkArea.connectionType === "wifi") return "#9ece6a"
                else if (networkArea.connectionType === "ethernet") return "#7aa2f7"
                else return "#f7768e"
            }
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            // Check network status
            let proc = Process.exec("sh", ["-c", "ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \\K\\S+' | head -1"])
            proc.finished.connect(() => {
                let iface = proc.stdout.trim()
                if (iface) {
                    if (iface.startsWith("wl")) {
                        networkArea.connectionType = "wifi"
                        // Get wifi signal strength
                        let signalProc = Process.exec("sh", ["-c", `iw dev ${iface} link | grep signal | awk '{print $2}'`])
                        signalProc.finished.connect(() => {
                            let signal = parseInt(signalProc.stdout.trim())
                            // Convert dBm to percentage (approximate)
                            networkArea.signalStrength = Math.max(0, Math.min(100, 2 * (signal + 100)))
                        })
                    } else if (iface.startsWith("en") || iface.startsWith("eth")) {
                        networkArea.connectionType = "ethernet"
                    }
                } else {
                    networkArea.connectionType = "disconnected"
                }
            })
        }
    }
    
    onClicked: {
        Process.execute("nm-connection-editor")
    }
}
