import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: mediaPlayer
    
    width: contentRow.width + 20
    height: 35
    color: "transparent"
    
    visible: Mpris.players.length > 0
    
    property var player: Mpris.players.length > 0 ? Mpris.players[0] : null
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (player) {
                player.playPause()
            }
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: contentRow.width + 16
            height: 32
            color: mouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
            radius: 6
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 8
                
                // Play/Pause icon
                Text {
                    text: player && player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: ThemeManager.accentPurple
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }
                
                // Track title
                Text {
                    text: {
                        if (!player || !player.metadata) return "No media"
                        const title = player.metadata["xesam:title"]
                        const artist = player.metadata["xesam:artist"]
                        if (title && artist) {
                            const combined = artist + " - " + title
                            return combined.length > 30 ? combined.substring(0, 30) + "..." : combined
                        }
                        if (title) {
                            return title.length > 30 ? title.substring(0, 30) + "..." : title
                        }
                        return "No media"
                    }
                    font.family: "MapleMono NF"
                    font.pixelSize: 11
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                // Previous button
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: prevMouseArea.containsMouse ? ThemeManager.surface2 : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                    }
                    
                    MouseArea {
                        id: prevMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: function(mouse) {
                            if (player) player.previous()
                            mouse.accepted = true
                        }
                    }
                }
                
                // Next button
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: nextMouseArea.containsMouse ? ThemeManager.surface2 : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                    }
                    
                    MouseArea {
                        id: nextMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: function(mouse) {
                            if (player) player.next()
                            mouse.accepted = true
                        }
                    }
                }
            }
        }
    }
}
