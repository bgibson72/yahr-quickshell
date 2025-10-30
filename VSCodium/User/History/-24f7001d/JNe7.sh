#!/bin/bash
# Post-processor to add targeted selectors for Discord areas
# This runs automatically after sync-vencord-theme.sh

THEME_FILE="$HOME/.config/vesktop/themes/QuickshellSync.theme.css"

# Check if theme file exists
if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found at $THEME_FILE"
    exit 1
fi

# Check if catch-all is already present
if grep -q "COMPREHENSIVE CATCH-ALL" "$THEME_FILE"; then
    # Already has catch-all, skip
    exit 0
fi

# Get current theme colors from the file
BG_CRUST=$(grep -m1 'background-secondary-alt:' "$THEME_FILE" | sed 's/.*: #\([a-f0-9]*\).*/\1/')
BG_MANTLE=$(grep -m1 'background-secondary:' "$THEME_FILE" | sed 's/.*: #\([a-f0-9]*\).*/\1/')
BG_BASE=$(grep -m1 'background-primary:' "$THEME_FILE" | sed 's/.*: #\([a-f0-9]*\).*/\1/')
SURFACE_0=$(grep -m1 'background-tertiary:' "$THEME_FILE" | sed 's/.*: #\([a-f0-9]*\).*/\1/')

if [ -z "$BG_CRUST" ]; then BG_CRUST="1e2326"; fi
if [ -z "$BG_MANTLE" ]; then BG_MANTLE="272e33"; fi
if [ -z "$BG_BASE" ]; then BG_BASE="2b3339"; fi
if [ -z "$SURFACE_0" ]; then SURFACE_0="374247"; fi

# Add targeted selectors for Discord areas
cat >> "$THEME_FILE" << EOF

/* ========================================= */
/* TARGETED SELECTORS FOR DISCORD AREAS */
/* Auto-added by vencord-add-catchall.sh */
/* ========================================= */

/* Main app container */
[class*="app_"] {
    background-color: #${BG_CRUST} !important;
}

/* Chat/Content area */
[class*="chat_"]:not([class*="input"]):not([class*="button"]),
[class*="content_"]:not([class*="button"]):not([class*="tab"]):not([class*="message"]) {
    background-color: #${BG_BASE} !important;
}

/* Sidebar/Channel list */
[class*="sidebar_"],
[class*="panels_"],
[class*="panel_"] {
    background-color: #${BG_MANTLE} !important;
}

/* Server list (guilds) */
[class*="guilds_"],
[class*="wrapper_"][class*="guilds"] {
    background-color: #${BG_CRUST} !important;
}

/* Server icons scroller/stack */
div[class*="stack_"],
[class*="scroller_"][class*="none_"],
[class*="guilds_"] [class*="scroller"] {
    background-color: #${BG_CRUST} !important;
}

/* Layers and backdrops */
[class*="layer"][class*="base"],
[class*="backdrop"],
[class*="bg_"][class*="backdrop"] {
    background-color: #${BG_CRUST} !important;
}

/* Title bar and top sections */
[class*="title"][class*="container"],
[class*="header"][class*="bar"] {
    background-color: #${BG_BASE} !important;
}

/* Server header/title area (where server name is shown) */
[class*="container_"][class*="themed"],
[class*="header_"]:not([class*="message"]):not([class*="search"]),
[class*="animatedContainer"],
[class*="bannerImage"] {
    background-color: #${BG_MANTLE} !important;
}

/* Message input/text area */
[class*="channelTextArea"],
[class*="textArea"],
[class*="scrollableContainer"],
form[class*="form"] {
    background-color: #${SURFACE_0} !important;
}

/* Message headers in chat */
h3[class*="header_"],
[class*="message"] h3[class*="header_"] {
    background-color: transparent !important;
}

/* Input fields */
[class*="input"]:not([type="checkbox"]):not([type="radio"]),
[class*="inputDefault"],
[class*="inputWrapper"] {
    background-color: #${SURFACE_0} !important;
}

/* Scrollbars */
[class*="scrollbar"],
[class*="scroller"]::-webkit-scrollbar,
[class*="scroller"]::-webkit-scrollbar-track,
[class*="auto_"]::-webkit-scrollbar-track,
div::-webkit-scrollbar-track {
    background-color: #${BG_BASE} !important;
}

/* Top bar separators/dividers - aggressive targeting */
[class*="divider"],
[class*="separator"],
[class*="toolbar"] [class*="divider"],
[class*="children"] > [class*="divider"],
[class*="children"] [class*="divider"] {
    background-color: #${BG_MANTLE} !important;
    border-color: #${BG_MANTLE} !important;
    box-shadow: none !important;
}

/* All divider elements by tag */
div[class*="divider"],
span[class*="divider"] {
    background-color: #${BG_MANTLE} !important;
    border-color: #${BG_MANTLE} !important;
}

/* Top bar search/toolbar area */
[class*="searchBar"],
[class*="search"][class*="bar"],
[class*="toolbar"],
[class*="iconWrapper"] {
    background-color: transparent !important;
}

/* Lower left user panel/account info area - exact targeting */
[class*="panels_"],
div[class*="panels_"],
section[class*="panels_"],
[class*="container_"][class*="account"],
[class*="panels_"] > [class*="container"],
[class*="avatarWrapper"] + [class*="container"],
[class*="panel"] [class*="container"]:not([class*="chat"]):not([class*="content"]),
[class*="accountProfileCard"],
[class*="userPanel"],
[class*="container"][class*="withTag"] {
    background-color: #${BG_MANTLE} !important;
}

/* Sidebar ::after pseudo-element (bottom panel overlay) */
div[class*="sidebar_"]::after {
    background-color: #${BG_MANTLE} !important;
    background: #${BG_MANTLE} !important;
}

/* Navigation container in lower left */
nav[class*="container_"] {
    background-color: #${BG_MANTLE} !important;
}

/* Scroller in lower left area */
div[class*="scroller__"],
[class*="scroller__"][class*="thin_"],
[class*="scrollerBase_"] {
    background-color: #${BG_MANTLE} !important;
}

/* Top toolbar container */
[class*="toolbar__"],
div[class*="toolbar__"],
[class*="container__"][class*="toolbar"] {
    background-color: #${BG_BASE} !important;
}

/* Top bar children ::after pseudo-element (separator line) */
div[class*="children_"]::after {
    background-color: #${BG_MANTLE} !important;
    background: #${BG_MANTLE} !important;
}
EOF

echo "  ↳ Added targeted selectors for Discord areas"
