import QtQuick
import Quickshell

IconButton {
    id: themeButton
    icon: "\uee26"
    tooltip: "Theme Switcher"QtQuick
import Quickshell

IconButton {
    id: themeButton
    icon: "�"
    tooltip: "Theme Switcher"
    
    // Access the root item through the parent chain
    property var rootItem: {
        var item = parent;
        while (item && item.objectName !== "shellRoot") {
            item = item.parent;
        }
        console.log("ThemeButton: Found root item:", item ? "YES" : "NO");
        return item;
    }
    
    onClicked: {
        console.log("ThemeButton clicked! rootItem:", rootItem);
        if (rootItem) {
            console.log("Current themeSwitcherVisible:", rootItem.themeSwitcherVisible);
            console.log("Toggling theme switcher widget");
            rootItem.themeSwitcherVisible = !rootItem.themeSwitcherVisible;
            console.log("New themeSwitcherVisible:", rootItem.themeSwitcherVisible);
        } else {
            console.error("Could not find shellRoot");
        }
    }
}
