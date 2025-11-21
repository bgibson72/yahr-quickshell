#!/bin/bash

# Sync Firefox Theme with Current Quickshell Theme
# Uses Firefox CSS to apply theme colors

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
FIREFOX_PROFILE="$HOME/.mozilla/firefox/g9e0jl2u.default-release"
CHROME_DIR="$FIREFOX_PROFILE/chrome"
USER_CSS="$CHROME_DIR/userChrome.css"
USER_CONTENT_CSS="$CHROME_DIR/userContent.css"

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found at $THEME_MANAGER"
    exit 1
fi

# Check if Firefox profile exists
if [[ ! -d "$FIREFOX_PROFILE" ]]; then
    echo "Error: Firefox profile not found at $FIREFOX_PROFILE"
    exit 1
fi

# Create chrome directory if it doesn't exist
mkdir -p "$CHROME_DIR"

# Extract theme colors
theme_name=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_cyan=$(grep 'property color accentCyan:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_green=$(grep 'property color accentGreen:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_red=$(grep 'property color accentRed:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_yellow=$(grep 'property color accentYellow:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_secondary=$(grep 'property color fgSecondary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface0=$(grep 'property color surface0:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface1=$(grep 'property color surface1:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

# Fallback to cyan if blue doesn't exist
if [[ -z "$accent_blue" ]]; then
    accent_blue="$accent_cyan"
fi

echo "Syncing Firefox theme for: $theme_name"

# Create userChrome.css
cat > "$USER_CSS" << EOF
/* Firefox Theme - Auto-synced with Quickshell Theme: $theme_name */

:root {
    --bg-base: $bg_base !important;
    --surface0: $surface0 !important;
    --surface1: $surface1 !important;
    --fg-primary: $fg_primary !important;
    --fg-secondary: $fg_secondary !important;
    --accent-blue: $accent_blue !important;
    --accent-green: $accent_green !important;
    --accent-red: $accent_red !important;
    --accent-yellow: $accent_yellow !important;
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
}

/* Individual tabs */
.tabbrowser-tab,
.tabbrowser-tab > .tab-stack > .tab-background {
    background-color: var(--surface0) !important;
    color: var(--fg-secondary) !important;
}

/* Selected/active tab */
.tabbrowser-tab[selected="true"],
.tabbrowser-tab[selected="true"] > .tab-stack > .tab-background {
    background-color: var(--surface1) !important;
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

/* URL bar and search bar */
#urlbar,
#urlbar-background,
#urlbar-input-container,
#searchbar {
    background-color: var(--surface1) !important;
    color: var(--fg-primary) !important;
    border: 1px solid var(--surface1) !important;
}

#urlbar[focused="true"],
#urlbar[focused="true"] #urlbar-background,
#searchbar:focus-within {
    border-color: var(--accent-blue) !important;
    box-shadow: 0 0 0 1px var(--accent-blue) !important;
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
