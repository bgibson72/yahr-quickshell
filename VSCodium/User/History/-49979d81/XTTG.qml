import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Theme Switcher"
    onClicked: {
        var scriptPath = Quickshell.env("HOME") + "/.config/quickshell/theme-switcher-quickshell"
        console.log("Launching Quickshell theme switcher:", scriptPath, "--wofi")
        Quickshell.execDetached([scriptPath, "--wofi"])
    }
}
