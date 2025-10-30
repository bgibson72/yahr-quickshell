import QtQuick
import Quickshell
import "."

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: {
        console.log("Wallpaper button clicked")
        WallpaperPickerBridge.show()
    }
}
