// ThemeManager.qml - Reads and applies Hyprland themes to Quickshell
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: themeManager
    
    // Current theme name
    property string currentTheme: "tokyonight-night"
    
    // Theme colors (defaults to Tokyo Night)
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
    
    // Alpha versions (opacity 85%)
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
    
    // Component function to parse theme file
    function loadTheme() {
        let homeDir = Quickshell.env("HOME")
        let themeFile = homeDir + "/.config/hypr/themes/" + currentTheme + ".conf"
        
        // Read current theme from hyprland.conf
        let hyprlandConf = homeDir + "/.config/hypr/hyprland.conf"
        let readTheme = Process.exec("sh", ["-c", 
            `grep -oP 'source.*themes/\\K[^.]+' "${hyprlandConf}" | head -1`
        ])
        
        // Wait for process to complete
        readTheme.finished.connect(() => {
            let themeName = readTheme.stdout.trim()
            if (themeName && themeName.length > 0) {
                currentTheme = themeName
                console.log("Detected theme:", currentTheme)
                parseThemeFile()
            }
        })
    }
    
    function parseThemeFile() {
        let homeDir = Quickshell.env("HOME")
        let themeFile = homeDir + "/.config/hypr/themes/" + currentTheme + ".conf"
        
        // Read theme file
        let readFile = Process.exec("cat", [themeFile])
        readFile.finished.connect(() => {
            let content = readFile.stdout
            parseThemeContent(content)
        })
    }
    
    function parseThemeContent(content) {
        let lines = content.split('\n')
        
        for (let line of lines) {
            line = line.trim()
            if (line.startsWith('$accent-blue =')) {
                accentBlue = extractColor(line)
            } else if (line.startsWith('$accent-purple =')) {
                accentPurple = extractColor(line)
            } else if (line.startsWith('$accent-red =')) {
                accentRed = extractColor(line)
            } else if (line.startsWith('$accent-maroon =')) {
                accentMaroon = extractColor(line)
            } else if (line.startsWith('$accent-yellow =')) {
                accentYellow = extractColor(line)
            } else if (line.startsWith('$accent-green =')) {
                accentGreen = extractColor(line)
            } else if (line.startsWith('$accent-orange =')) {
                accentOrange = extractColor(line)
            } else if (line.startsWith('$accent-pink =')) {
                accentPink = extractColor(line)
            } else if (line.startsWith('$accent-cyan =')) {
                accentCyan = extractColor(line)
            } else if (line.startsWith('$accent-teal =')) {
                accentTeal = extractColor(line)
            } else if (line.startsWith('$fg-primary =')) {
                fgPrimary = extractColor(line)
            } else if (line.startsWith('$fg-secondary =')) {
                fgSecondary = extractColor(line)
            } else if (line.startsWith('$fg-tertiary =')) {
                fgTertiary = extractColor(line)
            } else if (line.startsWith('$bg-base =')) {
                bgBase = extractColor(line)
                updateBgBaseAlpha()
            } else if (line.startsWith('$bg-mantle =')) {
                bgMantle = extractColor(line)
            } else if (line.startsWith('$bg-crust =')) {
                bgCrust = extractColor(line)
            } else if (line.startsWith('$surface-0 =')) {
                surface0 = extractColor(line)
            } else if (line.startsWith('$surface-1 =')) {
                surface1 = extractColor(line)
            } else if (line.startsWith('$surface-2 =')) {
                surface2 = extractColor(line)
            } else if (line.startsWith('$border-0 =')) {
                border0 = extractColor(line)
            } else if (line.startsWith('$border-1 =')) {
                border1 = extractColor(line)
            } else if (line.startsWith('$border-2 =')) {
                border2 = extractColor(line)
            }
        }
        
        console.log("Theme loaded:", currentTheme)
        console.log("Accent blue:", accentBlue)
        console.log("Background:", bgBase)
    }
    
    function extractColor(line) {
        // Extract color from line like: $accent-blue = rgb(7aa2f7)
        let match = line.match(/rgb\(([a-fA-F0-9]{6})\)/)
        if (match && match[1]) {
            return "#" + match[1]
        }
        return "#000000"
    }
    
    function updateBgBaseAlpha() {
        let r = parseInt(bgBase.toString().substr(1,2), 16) / 255
        let g = parseInt(bgBase.toString().substr(3,2), 16) / 255
        let b = parseInt(bgBase.toString().substr(5,2), 16) / 255
        bgBaseAlpha = Qt.rgba(r, g, b, barOpacity)
    }
    
    // Initialize theme on startup
    Component.onCompleted: {
        loadTheme()
    }
}
