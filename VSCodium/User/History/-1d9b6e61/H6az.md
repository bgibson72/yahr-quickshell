# Theme Images Directory

This directory contains theme-specific images for fastfetch.

## Directory Structure

Each theme has its own subdirectory with an image named after the theme:

```
images/
├── Catppuccin/
│   └── Catppuccin.png
├── Dracula/
│   └── Dracula.png
├── Eldritch/
│   └── Eldritch.png      ✓ (configured)
├── Everforest/
│   └── Everforest.png
├── Gruvbox/
│   └── Gruvbox.png
├── Kanagawa/
│   └── Kanagawa.png
├── Material/
│   └── Material.png
├── NightFox/
│   └── NightFox.png
├── Nord/
│   └── Nord.png
├── RosePine/
│   └── RosePine.png
└── TokyoNight/
    └── TokyoNight.png
```

## Adding Images

To add an image for a theme:

```bash
# Copy your image to the appropriate theme directory
cp /path/to/your-image.png ~/.config/fastfetch/images/Catppuccin/Catppuccin.png
```

## Supported Formats

- PNG (recommended)
- JPG/JPEG
- GIF
- WEBP

## Image Naming

Images should be named exactly like the theme directory (case-sensitive):
- Theme directory: `Eldritch/`
- Image file: `Eldritch.png`

The script will fall back to any image in the directory if the exact name isn't found.

## Tips

- Use high-quality, vibrant images for best results
- Images will be automatically resized to fit your terminal
- Consider using theme-specific artwork or wallpapers
- Keep images colorful to match your theme's aesthetic
