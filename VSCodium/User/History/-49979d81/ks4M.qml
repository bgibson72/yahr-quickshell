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
