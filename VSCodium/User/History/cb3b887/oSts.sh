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

echo "Expected theme images:"
echo ""

for theme in "${THEMES[@]}"; do
    theme_lower=$(echo "$theme" | tr '[:upper:]' '[:lower:]')
    found=false
    
    for ext in png jpg jpeg gif webp; do
        if [ -f "$IMAGE_DIR/${theme_lower}.${ext}" ]; then
            echo "✓ $theme → ${theme_lower}.${ext}"
            found=true
            break
        fi
    done
    
    if [ "$found" = false ]; then
        echo "✗ $theme → ${theme_lower}.{png,jpg,jpeg,gif,webp} (missing)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current theme: $(grep 'themeName:' ~/.config/quickshell/ThemeManager.qml 2>/dev/null | sed -E 's/.*"(.+)".*/\1/' || echo 'Unknown')"
echo "Image directory: $IMAGE_DIR"
echo ""
echo "To add images: cp /path/to/image.png $IMAGE_DIR/themename.png"
echo ""
