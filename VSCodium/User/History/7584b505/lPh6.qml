import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Files"
    onClicked: Process.execute("nautilus")
}
