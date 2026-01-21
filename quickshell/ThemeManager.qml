pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "Kanagawa"
    
    // Accent colors
    property color accentRose: "#d27e99"
    property color accentCoral: "#e46876" 
    property color accentPink: "#d27e99"
    property color accentPurple: "#957fb8"
    property color accentRed: "#e46876"
    property color accentMaroon: "#e82424"
    property color accentOrange: "#ffa066"
    property color accentYellow: "#dca561"
    property color accentGreen: "#98bb6c"
    property color accentTeal: "#7fb4ca"
    property color accentCyan: "#7fb4ca"
    property color accentSapphire: "#7aa89f"
    property color accentBlue: "#7e9cd8"
    property color accentLavender: "#938aa9"
    
    // Text colors  
    property color fgPrimary: "#dcd7ba"
    property color fgSecondary: "#c8c093"
    property color fgTertiary: "#a6a69c"
    
    // Border colors
    property color border2: "#8a8980"
    property color border1: "#727169"
    property color border0: "#625e5a"
    
    // Surface colors
    property color surface2: "#49473e"
    property color surface1: "#363636"
    property color surface0: "#2a2a2a"
    
    // Background colors
    property color bgBase: "#1f1f28"
    property color bgBaseAlpha: "#FF1f1f28"
    property color bgMantle: "#16161d"
    property color bgCrust: "#0d0c0c"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
