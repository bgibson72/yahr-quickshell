# YAHR - Yet Another Hyprland Rice 🍚

Complete Arch Linux + Hyprland desktop configuration with unified theme system.

![quickshell_preview.png](previews/quickshell_preview.png)

## Features
- 🎨 11 beautiful themes with instant switching
- 🖥️ Quickshell desktop environment
- ⚡ Synced themes across all apps
- 📦 Ready to use configurations
- 🎭 Includes GTK themes and icon packs

## Prerequisites

### Preinstalled Requirements
- Preinstalled Hyprland-compatible distro of your choice
- Preinstalled packages including hyprland and git (minimum requirements)

### Recommended Packages
- <a href="https://man.archlinux.org/man/xdg-user-dirs.1">xdg-user-dirs</a>
- <a href="https://github.com/outfoxxed/quickshell">quickshell</a>
- <a href="https://sw.kovidgoyal.net/kitty/">kitty</a>
- <a href="https://github.com/emersion/mako">mako</a>
- <a href="https://github.com/neovim/neovim">nvim</a>
- <a href="https://github.com/VSCodium/vscodium">VSCodium</a>
- <a href="https://github.com/Vencord/Vesktop">vesktop</a>
- <a href="https://github.com/Musagy/hypremoji">hypremoji</a>
- <a href="https://archlinux.org/packages/extra/x86_64/firefox/">firefox</a>

## Installation

### 1. Install Dependencies
Make sure you have all required packages installed (see Requirements section above).

### 2. Clone and Install Configurations
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell

# Backup existing configs (recommended)
mkdir -p ~/config-backup
cp -r ~/.config/{hypr,kitty,quickshell,mako,nvim,vesktop,VSCodium} ~/config-backup/ 2>/dev/null || true

# Install configurations
cp -r hypr kitty mako nvim vesktop VSCodium ~/.config/

# Install quickshell configuration
# Note: This copies all files including shell.qml, scripts, themes, and executables
cp -r quickshell ~/.config/
```

### 3. Configure Hyprland Autostart
Add quickshell to your Hyprland configuration:
```bash
# Add quickshell to autostart
echo 'exec-once = quickshell' >> ~/.config/hypr/hyprland.conf

# If you're migrating from Waybar, remove it from autostart
sed -i '/exec-once.*waybar/d' ~/.config/hypr/hyprland.conf
```

### 4. Start Quickshell
```bash
# Test quickshell (should launch without errors)
quickshell

# Or restart Hyprland to start everything fresh
# Log out and log back in, or press Super + Shift + E (if configured)
```

### Troubleshooting
- If `quickshell` can't find the config, ensure `~/.config/quickshell/shell.qml` exists
- For widget issues, check that all scripts in `~/.config/quickshell/` are executable: `chmod +x ~/.config/quickshell/*.sh ~/.config/quickshell/toggle-*`
- Check logs: `cat /run/user/$(id -u)/quickshell/by-id/*/log.qslog`

## Included Applications

- **hypr** - Hyprland window manager with 11 theme definitions
- **quickshell** - Custom desktop environment (bar, widgets, controls)
- **kitty** - Terminal emulator with theme synchronization
- **mako** - Notification daemon with themed styling
- **nvim** - Neovim with AstroNvim configuration
- **VSCodium** - VS Code fork with theme integration
  - **Note**: If you prefer Microsoft's VS Code, you can adapt the theme sync by changing the path in `sync-vscodium-theme.sh` from `~/.config/VSCodium/User/settings.json` to `~/.config/Code/User/settings.json`
- **vesktop** - Discord client with theme support

## Key Features

### Unified Theme System
Switch themes instantly across all applications with Super + T. Available themes:
- Material (Palenight)

![material_preview.png](previews/material_preview.png)

- Catppuccin (Mocha)

![catppuccin_preview.png](previews/catppuccin_preview.png)

- Dracula

![dracula_preview.png](previews/dracula_preview.png)

- Eldritch

![eldritch_preview.png](previews/eldritch_preview.png)

- Everforest

![everforest_preview.png](previews/everforest_preview.png)

- Gruvbox

![gruvbox_preview.png](previews/gruvbox_preview.png)

- Kanagawa

![kanagawa_preview.png](previews/kanagawa_preview.png)

- NightFox

![nightfox_preview.png](previews/nightfox_preview.png)

- Nord

![nord_preview.png](previews/nord_preview.png)

- Rosé Pine

![rosepine_preview.png](previews/rosepine_preview.png)

- TokyoNight

![tokyonight_preview.png](previews/tokyonight_preview.png)


### Custom Widgets
- **App Launcher** - Super + A - Fuzzy search application launcher

![app_launcher.png](previews/app_launcher.png)

- **Calendar** - Super + C - Monthly calendar widget

![calendar.png](previews/calendar.png)

- **Power Menu** - Super + Escape - System controls

![power_menu.png](previews/power_menu.png)

- **Screenshot Tool** - Super + PrtScrn - Multi-mode screenshots

![screenshot_tool.png](previews/screenshot_tool.png)

- **Settings** - Super + Shift + S - Quickshell configuration panel

![settings.png](previews/settings.png)

- **Theme Switcher** - Super + T - Visual theme selector

![theme_switcher.png](previews/theme_switcher.png)

- **Wallpaper Picker** - Super + Shift + W - Browse and select wallpapers

![wallpaper_picker.png](previews/wallpaper_picker.png)


### System Integration
- Workspace management with visual indicators
- System tray with audio, network, and updates
- Notification system with urgency-based styling
- GTK theme synchronization
- **Included GTK themes and icons** - Multiple theme-matched GTK themes and icon packs included in quickshell/gtk-themes/ and quickshell/gtk-icons/

## Requirements

### Core Dependencies
```bash
# Install from official repos
sudo pacman -S hyprland kitty mako swww hyprpolkitagent

# Install from AUR (requires yay or paru)
yay -S quickshell-git hyprshot
```

### Required Fonts
The bar and widgets require specific fonts to display icons and text correctly:
```bash
# Nerd Fonts Symbols - Required for all icons in the bar and widgets
sudo pacman -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common

# Maple Mono Nerd Font - Required for text in bar, workspaces, and widgets
yay -S maplemono-nf-unhinted
```

### Optional Applications
```bash
yay -S vesktop-bin vscodium-bin neovim
```

## Documentation

- [Quickshell Configuration Guide](quickshell/README.md)
- [Hyprland Setup](hypr/)
- [Theme Customization](quickshell/README.md#customization)

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
