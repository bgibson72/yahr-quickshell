pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "Material"
    
    // Accent colors
    property color accentRose: "#f78c6c"
    property color accentCoral: "#ff5370" 
    property color accentPink: "#f07178"
    property color accentPurple: "#c792ea"
    property color accentRed: "#ff5370"
    property color accentMaroon: "#ec5f67"
    property color accentOrange: "#f78c6c"
    property color accentYellow: "#ffcb6b"
    property color accentGreen: "#c3e88d"
    property color accentTeal: "#89ddff"
    property color accentCyan: "#89ddff"
    property color accentSapphire: "#89ddff"
    property color accentBlue: "#82aaff"
    property color accentLavender: "#b2ccd6"
    
    // Text colors  
    property color fgPrimary: "#eeffff"
    property color fgSecondary: "#b2ccd6"
    property color fgTertiary: "#89ddff"
    
    // Border colors
    property color border2: "#676e95"
    property color border1: "#4a5f7d"
    property color border0: "#3b4f6c"
    
    // Surface colors
    property color surface2: "#303348"
    property color surface1: "#212337"
    property color surface0: "#1b1e2b"
    
    // Background colors
    property color bgBase: "#0f111a"
    property color bgBaseAlpha: "#FF0f111a"
    property color bgMantle: "#090b10"
    property color bgCrust: "#000000"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
