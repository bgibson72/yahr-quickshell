#!/bin/bash
# ============================================
# Vencord Theme Sync Script v2
# Syncs colors from Hyprland themes to Vencord
# Now with proper app background support!
# ============================================

QUICKSHELL_SETTINGS="$HOME/.config/quickshell/settings.json"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"
VENCORD_CSS="$HOME/.config/vesktop/settings/settings.json"

# Get the current theme from quickshell settings
CURRENT_THEME=$(jq -r '.theme.current' "$QUICKSHELL_SETTINGS" 2>/dev/null)

if [ -z "$CURRENT_THEME" ] || [ "$CURRENT_THEME" = "null" ]; then
    echo "Error: Could not read current theme from $QUICKSHELL_SETTINGS"
    exit 1
fi

THEME_FILE="$HYPR_THEMES_DIR/${CURRENT_THEME}.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

echo "Syncing theme: $CURRENT_THEME"
echo "Reading colors from: $THEME_FILE"

# Function to extract color value from theme file
get_color() {
    local var_name="$1"
    # Extract the color value (handles both rgb() and plain hex)
    grep "^\$$var_name = " "$THEME_FILE" | sed -E 's/.*rgb\(([a-fA-F0-9]+)\).*/\1/' | sed 's/\$//'
}

# Extract all colors
accent_blue=$(get_color "accent-blue")
accent_purple=$(get_color "accent-purple")
accent_pink=$(get_color "accent-pink")
accent_red=$(get_color "accent-red")
accent_orange=$(get_color "accent-orange")
accent_yellow=$(get_color "accent-yellow")
accent_green=$(get_color "accent-green")
accent_cyan=$(get_color "accent-cyan")

fg_primary=$(get_color "fg-primary")
fg_secondary=$(get_color "fg-secondary")
fg_tertiary=$(get_color "fg-tertiary")

border_0=$(get_color "border-0")
border_1=$(get_color "border-1")
border_2=$(get_color "border-2")

surface_0=$(get_color "surface-0")
surface_1=$(get_color "surface-1")
surface_2=$(get_color "surface-2")

bg_base=$(get_color "bg-base")
bg_mantle=$(get_color "bg-mantle")
bg_crust=$(get_color "bg-crust")

# Generate CSS with the theme colors
CSS_CONTENT="/**
 * Theme: $CURRENT_THEME (Auto-synced from Quickshell)
 * Generated: $(date)
 */

:root {
    /* ===== APP BACKGROUND (Main fix for black background) ===== */
    --app-background: #${bg_crust};
    --bg-backdrop: #${bg_crust};
    --bg-base-primary: #${bg_base};
    --bg-base-secondary: #${bg_mantle};
    --bg-base-tertiary: #${bg_crust};
    
    /* Background Colors */
    --bg-overlay-1: #${bg_crust};
    --bg-overlay-2: #${bg_mantle};
    --bg-overlay-3: #${bg_base};
    --bg-overlay-app-frame: #${bg_crust};
    
    /* Surface Colors */
    --background-primary: #${bg_base};
    --background-secondary: #${bg_mantle};
    --background-secondary-alt: #${bg_crust};
    --background-tertiary: #${surface_0};
    --background-accent: #${surface_1};
    --background-floating: #${surface_0};
    --background-mobile-primary: #${bg_base};
    --background-mobile-secondary: #${bg_mantle};
    --background-modifier-hover: #${surface_0}80;
    --background-modifier-active: #${surface_1}80;
    --background-modifier-selected: #${surface_2}80;
    --background-modifier-accent: #${accent_blue}40;
    
    /* Text Colors */
    --text-normal: #${fg_primary};
    --text-muted: #${fg_secondary};
    --text-faint: #${fg_tertiary};
    --text-link: #${accent_blue};
    --text-positive: #${accent_green};
    --text-warning: #${accent_yellow};
    --text-danger: #${accent_red};
    --text-brand: #${accent_blue};
    
    /* Interactive Colors */
    --interactive-normal: #${fg_secondary};
    --interactive-hover: #${fg_primary};
    --interactive-active: #${accent_blue};
    --interactive-muted: #${fg_tertiary};
    
    /* Accent Colors */
    --brand-experiment: #${accent_blue};
    --brand-experiment-hover: #${accent_purple};
    --brand-experiment-560: #${accent_blue};
    
    /* Channel/User Status */
    --status-positive: #${accent_green};
    --status-warning: #${accent_yellow};
    --status-danger: #${accent_red};
    
    /* Border Colors */
    --border-subtle: #${border_0};
    --border-strong: #${border_1};
    --border-faint: #${border_0}40;
    
    /* Scrollbar */
    --scrollbar-thin-thumb: #${surface_1};
    --scrollbar-thin-track: transparent;
    --scrollbar-auto-thumb: #${surface_2};
    --scrollbar-auto-track: #${surface_0};
    
    /* Deprecated but still used */
    --deprecated-card-bg: #${surface_0};
    --deprecated-card-editable-bg: #${surface_1};
    --deprecated-store-bg: #${bg_base};
    --deprecated-quickswitcher-input-background: #${surface_0};
    --deprecated-text-input-bg: #${surface_0};
    --deprecated-text-input-border: #${border_0};
    --deprecated-text-input-border-hover: #${border_1};
    --deprecated-text-input-border-disabled: #${border_0}40;
}

/* ===== FORCE APP BACKGROUND (Critical for removing black) ===== */
body,
html,
#app-mount,
.app_bd26cc,
.bg_b02b02,
.wrapper_a7e7a8 {
    background-color: #${bg_crust} !important;
}

/* Additional custom styling */
.theme-dark {
    --background-primary: #${bg_base};
    --background-secondary: #${bg_mantle};
    --background-tertiary: #${surface_0};
}

/* Message bar */
.channelTextArea_a7d72e {
    background-color: #${surface_0};
}

/* User panel */
.container_ca50b9 {
    background-color: #${bg_crust};
}

/* Sidebar */
.sidebar_e031f6 {
    background-color: #${bg_mantle};
}

/* Server list */
.wrapper__8436d {
    background-color: #${bg_crust};
}

/* Chat background */
.chatContent__5dca8,
.chat__52833 {
    background-color: #${bg_base};
}

/* Accent for selected items */
.selected_fd9051,
.selected_ae80f7 {
    background-color: #${surface_2} !important;
    color: #${accent_blue} !important;
}

/* Links */
a {
    color: #${accent_blue};
}

a:hover {
    color: #${accent_purple};
}
"

# Handle command-line arguments
case "${1:-}" in
    --theme-file)
        # Update the theme file
        THEME_OUTPUT="$HOME/.config/vesktop/themes/QuickshellSync.theme.css"
        mkdir -p "$(dirname "$THEME_OUTPUT")"
        
        # Add theme header
        THEME_CSS="/**
 * @name Quickshell Sync ($CURRENT_THEME)
 * @author Auto-generated
 * @description Synced from ~/.config/hypr/themes/${CURRENT_THEME}.conf
 * @version 1.0
 */

$CSS_CONTENT"
        
        echo "$THEME_CSS" > "$THEME_OUTPUT"
        echo "✓ Theme file updated: $THEME_OUTPUT"
        echo "  Enable it in Vesktop: Settings > Vencord > Themes"
        
        # Add comprehensive catch-all selectors
        if [ -f "$HOME/.config/quickshell/vencord-add-catchall.sh" ]; then
            "$HOME/.config/quickshell/vencord-add-catchall.sh"
        fi
        ;;
        
    --quickcss)
        # Update QuickCSS in Vencord settings
        SETTINGS_FILE="$HOME/.config/vesktop/settings/settings.json"
        
        if [ ! -f "$SETTINGS_FILE" ]; then
            echo "Error: Vencord settings not found at $SETTINGS_FILE"
            echo "Please open Vesktop at least once to create the settings file"
            exit 1
        fi
        
        # Escape CSS for JSON
        CSS_ESCAPED=$(echo "$CSS_CONTENT" | jq -Rs .)
        
        # Update or add quickCss field
        jq ".vencord.quickCss = $CSS_ESCAPED" "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && \
            mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        
        echo "✓ QuickCSS updated in Vencord settings"
        echo "  Restart Vesktop to see changes"
        ;;
        
    --output)
        # Just output to stdout for manual copying
        echo "$CSS_CONTENT"
        ;;
        
    *)
        # Display the generated CSS and instructions
        echo ""
        echo "Generated CSS for theme: $CURRENT_THEME"
        echo "============================================"
        echo "$CSS_CONTENT"
        echo "============================================"
        echo ""
        echo "How to apply this theme:"
        echo ""
        echo "Option 1 - QuickCSS (Instant):"
        echo "  1. Open Vesktop"
        echo "  2. Settings > Vencord > Vencord (tab)"
        echo "  3. Click 'Edit QuickCSS'"
        echo "  4. Paste the CSS above"
        echo "  Or run: $0 --quickcss"
        echo ""
        echo "Option 2 - Theme File (Reusable):"
        echo "  Run: $0 --theme-file"
        echo "  Then enable in: Settings > Vencord > Themes"
        echo ""
        ;;
esac
