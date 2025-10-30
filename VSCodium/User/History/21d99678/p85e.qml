import QtQuick
import Quickshell
import "."

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: WallpaperPickerManager.show()
}
