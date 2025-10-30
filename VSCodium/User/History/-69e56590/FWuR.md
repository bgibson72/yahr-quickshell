# Fastfetch Theme Integration

## Setup Complete! ✅

Your fastfetch is now integrated with your Quickshell theme switcher.

## How It Works

### 1. Logo Location
- Logos are stored in: `~/.config/fastfetch/logos/`
- Naming convention: `themename_arch.png` (e.g., `gruvbox_arch.png`)
- Current symlink: `~/.config/fastfetch/current-theme-logo.png`

### 2. Automatic Theme Detection
- `get-theme-image.sh` reads your current theme from Quickshell's `ThemeManager.qml`
- Converts theme name to lowercase and finds matching logo
- Returns path to `themename_arch.png`

### 3. Theme Switching Integration

#### When Kitty Opens:
Your `.zshrc` now includes:
```bash
if [ "$TERM" = "xterm-kitty" ]; then
    ~/.config/fastfetch/update-theme-logo.sh > /dev/null 2>&1
    ff
fi
```
This automatically:
- Updates the logo symlink to match current theme
- Runs fastfetch with the correct logo

#### When You Change Themes:
Add this to your Quickshell theme switcher script:
```bash
~/.config/fastfetch/theme-switcher-hook.sh
```

Or manually run:
```bash
~/.config/fastfetch/update-theme-logo.sh
```

### 4. Available Themes
All logos are ready:
- catppuccin_arch.png ✅
- dracula_arch.png ✅
- eldritch_arch.png ✅
- everforest_arch.png ✅
- gruvbox_arch.png ✅
- kanagawa_arch.png ✅
- material_arch.png ✅
- nightfox_arch.png ✅
- nord_arch.png ✅
- rosepine_arch.png ✅
- tokyonight_arch.png ✅

## Manual Commands

### Update logo for current theme:
```bash
~/.config/fastfetch/update-theme-logo.sh
```

### Run fastfetch:
```bash
ff
```

### Check which logo is currently active:
```bash
ls -l ~/.config/fastfetch/current-theme-logo.png
```

## Quickshell Integration

To make the logo update automatically when you switch themes in Quickshell, add this line to your theme switching function/script:

```bash
~/.config/fastfetch/theme-switcher-hook.sh
```

Or just the update command:
```bash
~/.config/fastfetch/update-theme-logo.sh
```

## Kitty Config Additions

Added to `~/.config/kitty/kitty.conf`:
- Shell integration enabled
- Keybinding: `Ctrl+Shift+F` to run fastfetch overlay
- Auto-run on terminal start (via .zshrc)

## Files Overview

**Active Scripts:**
- `get-theme-image.sh` - Detects current theme and returns logo path
- `update-theme-logo.sh` - Updates symlink to current theme's logo
- `run-fastfetch-kitty.sh` - Runs fastfetch with Kitty graphics protocol
- `theme-switcher-hook.sh` - Hook for Quickshell theme switcher

**Config:**
- `config.jsonc` - Fastfetch configuration
- `current-theme-logo.png` - Symlink to active theme logo

**Logos:**
- `logos/` directory with all theme logos

## Testing

Test the integration:
```bash
# Check current theme
grep 'themeName:' ~/.config/quickshell/ThemeManager.qml

# Get logo path for current theme
~/.config/fastfetch/get-theme-image.sh

# Update symlink
~/.config/fastfetch/update-theme-logo.sh

# Run fastfetch
ff
```
