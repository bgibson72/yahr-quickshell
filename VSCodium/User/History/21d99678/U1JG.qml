import QtQuick
import Quickshell
import "."

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: WallpaperPickerManager.show()
}tQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: Quickshell.execDetached(["waypaper"])
}
