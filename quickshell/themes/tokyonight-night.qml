// ThemeManager.qml - Theme colors for Quickshell
pragma Singleton
import QtQuick

QtObject {
    id: themeManager
    
    // Current theme name (change this to match your Hyprland theme)
    property string currentTheme: "tokyonight-night"
    
    // Tokyo Night Theme Colors (default)
    property color accentBlue: "#7aa2f7"
    property color accentPurple: "#9d7cd8"
    property color accentRed: "#f7768e"
    property color accentMaroon: "#db4b4b"
    property color accentYellow: "#e0af68"
    property color accentGreen: "#9ece6a"
    property color accentOrange: "#ff9e64"
    property color accentPink: "#bb9af7"
    property color accentCyan: "#73daca"
    property color accentTeal: "#1abc9c"
    
    property color fgPrimary: "#c0caf5"
    property color fgSecondary: "#a9b1d6"
    property color fgTertiary: "#9aa5ce"
    
    property color bgBase: "#1a1b26"
    property color bgMantle: "#16161e"
    property color bgCrust: "#0f0f14"
    
    property color surface0: "#292e42"
    property color surface1: "#33467c"
    property color surface2: "#414868"
    
    property color border0: "#565f89"
    property color border1: "#737aa2"
    property color border2: "#828bb8"
    
    // Alpha version for bar background (85% opacity)
    property real barOpacity: 0.85
    property color bgBaseAlpha: Qt.rgba(
        parseInt(bgBase.toString().substr(1,2), 16) / 255,
        parseInt(bgBase.toString().substr(3,2), 16) / 255,
        parseInt(bgBase.toString().substr(5,2), 16) / 255,
        barOpacity
    )
    
    // Font sizes
    property int fontSizeClock: 14
    property int fontSizeWorkspace: 14
    property int fontSizeUpdates: 14
    property int fontSizeIcon: 16
    property int fontSizeLargeIcon: 24
    
    // To change themes, edit the colors above to match your theme:
    // Colors can be found in ~/.config/hypr/themes/[theme-name].conf
    //
    // For Catppuccin Mocha, use:
    // accentBlue: "#89b4fa"
    // fgPrimary: "#cdd6f4"
    // bgBase: "#1e1e2e"
    // surface0: "#313244"
    // etc.
}
