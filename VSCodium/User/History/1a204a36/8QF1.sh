#!/bin/bash

# Quick setup guide for fastfetch theme images

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║         Fastfetch Theme-Aware Image Setup Guide             ║
╚══════════════════════════════════════════════════════════════╝

📁 STEP 1: Add Your Images
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Place your theme images in:
  ~/.config/fastfetch/images/

Required naming (case-insensitive):
  catppuccin.png
  dracula.png
  eldritch.png
  everforest.png
  gruvbox.png
  kanagawa.png
  material.png
  nightfox.png
  nord.png
  rosepine.png
  tokyonight.png

Example:
  cp ~/Downloads/eldritch-wallpaper.png ~/.config/fastfetch/images/eldritch.png

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

- Supported formats: PNG, JPG, JPEG, GIF, WEBP
- Images auto-resize to fit terminal
- Falls back to ASCII art if image not found
- Theme detection works with your Quickshell setup
- Use vibrant, colorful images for best results

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Theme: $(grep 'themeName:' ~/.config/quickshell/ThemeManager.qml 2>/dev/null | sed -E 's/.*"(.+)".*/\1/' || echo 'Unknown')

EOF
