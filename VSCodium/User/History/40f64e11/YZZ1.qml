import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Terminal"
    onClicked: Quickshell.execDetached("kitty")
}
