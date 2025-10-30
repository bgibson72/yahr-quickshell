import QtQuick
import Quickshell

IconButton {
    icon: "󰹑"
    tooltip: "Screenshot"
    onClicked: Process.execute("hyprshot", ["-m", "region"])
}
