# YahrShell - Yet Another Hyprland Rice 🍚

Complete Arch Linux desktop environment featuring Hyprland + Quickshell with unified theme system and comprehensive automated installation.

![yahr_home.png](previews/yahr_home.png)

## ✨ Features
- 🎨 **11 Beautiful Themes** - Instant switching across all applications
- 🖥️ **Quickshell Desktop** - Modern QML-based desktop environment
- ⚡ **Unified Theme System** - Synced themes for Hyprland, GTK, Kitty, Firefox, VSCodium, Discord, and more
- 🎯 **GPU-Aware Installation** - Auto-detects and installs appropriate drivers (NVIDIA/AMD/Intel/Hybrid)
- 🚀 **Fully Automated Installer** - One command from minimal Arch to complete desktop
- 🎭 **Icon Theme Integration** - Papirus icons with dynamic folder colors matching your theme
- 📦 **Complete Graphics Stack** - Wayland, Mesa, Vulkan, Qt5/Qt6 support
- 🔧 **Two Installation Modes** - Full (all features) or Minimal (core only)
- ⚙️ **YOLO Mode** - Completely unattended installation option

## 📋 Prerequisites

**All you need is a minimal Arch Linux installation!**

The installer handles everything else:
- ✅ GPU driver detection and installation (NVIDIA/AMD/Intel/Hybrid)
- ✅ AUR helper installation (yay/paru)
- ✅ Complete graphics stack (Wayland, Mesa, Vulkan, Qt)
- ✅ All dependencies and recommended packages
- ✅ Quickshell, Hyprland, and all desktop components
- ✅ Theme system and configurations

### Minimum Requirements
- Fresh or existing Arch Linux installation
- Internet connection
- `git` installed (`sudo pacman -S git`)

That's it! The installer does the rest.

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell

# Run the installer
./install.sh
```

### Installation Modes

**Normal Mode (Recommended for first-time users)**
- Interactive prompts for optional components
- Choose AUR helper (yay/paru)
- Select NVIDIA driver type (proprietary/nouveau)
- Optional: Neovim, Vesktop, VSCodium, Thunar, Firefox, SDDM

**YOLO Mode (Unattended)**
- Fully automated, zero prompts
- Auto-installs yay as AUR helper
- Auto-selects proprietary NVIDIA drivers
- Skips all optional components
- Perfect for scripted/VM installations

**Installation Types**
- **Full Install**: All core components + optional applications (recommended)
- **Minimal Install**: Core desktop only (Quickshell, Hyprland, Kitty, Mako)

## 🎯 What Gets Installed

### Core Components (Always Installed)
- **Quickshell** - Desktop environment framework
- **Hyprland** - Wayland compositor with complete configuration
- **GPU Drivers** - Auto-detected for your hardware
  - NVIDIA: nvidia-dkms, nvidia-utils (with proper env vars)
  - AMD: vulkan-radeon, mesa-vdpau, amdgpu
  - Intel: vulkan-intel, libva-intel-driver, intel-media-driver
  - Hybrid: All detected GPUs + envycontrol for switching
- **Graphics Stack**
  - Mesa, Wayland, XWayland
  - Qt5/Qt6 Wayland support
  - Vulkan, libinput, seatd, polkit
- **Kitty** - Terminal emulator with theme sync
- **Mako** - Notification daemon
- **Wallpapers** - Collection organized by theme
- **Papirus Icons** - With dynamic folder colors
- **Fonts** - Maple Mono Nerd Font family, Nerd Fonts Symbols
- **Starship** - Shell prompt with configuration

### Recommended Packages (Auto-Installed)
- **Audio**: PipeWire, WirePlumber, pavucontrol
- **Bluetooth**: Blueman
- **Network**: NetworkManager
- **Utilities**: Thunar, Firefox, brightnessctl
- **Screenshots**: hyprshot, grim, slurp
- **Tools**: nwg-look (GTK theme manager)
- **System Info**: fastfetch with themed logos
- **Fonts**: Noto Color Emoji for colored icons

### Optional Components (Full Install - User Choice)
- **Neovim** - Editor with AstroVim configuration and 10 synced colorschemes
- **Vesktop** - Discord client with Vencord theme support
- **VSCodium** - VS Code alternative with theme integration
- **Thunar** - File manager with thumbnail support and custom plugins
- **Firefox** - Browser with userChrome.css theming
- **SDDM** - Display manager (login screen) with theme
- **Pacseek** - Modern TUI package manager with CLI launcher support

## 🎨 Included Themes
Switch themes instantly with Super + T. All themes include matching wallpapers and synchronized colors across all applications.

<details>
<summary><b>Catppuccin (Mocha) - Default Theme</b></summary>

![catppuccin.png](previews/catppuccin.png)
</details>

<details>
<summary><b>Material (Palenight)</b></summary>

![material.png](previews/material.png)
</details>

<details>
<summary><b>Dracula</b></summary>

![dracula.png](previews/dracula.png)
</details>

<details>
<summary><b>Eldritch</b></summary>

![eldritch.png](previews/eldritch.png)
</details>

<details>
<summary><b>Everforest</b></summary>

![everforest.png](previews/everforest.png)
</details>

<details>
<summary><b>Gruvbox</b></summary>

![gruv_box.png](previews/gruv_box.png)
</details>

<details>
<summary><b>Kanagawa</b></summary>

![kanagawa.png](previews/kanagawa.png)
</details>

<details>
<summary><b>NightFox</b></summary>

![night_fox.png](previews/night_fox.png)
</details>

<details>
<summary><b>Nord</b></summary>

![nord.png](previews/nord.png)
</details>

<details>
<summary><b>Rosé Pine</b></summary>

![rose_pine.png](previews/rose_pine.png)
</details>

<details>
<summary><b>TokyoNight</b></summary>

![tokyo_night.png](previews/tokyo_night.png)
</details>


### Custom Widgets

<details>
<summary><b>App Launcher</b> - Super + A - Fuzzy search application launcher</summary>

![app_launcher.png](previews/app_launcher.png)
</details>

<details>
<summary><b>Calendar</b> - Super + C - Monthly calendar widget</summary>

![calendar.png](previews/calendar.png)
</details>

<details>
<summary><b>Power Menu</b> - Super + Escape - System controls</summary>

![power_menu.png](previews/power_menu.png)
</details>

<details>
<summary><b>Screenshot Tool</b> - Super + PrtScrn - Multi-mode screenshots</summary>

![screenshot_tool.png](previews/screenshot_tool.png)
</details>

<details>
<summary><b>Settings</b> - Super + Shift + S - Quickshell configuration panel</summary>

Configure weather, clock format, screenshots, system tray visibility, theme selection, bar transparency, and bar position (top/bottom).

![settings.png](previews/settings.png)
</details>

<details>
<summary><b>Theme Switcher</b> - Super + T - Visual theme selector</summary>

![theme_switcher.png](previews/theme_switcher.png)
</details>

<details>
<summary><b>Wallpaper Picker</b> - Super + Shift + W - Browse and select wallpapers</summary>

![wallpaper_picker.png](previews/wallpaper_picker.png)
</details>

<details>
<summary><b>SDDM Login Screen</b> - Themed display manager with automatic theme sync</summary>

Custom SDDM theme that automatically syncs colors and wallpaper with your selected theme. Test without logging out using: `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/yahr-theme`

![sddm_preview.png](previews/sddm_preview.png)
</details>


### System Integration
- Workspace management with visual indicators
- System tray with audio, network, and updates
- Notification system with urgency-based styling
- GTK theme synchronization
- **Configurable bar position** - Toggle between top and bottom placement
- **SDDM theme synchronization** - Login screen automatically syncs with system theme
- **Firefox theme synchronization** - Automatic Firefox UI theming via userChrome.css
- **Neovim theme synchronization** - AstroVim colorschemes sync with system theme
- **Fastfetch themed display** - System info with matching logo and colors
- **CLI app launcher support** - Terminal apps launch correctly from app launcher
- **Included GTK themes and icons** - Multiple theme-matched GTK themes and icon packs included in quickshell/gtk-themes/ and quickshell/gtk-icons/

## Hyprland Configuration

The Hyprland configuration is modularized for easier maintenance and customization. Instead of one monolithic config file, settings are organized into separate files:

- **monitors.conf** - Display configuration and monitor settings
- **programs.conf** - Default application definitions
- **autostart.conf** - Programs to launch at startup
- **variables.conf** - Environment variables
- **look-and-feel.conf** - Appearance, animations, layouts, and window decorations
- **input.conf** - Keyboard, mouse, touchpad, and gesture settings
- **keybinds.conf** - All keyboard shortcuts and bindings
- **rules.conf** - Window and workspace rules

The main `hyprland.conf` file sources all these modules, keeping it clean and organized. Edit individual files in `hypr/` to customize specific aspects of your setup without navigating through a large config file.

## Development & Customization

### Bidirectional Sync Scripts

For developers and power users who want to modify configs:

**Working with Live Configs:**
```bash
# Make changes directly in ~/.config/
# When ready to commit, sync changes back to repo:
./sync-from-live.sh

# Then commit and push:
git add -A
git commit -m "Your changes"
git push
```

**Testing Repo Changes:**
```bash
# Made changes in the repo? Test them in live config:
./sync-to-live.sh

# Restart affected applications (e.g., quickshell --replace &)
```

### Key Features & Recent Improvements

**Latest Updates (v1.2)**
- **Bar Position Toggle** - Choose top or bottom bar placement in Settings
- **Neovim Theme Sync** - AstroVim colorschemes now sync with system theme
- **Enhanced Installer** - Improved package detection, theme initialization, and optional component prompts
- **Thunar Thumbnails** - Full thumbnail support with tumbler and media plugins
- **Colored Weather Icons** - Emoji support via fontconfig configuration
- **CLI App Launcher Support** - Terminal-based apps (like Pacseek) now launch correctly
- **Fastfetch Integration** - Themed logo display with kitty graphics protocol

**Update Counter (v1.1)**
- Checks both official repos AND AUR packages
- Handles pacman lock files properly
- Uses paru/yay for AUR updates
- Updates every hour with wake-from-sleep detection

**Theme Synchronization**
- **Neovim** - 10 colorscheme mappings (Catppuccin, Everforest, Kanagawa, Dracula, Eldritch, Gruvbox, Nightfox, Nord, RosePine, TokyoNight)
- **Firefox** - Auto-detect profile and generate userChrome.css from theme colors
- **VS Code/VSCodium** - Separate theme sync with workbench color customizations
- **Kitty** - Dynamic terminal theme switching
- **GTK** - Synchronized via gsettings and settings.ini
- **Papirus Icons** - Folder colors automatically match active theme
- **Starship** - Color-only updates preserving custom glyphs
- **Hyprlock** - Lock screen colors match active theme
- **Fastfetch** - Logo updates to match theme

## Contributing

Contributions, issues, and feature requests are welcome!

## Credits & Inspiration

### Core Technologies
- [Quickshell](https://github.com/outfoxxed/quickshell) by outfoxxed - Desktop environment framework
- [Hyprland](https://hyprland.org/) by [Vaxry](https://github.com/vaxerski) - Dynamic tiling Wayland compositor

### GTK Themes & Icons
- [Fausto Korpsvart](https://github.com/Fausto-Korpsvart) - GTK themes and icon packs
- [Dracula GTK](https://github.com/dracula/gtk) by [Eliver Lara](https://github.com/EliverLara) - Dracula theme

### Inspired By
- [HyDE Project](https://github.com/prasanthrangan/hyprdots) - Hyprland configuration
- [JaKooLit](https://github.com/JaKooLit) - Hyprland configuration
- [Stephan Raabe's ML4W](https://www.ml4w.com) - Hyprland configuration
- [end-4](https://github.com/end-4) - quickshell, ags and desktop concepts
- [Matt-FTW](https://github.com/Matt-FTW) - quickshell and hyprland configuration
- [Caelestia-dots](https://github.com/Heus-Sueh/Caelestia-dots) - Beautiful quickshell configuration
- And many others in the r/unixporn and Hyprland communities

---

**Made with ❤️ for the Arch + Hyprland community**
