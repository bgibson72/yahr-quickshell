import QtQuick
import Quickshell

IconButton {
    id: themeButton
    icon: "󰏘"
    tooltip: "Theme Switcher"
    
    // Access the root item through the parent chain
    property var rootItem: {
        var item = parent;
        while (item && item.objectName !== "shellRoot") {
            item = item.parent;
        }
        return item;
    }
    
    onClicked: {
        if (rootItem) {
            console.log("Toggling theme switcher widget")
            rootItem.themeSwitcherVisible = !rootItem.themeSwitcherVisible
        } else {
            console.error("Could not find shellRoot")
        }
    }
}
