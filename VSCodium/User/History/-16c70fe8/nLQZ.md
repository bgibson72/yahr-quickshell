# Fastfetch Theme-Aware Configuration

This fastfetch configuration dynamically changes the displayed image based on your current Quickshell/Hyprland theme.

## Setup

### 1. Add Your Theme Images

Organize your theme-specific images in separate directories under `~/.config/fastfetch/images/`:

```
~/.config/fastfetch/images/
├── Catppuccin/
│   └── Catppuccin.png
├── Dracula/
│   └── Dracula.png
├── Eldritch/
│   └── Eldritch.png
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
├── TokyoNight/
│   └── TokyoNight.png
└── default.png  (optional fallback)
```

**Structure:** Each theme has its own directory, and the image inside is named after the theme.

**Supported formats:** PNG, JPG, JPEG, GIF, WEBP

### 2. How It Works

The configuration:
- Reads the current theme from `~/.config/quickshell/ThemeManager.qml`
- Looks for the theme directory in `~/.config/fastfetch/images/[ThemeName]/`
- Finds and displays the image named `[ThemeName].png` (or jpg, jpeg, gif, webp)
- If no matching image exists, falls back to any image in the theme directory
- Displays minimal system information alongside the image
- Shows the current theme name in the output

### 3. Modules Displayed

- **User@Host** (title)
- **OS** - Operating system
- **Kernel** - Kernel version
- **Packages** - Number of installed packages
- **Shell** - Current shell
- **WM** - Window manager (Hyprland)
- **Terminal** - Terminal emulator
- **Uptime** - System uptime
- **Theme** - Current active theme
- **Color palette** - Terminal colors

### 4. Customization

Edit `~/.config/fastfetch/config.jsonc` to:
- Add/remove modules
- Change colors
- Adjust image size
- Modify separators and formatting

### 5. Testing

Run fastfetch to test:
```bash
fastfetch
```

Test the theme detection:
```bash
~/.config/fastfetch/get-theme-image.sh
```

### 6. Theme List

Based on your current setup, create images for these themes:
- Catppuccin
- Dracula
- Eldritch
- Everforest
- Gruvbox
- Kanagawa
- Material
- NightFox
- Nord
- RosePine
- TokyoNight

## Tips

- Images will be automatically resized to fit (default: 30x15 characters)
- Use high-quality images for best results
- Keep images colorful and vibrant
- Consider using theme-specific artwork or logos
- The script falls back to ASCII art if no image is found
