import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/wallpaper-picker"])
}tQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: Quickshell.execDetached(["waypaper"])
}
