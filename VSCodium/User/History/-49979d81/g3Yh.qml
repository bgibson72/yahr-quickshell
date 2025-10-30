import QtQuick
import Quickshell

IconButton {
    icon: "󰏘"
    tooltip: "Theme Switcher"
    
    onClicked: {
        console.log("Toggling theme switcher widget via IPC")
        // Use IPC to toggle - same as keybind
        Quickshell.execDetached(["quickshell", "ipc", "call", "ShellRoot", "toggleThemeSwitcher"])
    }
}
