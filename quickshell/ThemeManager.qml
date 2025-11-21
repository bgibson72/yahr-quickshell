pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "Everforest"
    
    // Accent colors
    property color accentRose: "#e69875"
    property color accentCoral: "#e67e80" 
    property color accentPink: "#d699b6"
    property color accentPurple: "#d3869b"
    property color accentRed: "#e67e80"
    property color accentMaroon: "#e67e80"
    property color accentOrange: "#e69875"
    property color accentYellow: "#dbbc7f"
    property color accentGreen: "#a7c080"
    property color accentTeal: "#83c092"
    property color accentCyan: "#7fbbb3"
    property color accentSapphire: "#7fbbb3"
    property color accentBlue: "#7fbbb3"
    property color accentLavender: "#a7c080"
    
    // Text colors  
    property color fgPrimary: "#d3c6aa"
    property color fgSecondary: "#bdc3af"
    property color fgTertiary: "#a7c080"
    
    // Border colors
    property color border2: "#859289"
    property color border1: "#7a8478"
    property color border0: "#656d5b"
    
    // Surface colors
    property color surface2: "#543a48"
    property color surface1: "#3d484d"
    property color surface0: "#374247"
    
    // Background colors
    property color bgBase: "#2b3339"
    property color bgBaseAlpha: "#FF2b3339"
    property color bgMantle: "#272e33"
    property color bgCrust: "#1e2326"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
