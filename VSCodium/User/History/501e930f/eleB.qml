import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Firefox"
    onClicked: Quickshell.execDetached("firefox")
}
