import QtQuick
import Quickshell
import "."

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    visible: true
    opacity: 1.0
    onClicked: {
        console.log("Wallpaper button clicked")
        WallpaperPickerBridge.show()
    }
}
