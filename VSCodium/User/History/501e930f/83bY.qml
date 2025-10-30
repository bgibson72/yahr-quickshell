import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Firefox"
    onClicked: Process.execute("firefox")
}
