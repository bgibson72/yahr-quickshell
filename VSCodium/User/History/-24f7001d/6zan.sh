#!/bin/bash
# Post-processor to add catch-all selectors to generated Vencord theme
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

if [ -z "$BG_CRUST" ]; then
    # Fallback to hardcoded
    BG_CRUST="1e2326"
fi

# Add catch-all selectors to the end of the file
cat >> "$THEME_FILE" << EOF

/* ========================================= */
/* COMPREHENSIVE CATCH-ALL FOR BLACK BACKGROUNDS */
/* Auto-added by vencord-add-catchall.sh */
/* ========================================= */

/* Target any class containing "bg_" (excludes images/avatars) */
[class*="bg_"]:not([class*="image"]):not([class*="avatar"]):not([class*="icon"]):not([class*="emoji"]):not([class*="banner"]) {
    background-color: #${BG_CRUST} !important;
}

/* Common Discord container/layer classes */
[class*="layer"]:not([class*="image"]),
[class*="layers"]:not([class*="image"]),
[class*="base_"]:not([class*="image"]),
[class*="content_"]:not([class*="image"]),
[class*="wrapper_"]:not([class*="avatar"]),
[class*="container_"]:not([class*="avatar"]):not([class*="image"]) {
    background-color: var(--background-secondary-alt, #${BG_CRUST}) !important;
}

/* Override literal black inline styles */
*[style*="background: black"],
*[style*="background-color: black"],
*[style*="background: #000000"],
*[style*="background-color: #000000"],
*[style*="background: #000"],
*[style*="background-color: #000"] {
    background-color: #${BG_CRUST} !important;
}
EOF

echo "  ↳ Added comprehensive catch-all selectors"
