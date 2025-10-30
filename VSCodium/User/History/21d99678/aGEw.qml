import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Wallpaper Picker"
    onClicked: {
        // Find and show the wallpaper picker
        const root = Quickshell.findObjectByName("shellRoot")
        if (root && root.wallpaperPicker) {
            root.wallpaperPicker.show()
        }
    }
}
