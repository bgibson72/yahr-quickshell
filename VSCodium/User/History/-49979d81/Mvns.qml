import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Theme Switcher"
    
    property var shellRoot: null
    
    Component.onCompleted: {
        // Find the ShellRoot instance
        shellRoot = Quickshell.findObject("shellRoot")
    }
    
    onClicked: {
        console.log("Toggling theme switcher widget")
        if (shellRoot) {
            shellRoot.toggleThemeSwitcher()
        }
    }
}

    icon: ""
    tooltip: "Theme Switcher"
    onClicked: {
        var scriptPath = Quickshell.env("HOME") + "/.config/quickshell/theme-switcher-quickshell"
        console.log("Launching Quickshell theme switcher:", scriptPath, "--wofi")
        Quickshell.execDetached([scriptPath, "--wofi"])
    }
}
