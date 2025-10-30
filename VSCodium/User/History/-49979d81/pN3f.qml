import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Theme Switcher"
    onClicked: {
        var scriptPath = Quickshell.env("HOME") + "/.local/bin/theme-switcher.sh"
        console.log("Launching theme switcher:", scriptPath, "--wofi")
        Quickshell.execDetached([scriptPath, "--wofi"])
    }
}
