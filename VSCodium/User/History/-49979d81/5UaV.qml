import QtQuick
import Quickshell

IconButton {
    icon: "󰏘"
    tooltip: "Theme Switcher"
    
    onClicked: {
        console.log("Toggling theme switcher widget")
        // Toggle via the shell root's property
        ShellRoot.themeSwitcherVisible = !ShellRoot.themeSwitcherVisible
    }
}
