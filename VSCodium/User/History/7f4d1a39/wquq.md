# YAHR Quickshell# Quickshell Configuration



**Y**et **A**nother **H**yprland **R**ice - A beautiful and feature-rich Quickshell configuration for Hyprland on Wayland.This is a migration from Waybar to Quickshell, a Qt/QML-based shell component system.



![Screenshot](https://img.shields.io/badge/Wayland-Only-blue?style=flat-square)## Installation

![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

### Arch Linux (AUR)

## 🎨 Features```bash

yay -S quickshell-git

- **Custom Top Bar** with system tray, clock, network, audio, and battery indicators# or

- **App Launcher** with fuzzy search and keyboard navigationparu -S quickshell-git

- **Power Menu** with logout, lock, suspend, reboot, and shutdown options```

- **Screenshot Widget** integrated with hyprshot

- **Theme Switcher** with support for multiple themes### From Source

- **Wallpaper Picker** using swww```bash

- **Calendar Widget** with weather integrationgit clone https://github.com/outfoxxed/quickshell

- **Notification Center** with DND supportcd quickshell

- **Settings Panel** for customizationcmake -B build -DCMAKE_BUILD_TYPE=Release

- **Flatpak Support** - automatically detects and lists Flatpak applicationscmake --build build

- **Theme Synchronization** - automatically syncs themes with VSCodium and Zedsudo cmake --install build

```

## 📦 Required Packages

## Running Quickshell

### Core Dependencies

```bash### Test your configuration

# Arch Linux / AUR```bash

yay -S quickshell-git       # The shell itselfquickshell

yay -S qt6-base             # Qt6 base```

yay -S qt6-declarative      # QML support

```### Auto-start with Hyprland

Add to your `~/.config/hypr/hyprland.conf`:

### System Tools```

```bashexec-once = quickshell

sudo pacman -S hyprland      # Wayland compositor```

sudo pacman -S hyprshot      # Screenshots

sudo pacman -S swww          # Wallpaper daemonIf you're currently running Waybar, kill it first:

sudo pacman -S python        # Theme sync scripts```bash

```killall waybar

```

### Optional (for full functionality)

```bash## Configuration Structure

# Application launcher

sudo pacman -S thunar        # File manager- `shell.qml` - Main entry point, defines the panel window

- `Bar.qml` - Main bar layout with left/center/right sections

# Screenshot/Screen recording- Component files:

yay -S gpu-screen-recorder-gui  # GPU-accelerated screen recorder  - `ArchButton.qml` - App launcher button

  - `WorkspaceBar.qml` - Hyprland workspace switcher

# Notifications  - `Clock.qml` - Date and time display

sudo pacman -S libnotify     # Desktop notifications  - `Network.qml` - Network status indicator

  - `Audio.qml` - Volume control

# Flatpak support (optional)  - `Battery.qml` - Battery status

sudo pacman -S flatpak       # For Flatpak app support  - `PowerButton.qml` - Power menu

```  - Various launcher buttons (Kitty, Nautilus, Firefox, etc.)



## 🚀 Installation## Advantages over Waybar



1. **Clone the repository:**1. **Full Programming Language**: QML/JavaScript gives you complete control

   ```bash2. **Better State Management**: Reactive properties and signals

   git clone https://github.com/bgibson72/yahr-quickshell.git3. **Custom Widgets**: Build any widget you can imagine

   cd yahr-quickshell4. **Animations**: Smooth transitions and effects

   ```5. **Complex Layouts**: Nested components and dynamic layouts

6. **Direct System Integration**: Access to Qt APIs and system services

2. **Backup your existing config (if any):**

   ```bash## Customization

   mv ~/.config/quickshell ~/.config/quickshell.backup

   ```### Colors

The Tokyo Night theme colors are defined in each component. To change the theme:

3. **Copy files to config directory:**1. Update color values in each `.qml` file

   ```bash2. Or create a `Theme.qml` singleton for centralized theme management

   cp -r . ~/.config/quickshell

   ```### Adding New Features

Some ideas for features that are difficult/impossible in Waybar:

4. **Make scripts executable:**

   ```bash1. **Custom Widgets**: System monitor graphs, weather, calendar popup

   chmod +x ~/.config/quickshell/*.sh2. **Animations**: Smooth transitions, sliding panels

   chmod +x ~/.config/quickshell/toggle-*3. **Complex Interactions**: Drag and drop, right-click menus

   chmod +x ~/.config/quickshell/scripts/*.sh4. **Dynamic Content**: Live data visualizations

   ```5. **Window Management**: Interactive window switcher with previews



5. **Start Quickshell:**### Example: Adding a System Monitor

   ```bashCreate `SystemMonitor.qml`:

   quickshell &```qml

   ```import QtQuick

import QtCharts

## ⚙️ Configuration

ChartView {

### Hyprland Integration    width: 200

    height: 100

Add these bindings to your `~/.config/hypr/hyprland.conf`:    // Add CPU/RAM usage graphs

}

```conf```

# Quickshell widgets

bind = $mainMod, Space, exec, ~/.config/quickshell/toggle-app-launcher## Debugging

bind = $mainMod, C, exec, ~/.config/quickshell/toggle-calendar

bind = $mainMod, N, exec, ~/.config/quickshell/toggle-notification-centerRun with debug output:

bind = $mainMod, Escape, exec, ~/.config/quickshell/toggle-power-menu```bash

bind = $mainMod SHIFT, S, exec, ~/.config/quickshell/toggle-screenshotQT_LOGGING_RULES="quickshell.*=true" quickshell

bind = $mainMod, T, exec, ~/.config/quickshell/toggle-theme-switcher```

bind = $mainMod, W, exec, ~/.config/quickshell/toggle-wallpaper-picker

## Documentation

# Screenshot

bind = $mainMod, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots- Quickshell Docs: https://quickshell.outfoxxed.me/

- QML Reference: https://doc.qt.io/qt-6/qmlapplications.html

# Reload Quickshell

bind = $mainMod SHIFT, R, exec, ~/.config/quickshell/restart-quickshell.sh## Migration Notes

```

All your Waybar features have been migrated:

### Settings- ✅ App launcher

- ✅ Workspace management  

Settings are stored in `~/.config/quickshell/settings.json`. You can modify them directly or use the built-in Settings widget (accessible from the bar or via keybinding).- ✅ Application shortcuts

- ✅ Clock with date/time

**Key settings:**- ✅ System updates counter

- `theme`: Current theme name- ✅ Network status

- `systemTray`: Show/hide battery, volume, and network details- ✅ Volume control

- `wallpaperPath`: Default wallpaper location- ✅ Battery indicator

- `saveLocation`: Screenshot save location- ✅ Power menu



## 🎨 ThemesThe functionality is the same, but now you have the power to extend it further!


Three beautiful themes are included:

- **Catppuccin Mocha** - Soothing pastel theme
- **Tokyo Night** - A clean, dark Tokyo-inspired theme
- **Gruvbox Dark** - Retro groove with warm colors

### Switching Themes

**Via GUI:**
- Use `Super + T` to open the theme switcher
- Click on a theme to apply

**Via Command Line:**
```bash
~/.config/quickshell/switch-theme.sh <theme-name>
```

Example:
```bash
~/.config/quickshell/switch-theme.sh catppuccin-mocha
```

### Adding Custom Themes

1. Create a new theme file in `~/.config/quickshell/themes/`
2. Copy an existing theme as a template
3. Modify the colors to your liking
4. The theme will automatically appear in the theme switcher

### Theme Synchronization

Themes automatically sync with:
- ✅ Quickshell (instant)
- ✅ VSCodium (via sync script)
- ✅ Zed (via sync script)

## 📁 Project Structure

```
quickshell/
├── shell.qml                 # Main entry point
├── Bar.qml                   # Top bar component
├── AppLauncher.qml          # Application launcher
├── PowerMenu.qml            # Power menu
├── CalendarWidget.qml       # Calendar widget
├── ScreenshotWidget.qml     # Screenshot tool
├── ThemeSwitcher.qml        # Theme selector
├── WallpaperPicker.qml      # Wallpaper chooser
├── NotificationCenter.qml   # Notification panel
├── SettingsWidget.qml       # Settings panel
├── ThemeManager.qml         # Active theme
├── themes/                  # Theme definitions
│   ├── catppuccin-mocha.qml
│   ├── tokyonight-night.qml
│   └── gruvbox-dark.qml
├── scripts/                 # Helper scripts
│   ├── list-apps.sh         # Application discovery
│   ├── powermenu.sh         # Power actions
│   └── toggle-widget.sh     # Widget toggling
├── switch-theme.sh          # Theme switcher
├── sync-vscodium-theme.sh   # VSCodium theme sync
├── sync-zed-theme.sh        # Zed theme sync
├── take-screenshot.sh       # Screenshot helper
├── restart-quickshell.sh    # Reload Quickshell
└── toggle-*                 # Widget toggle scripts
```

## 🎯 Widgets Overview

### App Launcher
- **Keybind:** `Super + Space`
- **Features:**
  - Fuzzy search
  - Keyboard navigation (↑↓ arrows, Enter to launch)
  - Automatic refresh for newly installed apps
  - Flatpak app support

### Power Menu
- **Keybind:** `Super + Escape`
- **Actions:** Lock, Logout, Suspend, Reboot, Shutdown
- **Features:** Keyboard shortcuts for each action

### Screenshot Widget
- **Keybind:** `Super + Shift + S`
- **Modes:** Region, Window, Output
- **Options:**
  - Save to disk
  - Copy to clipboard
  - Delay timer

### Calendar Widget
- **Keybind:** `Super + C`
- **Features:**
  - Month view
  - Date selection
  - Current date highlighting

### Theme Switcher
- **Keybind:** `Super + T`
- **Features:**
  - Visual theme preview
  - One-click theme switching
  - Auto-sync with VSCodium and Zed

### Wallpaper Picker
- **Keybind:** `Super + W`
- **Features:**
  - Browse wallpaper directory
  - Live preview
  - Integration with swww

### Notification Center
- **Keybind:** `Super + N`
- **Features:**
  - Notification history
  - Do Not Disturb toggle
  - Clear all notifications

## 🔧 Troubleshooting

### Quickshell won't start
```bash
# Check for errors
quickshell

# View logs
tail -f /run/user/1000/quickshell/by-id/*/log.qslog
```

### App launcher not showing apps
```bash
# Test the app list script
~/.config/quickshell/scripts/list-apps.sh
```

### Themes not applying
```bash
# Manually run theme switch
~/.config/quickshell/switch-theme.sh catppuccin-mocha

# Check ThemeManager.qml exists
ls -la ~/.config/quickshell/ThemeManager.qml
```

### Screenshots not working
```bash
# Ensure hyprshot is installed
which hyprshot

# Test manually
hyprshot -m region -o ~/Pictures/Screenshots
```

## 📝 Additional Documentation

- `QUICK_REFERENCE.txt` - Quick command reference
- `THEMING.md` - Detailed theming guide
- `TROUBLESHOOTING.md` - Extended troubleshooting guide
- `VSCODIUM_THEME_SYNC.md` - VSCodium theme sync details

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Share your custom themes

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- [Quickshell](https://github.com/outfoxxed/quickshell) - The amazing Wayland shell framework
- [Catppuccin](https://github.com/catppuccin) - Beautiful color palette
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Inspired theme
- [Gruvbox](https://github.com/morhetz/gruvbox) - Retro groove theme

## 📬 Contact

- GitHub: [@bgibson72](https://github.com/bgibson72)
- Repository: [yahr-quickshell](https://github.com/bgibson72/yahr-quickshell)

---

**Enjoy your beautiful Hyprland setup! 🚀**
