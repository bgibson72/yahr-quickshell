import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: Quickshell.execDetached("waypaper")
}
