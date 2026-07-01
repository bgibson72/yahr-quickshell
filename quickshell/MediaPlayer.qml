import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: mediaPlayer

    width: contentRow.width + 20
    height: 35
    color: "transparent"

    // Set this from outside to control whether the widget is allowed to show.
    // Visibility is gated internally so Mpris.players.count resolves correctly.
    property bool showMediaPlayer: true

    // Reactive property — true once any MPRIS player is assigned.
    // Use this from outside (e.g. Bar.qml) to gate visibility reactively,
    // since Mpris.players.count is not a NOTIFY-backed property and won't
    // trigger binding updates in other QML files.
    property bool hasPlayer: activePlayer !== null

    visible: showMediaPlayer && hasPlayer

    // Tracked player reference — updated by the Repeater below
    property MprisPlayer activePlayer: null

    // Iterate all live MPRIS players; prefer Spotify over anything else
    Repeater {
        model: Mpris.players

        delegate: Item {
            required property MprisPlayer modelData

            Component.onCompleted: {
                // Always pick Spotify when it appears; otherwise take the
                // first player seen.
                if (modelData.identity === "Spotify"
                        || modelData.desktopEntry === "spotify"
                        || mediaPlayer.activePlayer === null) {
                    mediaPlayer.activePlayer = modelData
                }
            }

            Component.onDestruction: {
                // If our player goes away, clear the reference so the next
                // PropertiesChanged cycle can fill it in again.
                if (mediaPlayer.activePlayer === modelData) {
                    mediaPlayer.activePlayer = null
                }
            }
        }
    }

    Item {
        anchors.fill: parent

        HoverHandler {
            id: widgetHover
        }

        Rectangle {
            anchors.centerIn: parent
            width: contentRow.width + 16
            height: 32
            color: widgetHover.hovered ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
            radius: 6
            border.width: widgetHover.hovered ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.18)

            Behavior on color   { ColorAnimation { duration: 200 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 8

                // Play / Pause button
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    opacity: activePlayer && activePlayer.canTogglePlaying ? 1.0 : 0.35
                    color: playPauseArea.containsMouse && activePlayer && activePlayer.canTogglePlaying
                           ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
                              ? "\udb80\udfe4" : "\udb81\udc0a"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: ThemeManager.accentPurple
                    }

                    MouseArea {
                        id: playPauseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: activePlayer && activePlayer.canTogglePlaying
                                     ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: function(mouse) {
                            if (activePlayer && activePlayer.canTogglePlaying)
                                activePlayer.togglePlaying()
                            mouse.accepted = true
                        }
                    }
                }

                // Track info
                Text {
                    text: {
                        if (!activePlayer) return "No media"
                        const title  = activePlayer.trackTitle
                        const artist = activePlayer.trackArtist
                        if (title && artist) {
                            const combined = artist + " - " + title
                            return combined.length > 35
                                   ? combined.substring(0, 35) + "\u2026" : combined
                        }
                        if (title)
                            return title.length > 35
                                   ? title.substring(0, 35) + "\u2026" : title
                        return activePlayer.identity || "No media"
                    }
                    font.family: ThemeManager.uiFont
                    font.pixelSize: 11
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Previous
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    opacity: activePlayer && activePlayer.canGoPrevious ? 1.0 : 0.35
                    color: prevArea.containsMouse && activePlayer && activePlayer.canGoPrevious
                           ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\udb81\udcae"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                    }

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: activePlayer && activePlayer.canGoPrevious
                                     ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: function(mouse) {
                            if (activePlayer && activePlayer.canGoPrevious)
                                activePlayer.previous()
                            mouse.accepted = true
                        }
                    }
                }

                // Next
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    opacity: activePlayer && activePlayer.canGoNext ? 1.0 : 0.35
                    color: nextArea.containsMouse && activePlayer && activePlayer.canGoNext
                           ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\udb81\udcad"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                    }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: activePlayer && activePlayer.canGoNext
                                     ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: function(mouse) {
                            if (activePlayer && activePlayer.canGoNext)
                                activePlayer.next()
                            mouse.accepted = true
                        }
                    }
                }
            }
        }
    }
}
