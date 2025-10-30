# Quickshell Theme System

## Overview

Quickshell now uses a centralized theme system via `ThemeManager.qml` that synchronizes with your Hyprland themes located in `~/.config/hypr/themes/`.

## How It Works

The `ThemeManager` singleton provides color properties that all Quickshell components use. This ensures consistent theming across your status bar.

## Switching Themes

### Manual Method

1. Open `~/.config/quickshell/ThemeManager.qml`
2. Update the color values to match your desired theme
3. Save the file - Quickshell will hot-reload automatically!

### Theme Presets

Pre-configured theme files are available in `~/.config/quickshell/themes/`:

```bash
# Copy a theme preset to activate it
cp ~/.config/quickshell/themes/catppuccin-mocha.qml ~/.config/quickshell/ThemeManager.qml
cp ~/.config/quickshell/themes/tokyonight-night.qml ~/.config/quickshell/ThemeManager.qml
cp ~/.config/quickshell/themes/gruvbox-dark.qml ~/.config/quickshell/ThemeManager.qml
# etc.
```

## Available Themes

All themes match the colors in `~/.config/hypr/themes/`:

- **tokyonight-night** (default)
- **catppuccin-mocha**
- **everforest-dark**
- **gruvbox-dark**
- **kanagawa-dark**
- **material-deepocean**
- **nightfox-dusk**
- **rosepine-dark**

## Theme Properties

The ThemeManager provides these color properties:

### Accent Colors
- `accentBlue` - Primary accent (Arch button, network ethernet, updates)
- `accentPurple` - Secondary accent (Arch button hover)
- `accentRed` - Error/critical (power button, network disconnected, battery critical)
- `accentMaroon` - Error hover (power button hover)
- `accentYellow` - Warning (audio, battery warning)
- `accentGreen` - Success (network wifi, battery good)
- `accentOrange`, `accentPink`, `accentCyan`, `accentTeal` - Additional accents

### Text Colors
- `fgPrimary` - Primary text (clock, icons)
- `fgSecondary` - Secondary text (workspace numbers)
- `fgTertiary` - Tertiary text

### Background Colors
- `bgBase` - Base background (button backgrounds)
- `bgBaseAlpha` - Bar background with transparency
- `bgMantle`, `bgCrust` - Darker backgrounds

### Surface Colors
- `surface0` - Module backgrounds
- `surface1` - Module hover backgrounds
- `surface2` - Elevated surfaces

### Border Colors
- `border0`, `border1`, `border2` - Borders and separators

### Font Sizes
- `fontSizeClock` (14) - Clock text size
- `fontSizeWorkspace` (14) - Workspace numbers
- `fontSizeUpdates` (14) - Update counter
- `fontSizeIcon` (16) - Standard icons
- `fontSizeLargeIcon` (24) - Large icons (Arch button)

## Creating Custom Themes

1. Copy an existing theme preset:
   ```bash
   cp ~/.config/quickshell/themes/tokyonight-night.qml ~/.config/quickshell/themes/mytheme.qml
   ```

2. Edit the color values to match your theme

3. Reference colors from your Hyprland theme file:
   ```bash
   cat ~/.config/hypr/themes/yourtheme.conf
   ```

4. Activate your theme:
   ```bash
   cp ~/.config/quickshell/themes/mytheme.qml ~/.config/quickshell/ThemeManager.qml
   ```

## Visual Customization

### Arch Button
- Background: `accentBlue` (hover: `accentPurple`)
- Icon color: `bgBase` (creates button appearance)
- Icon size: `fontSizeLargeIcon`

### Power Button
- Background: `accentRed` (hover: `accentMaroon`)
- Icon color: `bgBase` (creates button appearance)
- Icon size: `fontSizeIcon`

### Clock
- Background: `surface0` (hover: `surface1`)
- Text color: `fgPrimary`
- Font size: `fontSizeClock`

### Workspaces
- Background: transparent (hover: `surface0`)
- Text color: `fgSecondary`
- Font size: `fontSizeWorkspace`

### Updates Counter
- Background: `surface0` (hover: `surface1`)
- Icon & text color: `accentBlue`
- Font sizes: `fontSizeIcon` (icon), `fontSizeUpdates` (number)

### Network
- Background: `surface0` (hover: `surface1`)
- Icon colors:
  - WiFi: `accentGreen`
  - Ethernet: `accentBlue`
  - Disconnected: `accentRed`

### Audio
- Background: `surface0` (hover: `surface1`)
- Icon colors:
  - Normal: `accentYellow`
  - Muted: `border0`

### Battery
- Background: `surface0` (hover: `surface1`)
- Icon colors:
  - Good (>30%): `accentGreen`
  - Warning (15-30%): `accentYellow`
  - Critical (<15%): `accentRed`

## Quick Theme Switcher Script

Create `~/.config/quickshell/switch-theme.sh`:

```bash
#!/bin/bash
THEME="$1"

if [ -z "$THEME" ]; then
    echo "Available themes:"
    ls ~/.config/quickshell/themes/*.qml | xargs -n1 basename | sed 's/.qml//'
    echo ""
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME_FILE="$HOME/.config/quickshell/themes/${THEME}.qml"

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $THEME"
    exit 1
fi

cp "$THEME_FILE" "$HOME/.config/quickshell/ThemeManager.qml"
echo "Theme switched to: $THEME"
echo "Quickshell will auto-reload!"
```

Make it executable:
```bash
chmod +x ~/.config/quickshell/switch-theme.sh
```

Use it:
```bash
~/.config/quickshell/switch-theme.sh catppuccin-mocha
~/.config/quickshell/switch-theme.sh tokyonight-night
```

## Integration with Hyprland Theme Switcher

To make Quickshell theme switch along with your Hyprland theme, modify your theme-switcher script to also copy the appropriate Quickshell theme:

```bash
# In your theme-switcher script, add:
cp "$HOME/.config/quickshell/themes/${THEME_NAME}.qml" "$HOME/.config/quickshell/ThemeManager.qml"
```

This ensures your status bar always matches your overall system theme!
