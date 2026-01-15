// ThemeManager.qml - Catppuccin Mocha Theme
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    
    property string currentTheme: "catppuccin-mocha"
    
    // Catppuccin Mocha Theme Colors
    property color accentBlue: "#89b4fa"
    Behavior on accentBlue { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentPurple: "#cba6f7"
    Behavior on accentPurple { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentRed: "#f38ba8"
    Behavior on accentRed { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentMaroon: "#eba0ac"
    Behavior on accentMaroon { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentYellow: "#f9e2af"
    Behavior on accentYellow { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentGreen: "#a6e3a1"
    Behavior on accentGreen { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentOrange: "#fab387"
    Behavior on accentOrange { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentPink: "#f5c2e7"
    Behavior on accentPink { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentCyan: "#89dceb"
    Behavior on accentCyan { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color accentTeal: "#94e2d5"
    Behavior on accentTeal { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color fgPrimary: "#cdd6f4"
    Behavior on fgPrimary { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color fgSecondary: "#bac2de"
    Behavior on fgSecondary { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color fgTertiary: "#a6adc8"
    Behavior on fgTertiary { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color bgBase: "#1e1e2e"
    Behavior on bgBase { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color bgMantle: "#181825"
    Behavior on bgMantle { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color bgCrust: "#11111b"
    Behavior on bgCrust { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color surface0: "#313244"
    Behavior on surface0 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color surface1: "#45475a"
    Behavior on surface1 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color surface2: "#585b70"
    Behavior on surface2 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color border0: "#6c7086"
    Behavior on border0 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color border1: "#7f849c"
    Behavior on border1 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    property color border2: "#9399b2"
    Behavior on border2 { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
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
