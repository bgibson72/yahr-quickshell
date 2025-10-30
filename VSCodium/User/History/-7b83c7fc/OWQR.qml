pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "gruvbox-dark"
    
    // Accent colors
    property color accentRose: "#fe8019"
    property color accentCoral: "#fb4934" 
    property color accentPink: "#d3869b"
    property color accentPurple: "#b16286"
    property color accentRed: "#fb4934"
    property color accentMaroon: "#cc241d"
    property color accentOrange: "#fe8019"
    property color accentYellow: "#fabd2f"
    property color accentGreen: "#b8bb26"
    property color accentTeal: "#8ec07c"
    property color accentCyan: "#83a598"
    property color accentSapphire: "#458588"
    property color accentBlue: "#83a598"
    property color accentLavender: "#d3869b"
    
    // Text colors  
    property color fgPrimary: "#ebdbb2"
    property color fgSecondary: "#d5c4a1"
    property color fgTertiary: "#bdae93"
    
    // Border colors
    property color border2: "#a89984"
    property color border1: "#928374"
    property color border0: "#7c6f64"
    
    // Surface colors
    property color surface2: "#665c54"
    property color surface1: "#504945"
    property color surface0: "#3c3836"
    
    // Background colors
    property color bgBase: "#282828"
    property color bgBaseAlpha: "#FF282828"
    property color bgMantle: "#1d2021"
    property color bgCrust: "#0f0f0f"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
