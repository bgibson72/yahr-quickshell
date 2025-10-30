# Screenshot Widget (Updated)

A native Quickshell screenshot interface that replaces hyprshot-gui with full theme integration and overlay functionality.

## Features

- **Three Capture Modes**:
  - **Workspace** (󰍹): Captures the entire current workspace/monitor
  - **Window** (󰖲): Click to select a window to capture
  - **Selection** (󰆟): Click and drag to select a region

- **Delay Timer**: Set a delay from 0-10 seconds before the screenshot is taken

- **Editable Save Location**: Text field to customize where screenshots are saved (default: `/home/bryan/Pictures/Screenshots`)

- **Automatic Theme Colors**: Uses `ThemeManager` singleton for colors that match your current Hyprland theme

- **Overlay Window**: Uses `WlrLayer.Overlay` so it appears on top of all windows without pushing them around

## Usage

### Keybinds
- **Super + Shift + S**: Toggle screenshot widget
- **Super + Print**: Quick workspace screenshot (bypasses widget)
- **ESC**: Close the widget

### Bar Button
- Click the screenshot icon (󰹑) in the quick access drawer

## Implementation Details

### Screenshot Commands
The widget uses `hyprshot` with proper mode arguments:
- **Workspace**: `hyprshot -m output -o <save_location>`
- **Window**: `hyprshot -m window -o <save_location>`
- **Selection**: `hyprshot -m region -o <save_location>`

### Delay Functionality
When delay is set (> 0 seconds):
```bash
sleep <delay_seconds> && hyprshot -m <mode> -o <save_location>
```

### Widget Properties
- **Size**: 450x320px
- **Layer**: `WlrLayer.Overlay` (appears above all windows)
- **ExclusiveZone**: 0 (doesn't reserve screen space)
- **Position**: Centered on screen using margins calculation

### Theme Integration
All UI colors are dynamically sourced from `ThemeManager`:
- `ThemeManager.bgBase` - Background
- `ThemeManager.accentBlue/Green/Purple` - Button accents
- `ThemeManager.surface0/surface1` - UI elements
- `ThemeManager.border1` - Borders
- `ThemeManager.fgPrimary/Secondary/Tertiary` - Text colors

## Files
- Widget: `~/.config/quickshell/ScreenshotWidget.qml`
- Toggle script: `~/.config/quickshell/toggle-screenshot`
- Bar button: `~/.config/quickshell/ScreenshotButton.qml`
- Config: Integrated in `~/.config/quickshell/shell.qml`
- IPC socket: `/tmp/quickshell-screenshot.sock`

## Customization

### Change Default Save Location
Edit the property in `ScreenshotWidget.qml`:
```qml
property string saveLocation: "/home/bryan/Pictures/Screenshots"
```

Or change it in the widget's text field at runtime (changes persist for that session).

### Adjust Widget Size
Modify `implicitWidth` and `implicitHeight` in `ScreenshotWidget.qml`, and update the margins calculation:
```qml
implicitWidth: 450
implicitHeight: 320

margins {
    top: (screen.height - 320) / 2
    left: (screen.width - 450) / 2
    right: (screen.width - 450) / 2
}
```
