# Screenshot Widget

## Overview
Native Quickshell screenshot widget that automatically matches your theme colors and provides a clean, integrated screenshot experience.

## Features
- ✅ **Fully themed** - Automatically uses your active theme colors
- ✅ **Three capture modes**: Workspace, Window, Selection
- ✅ **Delay timer** - Set 0-10 second delays
- ✅ **Keyboard navigation** - ESC to close
- ✅ **Nerd Font icons** - Consistent icon rendering
- ✅ **Hover effects** - Visual feedback on interaction

## Keybinds

### Open Screenshot Widget
- **Super + Shift + S** - Opens the screenshot widget

### Quick Workspace Screenshot
- **Super + Print Screen** - Takes immediate workspace screenshot (bypasses widget)

## Screenshot Modes

### 󰍹 Workspace (Blue)
Captures the entire current monitor/workspace.

### 󰖲 Window (Green)
Captures a specific window (click to select after triggering).

### 󰆟 Selection (Purple)
Captures a region of the screen (click and drag to select).

## Options

### Delay
Use the **+** and **−** buttons to set a delay from 0-10 seconds before the screenshot is taken.

### Save Location
All screenshots are automatically saved to: `~/Pictures/Screenshots/`

Screenshots are also automatically copied to your clipboard for easy pasting!

## Files

- `~/.config/quickshell/ScreenshotWidget.qml` - Main widget component
- `~/.config/quickshell/toggle-screenshot` - Toggle script for keybind
- Socket file: `/tmp/quickshell-screenshot.sock` - IPC communication

## Integration

The screenshot widget is integrated into shell.qml with:
- Property: `screenshotVisible`
- Toggle function: `toggleScreenshot()`
- File watcher: `screenshotWatcher` (monitors socket file)

## Why This Instead of hyprshot-gui?

- **Better theming** - Uses Quickshell's ThemeManager, always matches your theme
- **Consistent look** - Matches your other Quickshell widgets perfectly
- **Lighter** - No GTK/Python overhead
- **Integrated** - Part of your Quickshell ecosystem
- **Customizable** - Easy to modify QML code

## Usage

1. Press **Super + Shift + S** to open the widget
2. Select capture mode (Workspace, Window, or Selection)
3. Optional: Adjust delay if needed
4. Click your chosen mode
5. Screenshot is saved and copied to clipboard!

Or use **Super + Print Screen** for instant workspace screenshots.

## Customization

The widget uses ThemeManager colors:
- Background: `ThemeManager.bgBase`
- Buttons: `ThemeManager.surface0` / `ThemeManager.surface1` (hover)
- Borders: `ThemeManager.border1` and `ThemeManager.accentBlue`
- Text: `ThemeManager.fgPrimary`, `fgSecondary`, `fgTertiary`
- Icon colors: `accentBlue`, `accentGreen`, `accentPurple`

Edit `ScreenshotWidget.qml` to customize layout, colors, or functionality!
