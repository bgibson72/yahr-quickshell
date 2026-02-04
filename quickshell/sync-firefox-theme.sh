#!/bin/bash

# Sync Firefox Theme with Current Quickshell Theme
# Uses Firefox CSS to apply theme colors

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

# Auto-detect Firefox profile
FIREFOX_BASE="$HOME/.mozilla/firefox"
FIREFOX_PROFILE=$(find "$FIREFOX_BASE" -maxdepth 1 -name "*.default-release" -type d | head -1)

if [[ -z "$FIREFOX_PROFILE" ]]; then
    echo "Error: Firefox profile not found"
    exit 1
fi

CHROME_DIR="$FIREFOX_PROFILE/chrome"
USER_CSS="$CHROME_DIR/userChrome.css"

# Get current theme from Hyprland config
THEME_FILE=$(grep "^source.*themes.*\.conf" "$HYPRLAND_CONF" | sed 's/.*= *//')

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    echo "Error: Could not determine theme file from Hyprland config"
    exit 1
fi

theme_name=$(basename "$THEME_FILE" .conf)
theme_name=$(basename "$THEME_FILE" .conf)

# Create chrome directory if it doesn't exist
mkdir -p "$CHROME_DIR"

# Function to extract colors from Hyprland theme file
get_color() {
    local color_var="$1"
    grep "^$color_var" "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1
}

# Extract theme colors from Hyprland theme
accent_blue=$(get_color '\$accent-blue')
accent_green=$(get_color '\$accent-green')
accent_red=$(get_color '\$accent-red')
accent_yellow=$(get_color '\$accent-yellow')
fg_primary=$(get_color '\$fg-primary')
fg_secondary=$(get_color '\$fg-secondary')
bg_base=$(get_color '\$bg-base')
surface0=$(get_color '\$surface-0')
surface1=$(get_color '\$surface-1')

# Fallback to cyan if blue doesn't exist
if [[ -z "$accent_blue" ]]; then
    accent_blue=$(get_color '\$accent-cyan')
fi

echo "Syncing Firefox theme for: $theme_name"

# Create userChrome.css
cat > "$USER_CSS" << EOF
/* Firefox Theme - Auto-synced with Quickshell Theme: $theme_name */

:root {
    --bg-base: #$bg_base !important;
    --surface0: #$surface0 !important;
    --surface1: #$surface1 !important;
    --fg-primary: #$fg_primary !important;
    --fg-secondary: #$fg_secondary !important;
    --accent-blue: #$accent_blue !important;
    --accent-green: #$accent_green !important;
    --accent-red: #$accent_red !important;
    --accent-yellow: #$accent_yellow !important;
}

/* Normalize font rendering and spacing */
* {
    letter-spacing: normal !important;
    word-spacing: normal !important;
}

/* Main toolbar and tab bar background */
#navigator-toolbox,
#TabsToolbar,
#nav-bar,
#PersonalToolbar,
toolbar {
    background-color: var(--bg-base) !important;
    background-image: none !important;
    border: none !important;
    box-shadow: none !important;
}

/* Remove all borders from tab area */
#tabbrowser-tabs,
.tabbrowser-arrowscrollbox,
#TabsToolbar-customization-target {
    border: none !important;
}

/* Individual tabs */
.tabbrowser-tab,
.tabbrowser-tab > .tab-stack > .tab-background {
    background-color: var(--surface0) !important;
    color: var(--fg-secondary) !important;
    border: none !important;
    border-radius: 0 !important;
    margin: 0 !important;
    padding: 0 !important;
    outline: none !important;
    box-shadow: none !important;
}

/* Selected/active tab */
.tabbrowser-tab[selected="true"],
.tabbrowser-tab[selected="true"] > .tab-stack > .tab-background {
    background-color: var(--surface1) !important;
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
}

.tabbrowser-tab[selected="true"] .tab-label,
.tabbrowser-tab[selected="true"] .tab-text {
    color: var(--fg-primary) !important;
}

/* Tab hover */
.tabbrowser-tab:hover:not([selected="true"]) > .tab-stack > .tab-background {
    background-color: var(--surface1) !important;
}

/* Tab text */
.tab-label,
.tab-text {
    color: var(--fg-secondary) !important;
}

/* Remove tab separators and borders */
.tabbrowser-tab::after,
.tabbrowser-tab::before,
.titlebar-spacer[type="pre-tabs"],
.titlebar-spacer[type="post-tabs"] {
    display: none !important;
    border: none !important;
}

/* Remove tab content area border */
.tab-content {
    border: none !important;
    outline: none !important;
}

/* URL bar and search bar - remove all borders */
#urlbar,
#urlbar-background,
#urlbar-input-container,
#searchbar,
.searchbar-textbox {
    background-color: var(--surface1) !important;
    color: var(--fg-primary) !important;
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
    -moz-appearance: none !important;
}

/* Force URL bar input text color */
#urlbar-input,
#urlbar input {
    color: var(--fg-primary) !important;
    background-color: transparent !important;
}

/* URL bar when it expands on focus */
#urlbar[breakout][breakout-extend] {
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
}

#urlbar[breakout][breakout-extend] > #urlbar-background {
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
}

/* URL bar focused - no visible border */
#urlbar[focused="true"],
#urlbar[focused="true"] #urlbar-background,
#urlbar[open],
#urlbar[open] #urlbar-background {
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
}

#searchbar:focus-within {
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
}

/* Remove default URL bar border containers */
#urlbar-container,
#search-container {
    border: none !important;
    box-shadow: none !important;
}

/* URL bar text */
#urlbar-input,
.searchbar-textbox {
    color: var(--fg-primary) !important;
}

/* URL bar dropmarker and buttons */
#urlbar toolbarbutton,
#page-action-buttons > toolbarbutton,
#urlbar-zoom-button {
    fill: var(--fg-primary) !important;
    color: var(--fg-primary) !important;
}

/* Autocomplete dropdown */
#urlbar-results,
.urlbarView,
.search-panel-one-offs {
    background-color: var(--surface0) !important;
    color: var(--fg-primary) !important;
    border-color: var(--surface1) !important;
}

.urlbarView-row {
    background-color: var(--surface0) !important;
    color: var(--fg-primary) !important;
}

.urlbarView-row[selected] {
    background-color: var(--accent-blue) !important;
    color: var(--bg-base) !important;
}

/* Toolbar buttons */
toolbarbutton,
.toolbarbutton-1 {
    fill: var(--fg-primary) !important;
    color: var(--fg-primary) !important;
}

toolbarbutton:hover,
.toolbarbutton-1:hover {
    background-color: var(--surface1) !important;
}

/* Sidebar */
#sidebar-box,
#sidebar-header {
    background-color: var(--bg-base) !important;
    color: var(--fg-primary) !important;
    border-color: var(--surface1) !important;
}

/* Context menus and dropdowns */
menupopup,
menu,
menuitem,
.panel-arrowcontent {
    background-color: var(--surface0) !important;
    color: var(--fg-primary) !important;
    -moz-appearance: none !important;
}

menupopup menu,
menupopup menuitem {
    background-color: var(--surface0) !important;
    color: var(--fg-primary) !important;
}

menupopup menu[_moz-menuactive="true"],
menupopup menuitem[_moz-menuactive="true"],
menuitem:hover {
    background-color: var(--accent-blue) !important;
    color: var(--bg-base) !important;
}

/* Bookmarks bar */
#PlacesToolbarItems > .bookmark-item {
    color: var(--fg-primary) !important;
}

#PlacesToolbarItems > .bookmark-item:hover {
    background-color: var(--surface1) !important;
}

/* Findbar */
findbar {
    background-color: var(--surface0) !important;
    border-color: var(--surface1) !important;
}

.findbar-textbox {
    background-color: var(--surface1) !important;
    color: var(--fg-primary) !important;
}

/* Tab line indicator */
.tab-line {
    background-color: var(--accent-blue) !important;
}

/* Notification box */
notification,
.notificationbox-stack {
    background-color: var(--surface1) !important;
    color: var(--fg-primary) !important;
}
EOF

# Create userContent.css for web page styling (optional - dark pages)
cat > "$USER_CONTENT_CSS" << EOF
/* Firefox Content Theme - Auto-synced with Quickshell Theme: $theme_name */
/* This styles Firefox's internal pages (about:, preferences, etc.) */

@-moz-document url-prefix(about:), url-prefix(chrome://) {
    :root {
        --bg-base: $bg_base !important;
        --surface0: $surface0 !important;
        --surface1: $surface1 !important;
        --fg-primary: $fg_primary !important;
        --fg-secondary: $fg_secondary !important;
        --accent-blue: $accent_blue !important;
    }
    
    body, html {
        background-color: var(--bg-base) !important;
        color: var(--fg-primary) !important;
    }
}
EOF

# Enable userChrome.css in Firefox (requires setting in about:config)
PREFS_JS="$FIREFOX_PROFILE/prefs.js"
if [[ -f "$PREFS_JS" ]]; then
    # Check if the setting exists
    if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$PREFS_JS"; then
        # Firefox needs to be closed to modify prefs.js safely
        if pgrep -x firefox > /dev/null; then
            echo "⚠ Firefox is running. Close Firefox and run this script again, or:"
            echo "  1. Open Firefox"
            echo "  2. Type 'about:config' in the address bar"
            echo "  3. Search for 'toolkit.legacyUserProfileCustomizations.stylesheets'"
            echo "  4. Set it to 'true'"
            echo "  5. Restart Firefox"
        else
            echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$PREFS_JS"
            echo "✓ Enabled userChrome.css support"
        fi
    fi
fi

echo "✓ Firefox theme files created"
echo "  Theme: $theme_name"
echo "  userChrome.css: $USER_CSS"
echo ""

if pgrep -x firefox > /dev/null; then
    echo "⚠ Firefox is running - restart Firefox to apply the theme"
else
    echo "✓ Launch Firefox to see the new theme"
fi
