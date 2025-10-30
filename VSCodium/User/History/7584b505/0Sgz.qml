import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Files"
    onClicked: Quickshell.execDetached("nautilus")
}
