import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Files"
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/launch-thunar.sh"])
}
