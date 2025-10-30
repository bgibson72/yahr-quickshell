import QtQuick
import Quickshell

IconButton {
    icon: "󰹑"
    tooltip: "Screenshot"
    onClicked: Quickshell.execDetached("hyprshot", ["-m", "region"])
}
