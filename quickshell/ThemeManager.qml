pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "Eldritch"
    
    // Bar opacity setting (0.0 - 1.0)
    property real barOpacity: 0.750495079212674
    
    // Accent colors
    property color accentRose: "#f265b5"
    property color accentCoral: "#f265b5" 
    property color accentPink: "#f265b5"
    property color accentPurple: "#a48cf2"
    property color accentRed: "#f16c75"
    property color accentMaroon: "#f16c75"
    property color accentOrange: "#f7c67f"
    property color accentYellow: "#f1fc79"
    property color accentGreen: "#37f499"
    property color accentTeal: "#04d1f9"
    property color accentCyan: "#04d1f9"
    property color accentSapphire: "#04d1f9"
    property color accentBlue: "#a48cf2"
    property color accentLavender: "#a48cf2"
    
    // Text colors  
    property color fgPrimary: "#ebfafa"
    property color fgSecondary: "#ebfafa"
    property color fgTertiary: "#7081d0"
    
    // Border colors
    property color border2: "#7081d0"
    property color border1: "#7081d0"
    property color border0: "#323449"
    
    // Surface colors
    property color surface2: "#323449"
    property color surface1: "#323449"
    property color surface0: "#323449"
    
    // Background colors
    property color bgBase: "#212337"
    property color bgBaseAlpha: Qt.rgba(bgBase.r, bgBase.g, bgBase.b, barOpacity)
    property color bgMantle: "#212337"
    property color bgCrust: "#212337"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14
}
