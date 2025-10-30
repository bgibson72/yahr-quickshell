import QtQuickimport QtQuick

import Quickshellimport Quickshell



IconButton {IconButton {

    icon: ""    icon: ""

    tooltip: "Files"    tooltip: "Files"

    onClicked: Quickshell.execDetached(["thunar"])    onClicked: Quickshell.execDetached(["thunar"])

}}import Quickshell

IconButton {
    icon: ""
    tooltip: "Files"
    onClicked: Quickshell.execDetached(["thunar"])
}tQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Files"
    onClicked: Quickshell.execDetached("nautilus")
}
