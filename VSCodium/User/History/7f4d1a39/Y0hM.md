# YAHR Quickshell# YAHR Quickshell# Quickshell Configuration



**Y**et **A**nother **H**yprland **R**ice - A beautiful and feature-rich Quickshell configuration for Hyprland on Wayland.



![Screenshot](https://img.shields.io/badge/Wayland-Only-blue?style=flat-square)**Y**et **A**nother **H**yprland **R**ice - A beautiful and feature-rich Quickshell configuration for Hyprland on Wayland.This is a migration from Waybar to Quickshell, a Qt/QML-based shell component system.

![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)



## 🎨 Features

![Screenshot](https://img.shields.io/badge/Wayland-Only-blue?style=flat-square)## Installation

- **Custom Top Bar** with system tray, clock, network, audio, and battery indicators

- **App Launcher** with fuzzy search and keyboard navigation![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

- **Power Menu** with logout, lock, suspend, reboot, and shutdown options

- **Screenshot Widget** integrated with hyprshot### Arch Linux (AUR)

- **Theme Switcher** with support for multiple themes

- **Wallpaper Picker** using swww## 🎨 Features```bash

- **Calendar Widget** with weather integration

- **Notification Center** with DND supportyay -S quickshell-git

- **Settings Panel** for customization

- **Flatpak Support** - automatically detects and lists Flatpak applications- **Custom Top Bar** with system tray, clock, network, audio, and battery indicators# or

- **Theme Synchronization** - automatically syncs themes with VSCodium and Zed

- **Complete GTK Themes & Icons** - includes all matching themes and icon sets- **App Launcher** with fuzzy search and keyboard navigationparu -S quickshell-git



## 📦 Dependencies & Installation- **Power Menu** with logout, lock, suspend, reboot, and shutdown options```



### Core Dependencies- **Screenshot Widget** integrated with hyprshot

```bash

# Quickshell (from AUR)- **Theme Switcher** with support for multiple themes### From Source

yay -S quickshell-git

- **Wallpaper Picker** using swww```bash

# Qt6 dependencies

sudo pacman -S qt6-base qt6-declarative- **Calendar Widget** with weather integrationgit clone https://github.com/outfoxxed/quickshell

```

- **Notification Center** with DND supportcd quickshell

### System Tools & Compositor

```bash- **Settings Panel** for customizationcmake -B build -DCMAKE_BUILD_TYPE=Release

# Wayland compositor

sudo pacman -S hyprland- **Flatpak Support** - automatically detects and lists Flatpak applicationscmake --build build



# Screenshot tool- **Theme Synchronization** - automatically syncs themes with VSCodium and Zedsudo cmake --install build

sudo pacman -S hyprshot

```

# Wallpaper daemon

sudo pacman -S swww## 📦 Required Packages



# Python for theme sync## Running Quickshell

sudo pacman -S python

```### Core Dependencies



### Required Applications```bash### Test your configuration

```bash

# Terminal emulator (used in keybindings)# Arch Linux / AUR```bash

sudo pacman -S kitty

yay -S quickshell-git       # The shell itselfquickshell

# File manager

sudo pacman -S thunaryay -S qt6-base             # Qt6 base```



# System info toolyay -S qt6-declarative      # QML support

sudo pacman -S fastfetch

```### Auto-start with Hyprland

# Audio control

sudo pacman -S pavucontrolAdd to your `~/.config/hypr/hyprland.conf`:



# Network management### System Tools```

sudo pacman -S networkmanager network-manager-applet

```bashexec-once = quickshell

# GTK theme/icon selector

yay -S nwg-looksudo pacman -S hyprland      # Wayland compositor```



# System update notifiersudo pacman -S hyprshot      # Screenshots

yay -S simple-update-notifier

```sudo pacman -S swww          # Wallpaper daemonIf you're currently running Waybar, kill it first:



### Optional Enhancementssudo pacman -S python        # Theme sync scripts```bash

```bash

# GPU-accelerated screen recording```killall waybar

yay -S gpu-screen-recorder-gui

```

# Desktop notifications

sudo pacman -S libnotify### Optional (for full functionality)



# Flatpak support```bash## Configuration Structure

sudo pacman -S flatpak

```# Application launcher



## 🚀 Installationsudo pacman -S thunar        # File manager- `shell.qml` - Main entry point, defines the panel window



### 1. Clone the Repository- `Bar.qml` - Main bar layout with left/center/right sections

```bash

git clone https://github.com/bgibson72/yahr-quickshell.git# Screenshot/Screen recording- Component files:

cd yahr-quickshell

```yay -S gpu-screen-recorder-gui  # GPU-accelerated screen recorder  - `ArchButton.qml` - App launcher button



### 2. Backup Existing Config  - `WorkspaceBar.qml` - Hyprland workspace switcher

```bash

# Backup your current quickshell config (if any)# Notifications  - `Clock.qml` - Date and time display

mv ~/.config/quickshell ~/.config/quickshell.backup

```sudo pacman -S libnotify     # Desktop notifications  - `Network.qml` - Network status indicator



### 3. Install Quickshell Config  - `Audio.qml` - Volume control

```bash

# Create config directory# Flatpak support (optional)  - `Battery.qml` - Battery status

mkdir -p ~/.config/quickshell

sudo pacman -S flatpak       # For Flatpak app support  - `PowerButton.qml` - Power menu

# Copy all configuration files

cp -r AdvancedExamples.qml AppLauncher.qml ArchButton.qml Audio.qml \```  - Various launcher buttons (Kitty, Nautilus, Firefox, etc.)

      Bar.qml Battery.qml CalendarState.qml CalendarWidget.qml Clock.qml \

      FilesButton.qml FirefoxButton.qml IconButton.qml KittyButton.qml \

      Network.qml NotificationCenter.qml NotificationIndicator.qml \

      NotificationPopup.qml NotificationService.qml PowerButton.qml \## 🚀 Installation## Advantages over Waybar

      PowerMenu.qml QuickAccessDrawer.qml ScreenshotButton.qml \

      ScreenshotWidget.qml Separator.qml SettingsButton.qml SettingsWidget.qml \

      SystemTray.qml ThemeButton.qml ThemeManager.qml ThemeSwitcher.qml \

      Updates.qml WallpaperButton.qml WallpaperPicker.qml WallpaperPickerBridge.qml \1. **Clone the repository:**1. **Full Programming Language**: QML/JavaScript gives you complete control

      WallpaperPickerManager.qml WorkspaceBar.qml shell.qml settings.json \

      ~/.config/quickshell/   ```bash2. **Better State Management**: Reactive properties and signals



# Copy scripts   git clone https://github.com/bgibson72/yahr-quickshell.git3. **Custom Widgets**: Build any widget you can imagine

cp -r scripts themes ~/.config/quickshell/

   cd yahr-quickshell4. **Animations**: Smooth transitions and effects

# Copy shell scripts

cp *.sh *-* ~/.config/quickshell/   ```5. **Complex Layouts**: Nested components and dynamic layouts

```

6. **Direct System Integration**: Access to Qt APIs and system services

### 4. Install GTK Themes & Icons

```bash2. **Backup your existing config (if any):**

# Create directories

mkdir -p ~/.themes ~/.icons   ```bash## Customization



# Install GTK themes   mv ~/.config/quickshell ~/.config/quickshell.backup

cp -r gtk-themes/* ~/.themes/

   ```### Colors

# Install icon themes

cp -r gtk-icons/* ~/.icons/The Tokyo Night theme colors are defined in each component. To change the theme:



# Refresh GTK cache3. **Copy files to config directory:**1. Update color values in each `.qml` file

gtk-update-icon-cache ~/.icons/* 2>/dev/null

```   ```bash2. Or create a `Theme.qml` singleton for centralized theme management



### 5. Make Scripts Executable   cp -r . ~/.config/quickshell

```bash

cd ~/.config/quickshell   ```### Adding New Features

chmod +x *.sh toggle-* scripts/*.sh

```Some ideas for features that are difficult/impossible in Waybar:



### 6. Start Quickshell4. **Make scripts executable:**

```bash

quickshell &   ```bash1. **Custom Widgets**: System monitor graphs, weather, calendar popup

```

   chmod +x ~/.config/quickshell/*.sh2. **Animations**: Smooth transitions, sliding panels

## ⚙️ Configuration

   chmod +x ~/.config/quickshell/toggle-*3. **Complex Interactions**: Drag and drop, right-click menus

### Hyprland Integration

   chmod +x ~/.config/quickshell/scripts/*.sh4. **Dynamic Content**: Live data visualizations

Add these bindings to your `~/.config/hypr/hyprland.conf`:

   ```5. **Window Management**: Interactive window switcher with previews

```conf

# Quickshell widgets

bind = $mainMod, Space, exec, ~/.config/quickshell/toggle-app-launcher

bind = $mainMod, C, exec, ~/.config/quickshell/toggle-calendar5. **Start Quickshell:**### Example: Adding a System Monitor

bind = $mainMod, N, exec, ~/.config/quickshell/toggle-notification-center

bind = $mainMod, Escape, exec, ~/.config/quickshell/toggle-power-menu   ```bashCreate `SystemMonitor.qml`:

bind = $mainMod SHIFT, S, exec, ~/.config/quickshell/toggle-screenshot

bind = $mainMod, T, exec, ~/.config/quickshell/toggle-theme-switcher   quickshell &```qml

bind = $mainMod, W, exec, ~/.config/quickshell/toggle-wallpaper-picker

   ```import QtQuick

# Screenshot

bind = $mainMod, Print, exec, hyprshot -m output -o ~/Pictures/Screenshotsimport QtCharts



# Reload Quickshell## ⚙️ Configuration

bind = $mainMod SHIFT, R, exec, ~/.config/quickshell/restart-quickshell.sh

```ChartView {



### Auto-start with Hyprland### Hyprland Integration    width: 200



Add to your `~/.config/hypr/hyprland.conf`:    height: 100



```confAdd these bindings to your `~/.config/hypr/hyprland.conf`:    // Add CPU/RAM usage graphs

# Auto-start Quickshell

exec-once = quickshell}



# Auto-start wallpaper daemon```conf```

exec-once = swww-daemon

# Quickshell widgets

# Auto-start network manager

exec-once = nm-applet --indicatorbind = $mainMod, Space, exec, ~/.config/quickshell/toggle-app-launcher## Debugging

```

bind = $mainMod, C, exec, ~/.config/quickshell/toggle-calendar

### Settings

bind = $mainMod, N, exec, ~/.config/quickshell/toggle-notification-centerRun with debug output:

Settings are stored in `~/.config/quickshell/settings.json`. You can modify them directly or use the built-in Settings widget.

bind = $mainMod, Escape, exec, ~/.config/quickshell/toggle-power-menu```bash

**Key settings:**

- `theme`: Current theme namebind = $mainMod SHIFT, S, exec, ~/.config/quickshell/toggle-screenshotQT_LOGGING_RULES="quickshell.*=true" quickshell

- `systemTray`: Show/hide battery, volume, and network details

- `wallpaperPath`: Default wallpaper locationbind = $mainMod, T, exec, ~/.config/quickshell/toggle-theme-switcher```

- `saveLocation`: Screenshot save location

bind = $mainMod, W, exec, ~/.config/quickshell/toggle-wallpaper-picker

## 🎨 Themes

## Documentation

Three beautiful themes are included with matching GTK themes and icons:

# Screenshot

- **Catppuccin Mocha** - Soothing pastel theme

- **Tokyo Night** - A clean, dark Tokyo-inspired themebind = $mainMod, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots- Quickshell Docs: https://quickshell.outfoxxed.me/

- **Gruvbox Dark** - Retro groove with warm colors

- QML Reference: https://doc.qt.io/qt-6/qmlapplications.html

### Included GTK Themes

All themes are in the `gtk-themes/` directory:# Reload Quickshell

- Catppuccin-Dark (hdpi, xhdpi variants)

- Tokyonight-Dark (hdpi, xhdpi variants)bind = $mainMod SHIFT, R, exec, ~/.config/quickshell/restart-quickshell.sh## Migration Notes

- Gruvbox-Dark (hdpi, xhdpi variants)

- Everforest-Dark, Rosepine-Dark, Material-Dark-Palenight```

- Nightfox-Dark-Duskfox, Kanagawa-Dark-Dragon

- Dracula, Eldritch, Nordic, Osaka-DarkAll your Waybar features have been migrated:



### Included Icon Themes### Settings- ✅ App launcher

All icon sets are in the `gtk-icons/` directory:

- Catppuccin-Mocha- ✅ Workspace management  

- Tokyonight-Dark

- Gruvbox-DarkSettings are stored in `~/.config/quickshell/settings.json`. You can modify them directly or use the built-in Settings widget (accessible from the bar or via keybinding).- ✅ Application shortcuts

- Everforest-Dark, Rose-Pine-Moon

- Material-DeepOcean, Nightfox-Duskfox, Kanagawa- ✅ Clock with date/time

- Dracula, Eldritch, Nordic

**Key settings:**- ✅ System updates counter

### Switching Themes

- `theme`: Current theme name- ✅ Network status

**Via GUI:**

- Use `Super + T` to open the theme switcher- `systemTray`: Show/hide battery, volume, and network details- ✅ Volume control

- Click on a theme to apply

- GTK themes and icons sync automatically via `nwg-look`- `wallpaperPath`: Default wallpaper location- ✅ Battery indicator



**Via Command Line:**- `saveLocation`: Screenshot save location- ✅ Power menu

```bash

~/.config/quickshell/switch-theme.sh <theme-name>

```

## 🎨 ThemesThe functionality is the same, but now you have the power to extend it further!

Example:

```bash

~/.config/quickshell/switch-theme.sh catppuccin-mochaThree beautiful themes are included:

```

- **Catppuccin Mocha** - Soothing pastel theme

### Adding Custom Themes- **Tokyo Night** - A clean, dark Tokyo-inspired theme

- **Gruvbox Dark** - Retro groove with warm colors

1. Create a new theme file in `~/.config/quickshell/themes/`

2. Copy an existing theme as a template### Switching Themes

3. Modify the colors to your liking

4. Add matching GTK theme to `~/.themes/`**Via GUI:**

5. Add matching icon theme to `~/.icons/`- Use `Super + T` to open the theme switcher

6. The theme will automatically appear in the theme switcher- Click on a theme to apply



### Theme Synchronization**Via Command Line:**

```bash

Themes automatically sync with:~/.config/quickshell/switch-theme.sh <theme-name>

- ✅ Quickshell (instant)```

- ✅ GTK applications (via nwg-look)

- ✅ VSCodium (via sync script)Example:

- ✅ Zed (via sync script)```bash

~/.config/quickshell/switch-theme.sh catppuccin-mocha

## 📁 Project Structure```



```### Adding Custom Themes

quickshell/

├── shell.qml                 # Main entry point1. Create a new theme file in `~/.config/quickshell/themes/`

├── Bar.qml                   # Top bar component2. Copy an existing theme as a template

├── AppLauncher.qml          # Application launcher3. Modify the colors to your liking

├── PowerMenu.qml            # Power menu4. The theme will automatically appear in the theme switcher

├── CalendarWidget.qml       # Calendar widget

├── ScreenshotWidget.qml     # Screenshot tool### Theme Synchronization

├── ThemeSwitcher.qml        # Theme selector

├── WallpaperPicker.qml      # Wallpaper chooserThemes automatically sync with:

├── NotificationCenter.qml   # Notification panel- ✅ Quickshell (instant)

├── SettingsWidget.qml       # Settings panel- ✅ VSCodium (via sync script)

├── ThemeManager.qml         # Active theme- ✅ Zed (via sync script)

├── themes/                  # Quickshell theme definitions

│   ├── catppuccin-mocha.qml## 📁 Project Structure

│   ├── tokyonight-night.qml

│   └── gruvbox-dark.qml```

├── gtk-themes/              # GTK themes (30 themes)quickshell/

├── gtk-icons/               # Icon themes (12 sets)├── shell.qml                 # Main entry point

├── scripts/                 # Helper scripts├── Bar.qml                   # Top bar component

│   ├── list-apps.sh         # Application discovery├── AppLauncher.qml          # Application launcher

│   ├── powermenu.sh         # Power actions├── PowerMenu.qml            # Power menu

│   └── toggle-widget.sh     # Widget toggling├── CalendarWidget.qml       # Calendar widget

├── switch-theme.sh          # Theme switcher├── ScreenshotWidget.qml     # Screenshot tool

├── sync-vscodium-theme.sh   # VSCodium theme sync├── ThemeSwitcher.qml        # Theme selector

├── sync-zed-theme.sh        # Zed theme sync├── WallpaperPicker.qml      # Wallpaper chooser

├── take-screenshot.sh       # Screenshot helper├── NotificationCenter.qml   # Notification panel

├── restart-quickshell.sh    # Reload Quickshell├── SettingsWidget.qml       # Settings panel

└── toggle-*                 # Widget toggle scripts├── ThemeManager.qml         # Active theme

```├── themes/                  # Theme definitions

│   ├── catppuccin-mocha.qml

## 🎯 Widgets Overview│   ├── tokyonight-night.qml

│   └── gruvbox-dark.qml

### App Launcher├── scripts/                 # Helper scripts

- **Keybind:** `Super + Space`│   ├── list-apps.sh         # Application discovery

- **Features:**│   ├── powermenu.sh         # Power actions

  - Fuzzy search│   └── toggle-widget.sh     # Widget toggling

  - Keyboard navigation (↑↓ arrows, Enter to launch)├── switch-theme.sh          # Theme switcher

  - Automatic refresh for newly installed apps├── sync-vscodium-theme.sh   # VSCodium theme sync

  - Flatpak app support├── sync-zed-theme.sh        # Zed theme sync

├── take-screenshot.sh       # Screenshot helper

### Power Menu├── restart-quickshell.sh    # Reload Quickshell

- **Keybind:** `Super + Escape`└── toggle-*                 # Widget toggle scripts

- **Actions:** Lock, Logout, Suspend, Reboot, Shutdown```

- **Features:** Keyboard shortcuts for each action

## 🎯 Widgets Overview

### Screenshot Widget

- **Keybind:** `Super + Shift + S`### App Launcher

- **Modes:** Region, Window, Output- **Keybind:** `Super + Space`

- **Options:**- **Features:**

  - Save to disk  - Fuzzy search

  - Copy to clipboard  - Keyboard navigation (↑↓ arrows, Enter to launch)

  - Delay timer  - Automatic refresh for newly installed apps

  - Flatpak app support

### Calendar Widget

- **Keybind:** `Super + C`### Power Menu

- **Features:**- **Keybind:** `Super + Escape`

  - Month view- **Actions:** Lock, Logout, Suspend, Reboot, Shutdown

  - Date selection- **Features:** Keyboard shortcuts for each action

  - Current date highlighting

### Screenshot Widget

### Theme Switcher- **Keybind:** `Super + Shift + S`

- **Keybind:** `Super + T`- **Modes:** Region, Window, Output

- **Features:**- **Options:**

  - Visual theme preview  - Save to disk

  - One-click theme switching  - Copy to clipboard

  - Auto-sync with GTK, VSCodium, and Zed  - Delay timer



### Wallpaper Picker### Calendar Widget

- **Keybind:** `Super + W`- **Keybind:** `Super + C`

- **Features:**- **Features:**

  - Browse wallpaper directory  - Month view

  - Live preview  - Date selection

  - Integration with swww  - Current date highlighting



### Notification Center### Theme Switcher

- **Keybind:** `Super + N`- **Keybind:** `Super + T`

- **Features:**- **Features:**

  - Notification history  - Visual theme preview

  - Do Not Disturb toggle  - One-click theme switching

  - Clear all notifications  - Auto-sync with VSCodium and Zed



## 🔧 Troubleshooting### Wallpaper Picker

- **Keybind:** `Super + W`

### Quickshell won't start- **Features:**

```bash  - Browse wallpaper directory

# Check for errors  - Live preview

quickshell  - Integration with swww



# View logs### Notification Center

tail -f /run/user/1000/quickshell/by-id/*/log.qslog- **Keybind:** `Super + N`

```- **Features:**

  - Notification history

### App launcher not showing apps  - Do Not Disturb toggle

```bash  - Clear all notifications

# Test the app list script

~/.config/quickshell/scripts/list-apps.sh## 🔧 Troubleshooting

```

### Quickshell won't start

### Themes not applying```bash

```bash# Check for errors

# Manually run theme switchquickshell

~/.config/quickshell/switch-theme.sh catppuccin-mocha

# View logs

# Check ThemeManager.qml existstail -f /run/user/1000/quickshell/by-id/*/log.qslog

ls -la ~/.config/quickshell/ThemeManager.qml```



# Verify GTK themes installed### App launcher not showing apps

ls ~/.themes/```bash

```# Test the app list script

~/.config/quickshell/scripts/list-apps.sh

### Icons not showing```

```bash

# Verify icon themes installed### Themes not applying

ls ~/.icons/```bash

# Manually run theme switch

# Rebuild icon cache~/.config/quickshell/switch-theme.sh catppuccin-mocha

gtk-update-icon-cache ~/.icons/*

```# Check ThemeManager.qml exists

ls -la ~/.config/quickshell/ThemeManager.qml

### Screenshots not working```

```bash

# Ensure hyprshot is installed### Screenshots not working

which hyprshot```bash

# Ensure hyprshot is installed

# Test manuallywhich hyprshot

hyprshot -m region -o ~/Pictures/Screenshots

```# Test manually

hyprshot -m region -o ~/Pictures/Screenshots

### Network/Audio widgets not working```

```bash

# Check NetworkManager is running## 📝 Additional Documentation

systemctl status NetworkManager

- `QUICK_REFERENCE.txt` - Quick command reference

# Check PulseAudio/Pipewire is running- `THEMING.md` - Detailed theming guide

pactl info- `TROUBLESHOOTING.md` - Extended troubleshooting guide

```- `VSCODIUM_THEME_SYNC.md` - VSCodium theme sync details



## 📝 Additional Documentation## 🤝 Contributing



- `QUICK_REFERENCE.txt` - Quick command referenceContributions are welcome! Feel free to:

- `THEMING.md` - Detailed theming guide- Report bugs

- `TROUBLESHOOTING.md` - Extended troubleshooting guide- Suggest features

- `VSCODIUM_THEME_SYNC.md` - VSCodium theme sync details- Submit pull requests

- Share your custom themes

## 🤝 Contributing

## 📄 License

Contributions are welcome! Feel free to:

- Report bugsMIT License - See LICENSE file for details

- Suggest features

- Submit pull requests## 🙏 Acknowledgments

- Share your custom themes

- [Quickshell](https://github.com/outfoxxed/quickshell) - The amazing Wayland shell framework

## 📄 License- [Catppuccin](https://github.com/catppuccin) - Beautiful color palette

- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Inspired theme

MIT License - See LICENSE file for details- [Gruvbox](https://github.com/morhetz/gruvbox) - Retro groove theme



## 🙏 Acknowledgments## 📬 Contact



- [Quickshell](https://github.com/outfoxxed/quickshell) - The amazing Wayland shell framework- GitHub: [@bgibson72](https://github.com/bgibson72)

- [Catppuccin](https://github.com/catppuccin) - Beautiful color palette- Repository: [yahr-quickshell](https://github.com/bgibson72/yahr-quickshell)

- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Inspired theme

- [Gruvbox](https://github.com/morhetz/gruvbox) - Retro groove theme---

- All theme creators for the beautiful GTK themes and icons

**Enjoy your beautiful Hyprland setup! 🚀**

## 📬 Contact

- GitHub: [@bgibson72](https://github.com/bgibson72)
- Repository: [yahr-quickshell](https://github.com/bgibson72/yahr-quickshell)

---

**Enjoy your beautiful Hyprland setup! 🚀**
