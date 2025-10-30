#!/bin/bash
# Update sync-vencord-theme.sh with comprehensive background handling

SYNC_SCRIPT="$HOME/.config/quickshell/sync-vencord-theme.sh"
BACKUP="$HOME/.config/quickshell/sync-vencord-theme-manual-backup.sh"

# Create backup
cp "$SYNC_SCRIPT" "$BACKUP"
echo "✓ Backup created: $BACKUP"

# Extract everything before the background section
sed -n '1,144p' "$SYNC_SCRIPT" > "${SYNC_SCRIPT}.new"

# Add the comprehensive background CSS
cat >> "${SYNC_SCRIPT}.new" << 'COMPREHENSIVE_CSS'

/* ===== COMPREHENSIVE BACKGROUND OVERRIDE ===== */
/* This uses Discord's CSS variables to theme everything at once */

/* Override Discord's theme variables with !important */
.theme-dark,
.theme-light {
    --background-primary: #${bg_base} !important;
    --background-secondary: #${bg_mantle} !important;
    --background-secondary-alt: #${bg_crust} !important;
    --background-tertiary: #${surface_0} !important;
    --background-accent: #${surface_1} !important;
    --background-floating: #${surface_0} !important;
    --background-mobile-primary: #${bg_base} !important;
    --background-mobile-secondary: #${bg_mantle} !important;
    
    /* Nested/custom background variables */
    --bg-backdrop: #${bg_crust} !important;
    --bg-base-primary: #${bg_base} !important;
    --bg-base-secondary: #${bg_mantle} !important;
    --bg-base-tertiary: #${bg_crust} !important;
    
    --bg-overlay-1: #${bg_crust} !important;
    --bg-overlay-2: #${bg_mantle} !important;
    --bg-overlay-3: #${bg_base} !important;
    --bg-overlay-app-frame: #${bg_crust} !important;
}

/* Force base app backgrounds */
body,
html,
#app-mount {
    background-color: #${bg_crust} !important;
}

/* Target common Discord wrapper classes */
.app_bd26cc,
.bg_b02b02,
.wrapper_a7e7a8,
.layers_a23c37,
.layer_cd0de5,
.base_a4d4d9 {
    background-color: #${bg_crust} !important;
}

/* Catch-all selectors for stubborn black backgrounds */
/* This targets any class starting with "bg_" or "background" */
[class*="bg_"][class*="_"]:not([class*="image"]):not([class*="avatar"]):not([class*="icon"]) {
    background-color: var(--background-secondary-alt, #${bg_crust}) !important;
}

/* Override inline styles (last resort) */
div[style*="background-color: rgb(0, 0, 0)"],
div[style*="background-color: black"],
div[style*="background: rgb(0, 0, 0)"],
div[style*="background: black"],
div[style*="background-color:#000000"],
div[style*="background-color:#000"] {
    background-color: #${bg_crust} !important;
}

/* Specific element styling */
.channelTextArea_a7d72e {
    background-color: #${surface_0};
}

.container_ca50b9 {
    background-color: #${bg_crust};
}

.sidebar_e031f6 {
    background-color: #${bg_mantle};
}

.wrapper__8436d {
    background-color: #${bg_crust};
}

.chatContent__5dca8,
.chat__52833 {
    background-color: #${bg_base};
}

.selected_fd9051,
.selected_ae80f7 {
    background-color: #${surface_2} !important;
    color: #${accent_blue} !important;
}

a {
    color: #${accent_blue};
}

a:hover {
    color: #${accent_purple};
}
COMPREHENSIVE_CSS

# Add everything after the old CSS section (from line 205 onwards)
tail -n +205 "$SYNC_SCRIPT" >> "${SYNC_SCRIPT}.new"

# Replace the original
mv "${SYNC_SCRIPT}.new" "$SYNC_SCRIPT"
chmod +x "$SYNC_SCRIPT"

echo "✓ Updated sync-vencord-theme.sh with comprehensive background handling"
echo ""
echo "The new approach:"
echo "  1. Overrides Discord's CSS variables (catches most elements)"
echo "  2. Targets common wrapper classes"
echo "  3. Uses catch-all selectors for [class*='bg_']"
echo "  4. Overrides inline styles as last resort"
echo ""
echo "Regenerate your theme:"
echo "  ~/.config/quickshell/sync-vencord-theme.sh --theme-file"
echo "  Then reload Vesktop (Ctrl+R)"
