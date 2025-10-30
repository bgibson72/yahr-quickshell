#!/bin/bash

# Quick setup guide for fastfetch theme images

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║         Fastfetch Theme-Aware Image Setup Guide             ║
╚══════════════════════════════════════════════════════════════╝

📁 STEP 1: Add Your Images
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Organize your images in theme-specific directories:
  ~/.config/fastfetch/images/

Directory structure (each theme has its own folder):
  Catppuccin/Catppuccin.png
  Dracula/Dracula.png
  Eldritch/Eldritch.png
  Everforest/Everforest.png
  Gruvbox/Gruvbox.png
  Kanagawa/Kanagawa.png
  Material/Material.png
  NightFox/NightFox.png
  Nord/Nord.png
  RosePine/RosePine.png
  TokyoNight/TokyoNight.png

Example:
  mkdir -p ~/.config/fastfetch/images/Eldritch
  cp ~/Downloads/eldritch-wallpaper.png ~/.config/fastfetch/images/Eldritch/Eldritch.png

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 STEP 2: Check Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Check which images are present:
  ~/.config/fastfetch/check-images.sh

Test theme detection:
  ~/.config/fastfetch/get-theme-image.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 STEP 3: Run Fastfetch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Simply run:
  fastfetch

The image will automatically match your current theme!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  CUSTOMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Edit configuration:
  vim ~/.config/fastfetch/config.jsonc

Adjust image size, modules, colors, and more!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Each theme has its own directory for better organization
- Images should be named exactly like the theme (e.g., Eldritch.png)
- Supported formats: PNG, JPG, JPEG, GIF, WEBP
- Images auto-resize to fit terminal
- Falls back to any image in theme directory if exact name not found
- Falls back to ASCII art if theme directory doesn't exist
- Theme detection works with your Quickshell setup
- Use vibrant, colorful images for best results

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Theme: $(grep 'themeName:' ~/.config/quickshell/ThemeManager.qml 2>/dev/null | sed -E 's/.*"(.+)".*/\1/' || echo 'Unknown')

EOF
