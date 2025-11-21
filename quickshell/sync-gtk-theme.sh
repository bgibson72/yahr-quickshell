#!/bin/bash

# Sync GTK Theme with Current Quickshell Theme
# Maps Quickshell themes to corresponding GTK themes

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"
GTK2_SETTINGS="$HOME/.gtkrc-2.0"

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found at $THEME_MANAGER"
    exit 1
fi

# Extract current theme name
theme_name=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Syncing GTK theme for: $theme_name"

# Map Quickshell themes to GTK themes
case "$theme_name" in
    "Everforest")
        gtk_theme="Everforest-Dark"
        icon_theme="Everforest-Dark"
        ;;
    "Catppuccin Mocha")
        gtk_theme="Catppuccin-Mocha-Standard-Blue-Dark"
        icon_theme="Catppuccin-Mocha"
        ;;
    "Gruvbox")
        gtk_theme="Gruvbox-Dark"
        icon_theme="Gruvbox-Dark"
        ;;
    "Nord")
        gtk_theme="Nordic"
        icon_theme="Nordic"
        ;;
    "Dracula")
        gtk_theme="Dracula"
        icon_theme="Dracula"
        ;;
    "Tokyo Night")
        gtk_theme="Tokyonight-Dark"
        icon_theme="Tokyonight-Dark"
        ;;
    "Nightfox Duskfox")
        gtk_theme="Nightfox-Dark-Duskfox"
        icon_theme="Nightfox - Duskfox"
        ;;
    "Rose Pine")
        gtk_theme="Rose-Pine"
        icon_theme="Rose-Pine-Moon"
        ;;
    "Solarized Dark")
        gtk_theme="Solarized-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "Material Palenight")
        gtk_theme="Material-Palenight"
        icon_theme="Material - DeepOcean"
        ;;
    "One Dark")
        gtk_theme="One-Dark"
        icon_theme="Papirus-Dark"
        ;;
    *)
        echo "⚠ No GTK theme mapping for: $theme_name"
        echo "  Using default: Adwaita-dark"
        gtk_theme="Adwaita-dark"
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

# Update gsettings (used by some GTK4 apps like pavucontrol)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
    echo "  gsettings updated"
fi

echo ""
echo "Note: Running GTK applications will need to be restarted to see changes"
