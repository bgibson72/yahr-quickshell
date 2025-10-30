import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Theme Switcher"
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/theme-switcher.sh --wofi"])
}
