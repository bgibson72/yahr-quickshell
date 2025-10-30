# VSCodium Theme Sync

## Overview
Automatic theme synchronization for VSCodium that reads colors from your Hyprland theme files and applies them to VSCodium's color customizations.

## Files Created

### 1. `~/.config/quickshell/sync-vscodium-theme.sh`
Main script that:
- Reads the current Hyprland theme from `hyprland.conf`
- Parses theme colors from the theme file
- Converts colors to VSCodium's format
- Updates `~/.config/VSCodium/User/settings.json` with matching colors
- Backs up existing settings before making changes

## How It Works

1. **Reads Current Theme**: Detects which theme is active by checking the `source` line in `hyprland.conf`

2. **Parses Theme Colors**: Extracts RGB color values from the theme file:
   - Background colors (`bg-base`, `bg-mantle`, `bg-crust`)
   - Surface colors (`surface-0`, `surface-1`, `surface-2`)
   - Text colors (`fg-primary`, `fg-secondary`, `fg-tertiary`)
   - Border colors (`border-0`, `border-1`, `border-2`)
   - Accent colors (blue, green, yellow, red, purple, cyan, orange)

3. **Applies to VSCodium**: Updates the `workbench.colorCustomizations` section with:
   - Editor colors (background, foreground, cursor, selection)
   - Sidebar colors
   - Activity bar colors
   - Title bar colors
   - Status bar colors
   - Tab colors
   - Panel and terminal colors
   - List and tree colors
   - Input and button colors
   - Git decoration colors
   - And more...

## Usage

### Manual Sync
Run the script directly:
```bash
~/.config/quickshell/sync-vscodium-theme.sh
```

### Automatic Sync
The script is automatically called when you switch themes using:
```bash
~/.config/quickshell/theme-switcher-quickshell --wofi
```

Or when you use the theme switcher button in your Quickshell status bar.

## What Gets Synced

- **Editor**: Background, foreground, line numbers, cursor, selections
- **Sidebar**: Background, foreground, borders, section headers
- **Activity Bar**: Background, foreground, active/inactive states
- **Title Bar**: Active/inactive backgrounds and foregrounds
- **Status Bar**: Background, foreground, debugging states
- **Tabs**: Active/inactive backgrounds, borders
- **Terminal**: All 16 ANSI colors mapped to your theme
- **Git**: Modified, deleted, untracked, ignored, conflicting states
- **And much more...**

## After Syncing

**You need to restart VSCodium** to see the changes. The script will remind you:
```
Restart VSCodium to see the changes!
```

## Backup

The script automatically backs up your settings before making changes:
- Location: `~/.config/VSCodium/User/settings.json.backup`

If something goes wrong, you can restore it:
```bash
cp ~/.config/VSCodium/User/settings.json.backup ~/.config/VSCodium/User/settings.json
```

## Integration

This script is integrated into your theme-switching workflow:

1. Select a theme from Quickshell theme switcher
2. Theme applies to:
   - Quickshell
   - Hyprland
   - Wofi
   - Kitty
   - Mako
   - Hyprlock
   - GTK theme
   - Wallpaper
   - **VSCodium** ← NEW!

## Example

```bash
# Current theme: TokyoNight
~/.config/quickshell/sync-vscodium-theme.sh

# Output:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   VSCodium Theme Sync
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Current theme: TokyoNight
#
# ✓ Backed up existing settings
# ✓ VSCodium colors synchronized with TokyoNight theme
#
# Restart VSCodium to see the changes!
```

## Supported Themes

Works with all your Hyprland themes:
- TokyoNight
- Catppuccin
- Gruvbox
- Material
- Everforest
- Kanagawa
- NightFox
- RosePine
- Dracula
- Nord
- Eldritch

## Notes

- VSCodium uses custom color customizations, not GTK themes (since it's an Electron app)
- The script preserves all other settings in your `settings.json`
- Colors are applied via the `workbench.colorCustomizations` section
- Terminal colors are mapped to ANSI color codes for consistency with your terminal theme
