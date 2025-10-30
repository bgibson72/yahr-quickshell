import QtQuick
import Quickshell

IconButton {
    icon: "󰹑"
    tooltip: "Screenshot"
    onClicked: Quickshell.execDetached(["/home/bryan/.config/quickshell/toggle-screenshot"])
}
