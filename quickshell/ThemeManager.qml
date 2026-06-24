pragma Singleton

import QtQuick

QtObject {
    // Theme name
    property string themeName: "NightFox"
    
    // Bar opacity setting (0.0 - 1.0)
    property real barOpacity: 0.70
    
    // Accent colors
    property color accentRose: "#ea9a97"
    property color accentCoral: "#eb746b" 
    property color accentPink: "#eb98c3"
    property color accentPurple: "#a78cfa"
    property color accentRed: "#eb746b"
    property color accentMaroon: "#d67f8a"
    property color accentOrange: "#ea9a97"
    property color accentYellow: "#f6b079"
    property color accentGreen: "#7eb4b3"
    property color accentTeal: "#569fba"
    property color accentCyan: "#7eb4b3"
    property color accentSapphire: "#6db3ce"
    property color accentBlue: "#6db3ce"
    property color accentLavender: "#a78cfa"
    
    // Text colors  
    property color fgPrimary: "#cdcbe0"
    property color fgSecondary: "#aeafca"
    property color fgTertiary: "#9b9cb8"
    
    // Border colors
    property color border2: "#817c9c"
    property color border1: "#6e6a86"
    property color border0: "#555169"
    
    // Surface colors
    property color surface2: "#3f3d54"
    property color surface1: "#32303f"
    property color surface0: "#2b2837"
    
    // Background colors
    property color bgBase: "#232136"
    property color bgBaseAlpha: Qt.rgba(bgBase.r, bgBase.g, bgBase.b, barOpacity)
    property color bgMantle: "#1e1e2e"
    property color bgCrust: "#131021"
    
    // Font sizes
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeIcon: 14

    // Persistent user preferences (preserved across theme switches)
    property real widgetOpacity: 1.0
    property bool barLarge: true
    property string uiFont: "Inter"
    property int hyprRounding: 12
    property bool showWidgetBorders: false
    property int widgetBorderWidth: 3
    property string workspaceStyle: "dots"
}
