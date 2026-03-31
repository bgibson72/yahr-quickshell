#!/bin/bash

# Sync GTK Theme with Current Quickshell Theme
# Maps Quickshell themes to corresponding GTK themes

CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"
GTK2_SETTINGS="$HOME/.gtkrc-2.0"
GTK_ENV_FILE="$HOME/.config/gtk-3.0/gtk-theme-env.sh"

# Check if current theme file exists
if [[ ! -f "$CURRENT_THEME_FILE" ]]; then
    echo "Error: Current theme file not found at $CURRENT_THEME_FILE"
    exit 1
fi

# Extract current theme name
theme_name=$(cat "$CURRENT_THEME_FILE" | tr -d '[:space:]')

echo "Syncing GTK theme for: $theme_name"

# Map Quickshell themes to GTK themes
# Supports both kebab-case (catppuccin-mocha) and Title Case (Catppuccin Mocha)
case "$theme_name" in
    "everforest"|"Everforest")
        gtk_theme="Everforest-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "catppuccin-mocha"|"Catppuccin Mocha")
        gtk_theme="Catppuccin-Mocha-Standard-Blue-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "gruvbox-dark"|"Gruvbox")
        gtk_theme="Gruvbox-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "nord"|"Nord")
        gtk_theme="Nordic"
        icon_theme="Papirus-Dark"
        ;;
    "dracula"|"Dracula")
        gtk_theme="Dracula"
        icon_theme="Papirus-Dark"
        ;;
    "tokyonight-night"|"Tokyo Night")
        gtk_theme="Tokyonight-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "nightfox"|"Nightfox Duskfox")
        gtk_theme="Nightfox-Dark-Duskfox"
        icon_theme="Papirus-Dark"
        ;;
    "rosepine"|"Rose Pine")
        gtk_theme="Rose-Pine"
        icon_theme="Papirus-Dark"
        ;;
    "solarized-dark"|"Solarized Dark"|"Solarized")
        gtk_theme="Osaka-BL-LB-Dark-Solarized"
        icon_theme="Papirus-Dark"
        ;;
    "material"|"Material"|"Material Palenight")
        gtk_theme="Material-Dark-Palenight"
        icon_theme="Papirus-Dark"
        ;;
    "onedark"|"One Dark")
        gtk_theme="One-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "kanagawa"|"Kanagawa")
        gtk_theme="Kanagawa"
        icon_theme="Papirus-Dark"
        ;;
    "eldritch"|"Eldritch")
        gtk_theme="Eldritch"
        icon_theme="Papirus-Dark"
        ;;
    "monochrome"|"Monochrome")
        gtk_theme="Graphite-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "solarized"|"Solarized"|"Solarized Dark")
        gtk_theme="Osaka-BL-LB-Dark-Solarized"
        icon_theme="Papirus-Dark"
        ;;
    *)
        echo "⚠ No GTK theme mapping for: $theme_name"
        echo "  Using default with Papirus-Dark icons"
        gtk_theme="Catppuccin-Dark"
        icon_theme="Papirus-Dark"
        ;;
esac

# Check if GTK theme exists
if [[ ! -d "$HOME/.themes/$gtk_theme" ]] && [[ ! -d "/usr/share/themes/$gtk_theme" ]]; then
    echo "⚠ GTK theme not found: $gtk_theme"
    echo "  Install it or edit the theme mapping in this script"
    exit 1
fi

# Update GTK3 settings
mkdir -p "$(dirname "$GTK3_SETTINGS")"
cat > "$GTK3_SETTINGS" << EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-font-name=Maple Mono NF 10
gtk-cursor-theme-name=default
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=1
EOF

# Update GTK4 settings
mkdir -p "$(dirname "$GTK4_SETTINGS")"
cat > "$GTK4_SETTINGS" << EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-application-prefer-dark-theme=1
EOF

# Update GTK2 settings
cat > "$GTK2_SETTINGS" << EOF
gtk-theme-name="$gtk_theme"
gtk-icon-theme-name="$icon_theme"
gtk-font-name="Maple Mono NF 10"
gtk-cursor-theme-name="default"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

echo "✓ GTK theme updated"
echo "  GTK Theme: $gtk_theme"
echo "  Icon Theme: $icon_theme"

# Create environment file for GTK apps
cat > "$GTK_ENV_FILE" << EOF
export GTK_THEME="$gtk_theme"
EOF

# Update gsettings (used by some GTK4 apps like pavucontrol)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
    echo "  gsettings updated"
fi

# Force reload GTK theme cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t ~/.icons/"$icon_theme" 2>/dev/null || true
fi

# Restart GTK file managers to apply theme immediately
pkill -HUP thunar 2>/dev/null || true
pkill -HUP pcmanfm 2>/dev/null || true

echo ""
echo "Note: Running GTK applications will need to be restarted to see changes"
