#!/bin/bash

# Helper script to list expected theme image filenames

IMAGE_DIR="$HOME/.config/fastfetch/images"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Fastfetch Theme Images Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List of themes from hypr/themes
THEMES=(
    "Catppuccin"
    "Dracula"
    "Eldritch"
    "Everforest"
    "Gruvbox"
    "Kanagawa"
    "Material"
    "NightFox"
    "Nord"
    "RosePine"
    "TokyoNight"
)

echo "Expected theme directories and images:"
echo ""

for theme in "${THEMES[@]}"; do
    theme_dir="$IMAGE_DIR/$theme"
    found=false
    found_file=""
    
    if [ -d "$theme_dir" ]; then
        # Check for theme-named image in directory
        for ext in png jpg jpeg gif webp; do
            if [ -f "$theme_dir/${theme}.${ext}" ]; then
                echo "✓ $theme/ → $theme.${ext}"
                found=true
                found_file="${theme}.${ext}"
                break
            fi
        done
        
        # If no theme-named image, check for any image
        if [ "$found" = false ]; then
            any_image=$(find "$theme_dir" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null | head -n 1)
            if [ -n "$any_image" ]; then
                echo "⚠ $theme/ → $(basename "$any_image") (directory exists, but should be named ${theme}.png)"
                found=true
            else
                echo "⚠ $theme/ → (directory exists, but no images found)"
            fi
        fi
    fi
    
    if [ "$found" = false ]; then
        echo "✗ $theme/ → (directory missing)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current theme: $(grep 'themeName:' ~/.config/quickshell/ThemeManager.qml 2>/dev/null | sed -E 's/.*"(.+)".*/\1/' || echo 'Unknown')"
echo "Image directory: $IMAGE_DIR"
echo ""
echo "Structure: $IMAGE_DIR/ThemeName/ThemeName.png"
echo "Example:   mkdir -p $IMAGE_DIR/Eldritch && cp /path/to/image.png $IMAGE_DIR/Eldritch/Eldritch.png"
echo ""
