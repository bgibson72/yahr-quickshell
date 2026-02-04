// ThemeManager.qml - Monochrome Theme
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    
    property string currentTheme: "monochrome"
    property string themeName: "Monochrome"
    
    // Monochrome Theme Colors (based on Equilux GTK theme)
    property color accentBlue: "#a0a0a0"
    property color accentPurple: "#8c8c8c"
    property color accentRed: "#808080"
    property color accentMaroon: "#737373"
    property color accentYellow: "#b0b0b0"
    property color accentGreen: "#8c8c8c"
    property color accentOrange: "#666666"
    property color accentPink: "#9e9e9e"
    property color accentCyan: "#737373"
    property color accentTeal: "#808080"
    property color accentRose: "#bebebe"
    property color accentCoral: "#a8a8a8"
    property color accentSapphire: "#666666"
    property color accentLavender: "#b0b0b0"
    
    property color fgPrimary: "#bebebe"
    property color fgSecondary: "#afafaf"
    property color fgTertiary: "#969696"
    
    property color bgBase: "#252525"
    property color bgMantle: "#1f1f1f"
    property color bgCrust: "#191919"
    
    property color surface0: "#323232"
    property color surface1: "#373737"
    property color surface2: "#3c3c3c"
    
    property color border0: "#404040"
    property color border1: "#4d4d4d"
    property color border2: "#5a5a5a"
    
    property real barOpacity: 0.90
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
