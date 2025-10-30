import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Terminal"
    onClicked: Process.execute("kitty")
}
