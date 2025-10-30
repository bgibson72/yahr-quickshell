import QtQuick
import Quickshell

IconButton {
    id: themeButton
    icon: "\uf1fc"
    tooltip: "Theme Switcher"
    
    signal toggleThemeSwitcher()
    
    onClicked: {
        console.log("ThemeButton clicked - emitting signal");
        toggleThemeSwitcher();
    }
}
