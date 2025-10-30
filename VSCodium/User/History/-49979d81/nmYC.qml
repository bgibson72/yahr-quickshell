import QtQuick
import Quickshell

IconButton {
    id: themeButton
    icon: ""
    tooltip: "Theme Switcher"
    
    signal toggleThemeSwitcher()
    
    onClicked: {
        console.log("ThemeButton clicked - emitting signal");
        toggleThemeSwitcher();
    }
}
