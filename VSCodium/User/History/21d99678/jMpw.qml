import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: Process.execute("waypaper")
}
