import QtQuick
import Quickshell

IconButton {
    icon: ""
    tooltip: "Theme Switcher"
    onClicked: Process.execute(Qt.resolvedUrl("~/.local/bin/theme-switcher").toString().replace("file://", ""), ["--wofi"])
}
