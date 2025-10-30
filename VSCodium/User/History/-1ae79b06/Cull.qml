// ThemeManager.qml - Catppuccin Mocha Theme
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    
    property string currentTheme: "catppuccin-mocha"
    
    // Catppuccin Mocha Theme Colors
    property color accentBlue: "#89b4fa"
    property color accentPurple: "#cba6f7"
    property color accentRed: "#f38ba8"
    property color accentMaroon: "#eba0ac"
    property color accentYellow: "#f9e2af"
    property color accentGreen: "#a6e3a1"
    property color accentOrange: "#fab387"
    property color accentPink: "#f5c2e7"
    property color accentCyan: "#89dceb"
    property color accentTeal: "#94e2d5"
    
    property color fgPrimary: "#cdd6f4"
    property color fgSecondary: "#bac2de"
    property color fgTertiary: "#a6adc8"
    
    property color bgBase: "#1e1e2e"
    property color bgMantle: "#181825"
    property color bgCrust: "#11111b"
    
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    
    property color border0: "#6c7086"
    property color border1: "#7f849c"
    property color border2: "#9399b2"
    
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
