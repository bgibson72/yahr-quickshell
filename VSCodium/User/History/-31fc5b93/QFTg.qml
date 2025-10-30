// ThemeManager.qml - Gruvbox Dark Theme
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    
    property string currentTheme: "gruvbox-dark"
    
    // Gruvbox Dark Theme Colors
    property color accentBlue: "#83a598"
    property color accentPurple: "#d3869b"
    property color accentRed: "#fb4934"
    property color accentMaroon: "#cc241d"
    property color accentYellow: "#fabd2f"
    property color accentGreen: "#b8bb26"
    property color accentOrange: "#fe8019"
    property color accentPink: "#d3869b"
    property color accentCyan: "#8ec07c"
    property color accentTeal: "#689d6a"
    
    property color fgPrimary: "#ebdbb2"
    property color fgSecondary: "#d5c4a1"
    property color fgTertiary: "#bdae93"
    
    property color bgBase: "#282828"
    property color bgMantle: "#1d2021"
    property color bgCrust: "#1d2021"
    
    property color surface0: "#3c3836"
    property color surface1: "#504945"
    property color surface2: "#665c54"
    
    property color border0: "#7c6f64"
    property color border1: "#928374"
    property color border2: "#a89984"
    
    property real barOpacity: 0.85
    property color bgBaseAlpha: Qt.rgba(
        parseInt(bgBase.toString().substr(1,2), 16) / 255,
        parseInt(bgBase.toString().substr(3,2), 16) / 255,
        parseInt(bgBase.toString().substr(5,2), 16) / 255,
        barOpacity
    )
    
    property int fontSizeClock: 14
    property int fontSizeWorkspace: 14
    property int fontSizeUpdates: 14
    property int fontSizeIcon: 16
    property int fontSizeLargeIcon: 24
}
