pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "Catppuccin"
    
    // Accent colors
    property color accentRose: "#f5e0dc"
    property color accentCoral: "#f2cdcd" 
    property color accentPink: "#f5c2e7"
    property color accentPurple: "#cba6f7"
    property color accentRed: "#f38ba8"
    property color accentMaroon: "#eba0ac"
    property color accentOrange: "#fab387"
    property color accentYellow: "#f9e2af"
    property color accentGreen: "#a6e3a1"
    property color accentTeal: "#94e2d5"
    property color accentCyan: "#89dceb"
    property color accentSapphire: "#74c7ec"
    property color accentBlue: "#89b4fa"
    property color accentLavender: "#b4befe"
    
    // Text colors  
    property color fgPrimary: "#cdd6f4"
    property color fgSecondary: "#bac2de"
    property color fgTertiary: "#a6adc8"
    
    // Border colors
    property color border2: "#9399b2"
    property color border1: "#7f849c"
    property color border0: "#6c7086"
    
    // Surface colors
    property color surface2: "#585b70"
    property color surface1: "#45475a"
    property color surface0: "#313244"
    
    // Background colors
    property color bgBase: "#1e1e2e"
    property color bgBaseAlpha: "#FF1e1e2e"
    property color bgMantle: "#181825"
    property color bgCrust: "#11111b"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
