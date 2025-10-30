# YAHR Configuration Repository

**YAHR** - Yet Another Hyprland Rice 🍚

A complete, theme-synchronized desktop environment configuration for Arch Linux + Hyprland.

## 🎨 Features

- **Unified Theme System**: One command switches themes across all applications
- **11 Beautiful Themes**: Material, Catppuccin, Dracula, Eldritch, Everforest, Gruvbox, Kanagawa, NightFox, Nord, Rosé Pine, TokyoNight
- **Quickshell Desktop Environment**: Custom bar, widgets, and controls
- **Seamless Integration**: Hyprland, Kitty, Neovim, VSCodium, Vesktop, Zed, and more

## 📦 What's Included

### Core Components
- **hypr** - Hyprland window manager configuration with theme system
- **quickshell** - Custom desktop environment (bar, widgets, app launcher)
- **kitty** - Terminal emulator with synced themes
- **mako** - Notification daemon with theme integration

### Optional Applications
- **nvim** - Neovim with AstroNvim configuration
- **VSCodium** - VS Code fork with theme synchronization
- **vesktop** - Discord client (Vencord) with theme sync
- **zed** - Modern text editor

## 🚀 Quick Start

### Prerequisites

```bash
# Core requirements
sudo pacman -S hyprland kitty quickshell mako swww hyprpolkitagent

# Optional applications
yay -S vesktop-bin vscodium-bin zed neovim
```

### Installation

1. **Backup existing configs**:
```bash
mkdir -p ~/config-backups
cp -r ~/.config/hypr ~/config-backups/ 2>/dev/null || true
cp -r ~/.config/kitty ~/config-backups/ 2>/dev/null || true
cp -r ~/.config/quickshell ~/config-backups/ 2>/dev/null || true
```

2. **Clone this repository**:
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git ~/yahr-config
```

3. **Install configurations**:
```bash
cd ~/yahr-config
cp -r config/* ~/.config/
```

4. **Start Hyprland**:
```bash
# If not already running
Hyprland

# Or reload if already running
hyprctl reload
```

## 🎮 Usage

### Keybindings

All keybindings use `Super` (Windows/Mod key):

| Keybinding | Action |
|------------|--------|
| `Super + Enter` | Terminal (Kitty) |
| `Super + D` | App Launcher |
| `Super + C` | Calendar Widget |
| `Super + T` | **Theme Switcher** |
| `Super + N` | Restore Last Notification |
| `Super + Shift + S` | Screenshot Widget |
| `Super + Shift + W` | Wallpaper Picker |
| `Super + B` | Browser (Firefox) |
| `Super + Z` | Restart Quickshell |

### Theme Switching

Press `Super + T` to open the theme switcher and click any theme. Changes apply immediately to:
- Hyprland (borders, colors)
- Quickshell (bar, widgets)
- Kitty terminal
- VSCodium
- Vesktop/Discord
- Zed
- Mako notifications
- GTK applications

### Available Themes

- **Material** (Palenight) - Purple and teal, modern material design
- **Catppuccin** (Mocha) - Warm, pastel comfort
- **Dracula** - Purple and pink vampire chic
- **Eldritch** - Deep purple mystique
- **Everforest** - Calm green forest
- **Gruvbox** - Retro warmth
- **Kanagawa** - Japanese waves theme
- **NightFox** - Deep blue night
- **Nord** - Arctic, bluish elegance
- **Rosé Pine** - Cozy rose tones
- **TokyoNight** - Vibrant Tokyo skyline

## 📁 Repository Structure

```
config/
├── hypr/           # Hyprland configuration
│   ├── hyprland.conf
│   └── themes/     # Theme color definitions
├── kitty/          # Kitty terminal
│   ├── kitty.conf
│   └── themes/
├── mako/           # Notification daemon
│   └── config
├── nvim/           # Neovim (AstroNvim)
├── quickshell/     # Desktop environment
│   ├── shell.qml
│   ├── Bar.qml
│   ├── themes/
│   └── ...
├── vesktop/        # Discord client
│   └── themes/
└── VSCodium/       # VSCodium editor
    └── User/
```

## 🛠️ Customization

### Modify Colors

Edit theme files in each application's `themes/` directory:
- Hyprland: `~/.config/hypr/themes/THEMENAME.conf`
- Kitty: `~/.config/kitty/themes/THEMENAME.conf`

Or modify the active theme in:
- Quickshell: `~/.config/quickshell/ThemeManager.qml`

### Add New Widgets

See `config/quickshell/README.md` for detailed widget development guide.

### Bar Customization

Edit `~/.config/quickshell/settings.json` or use the Settings widget (gear icon in bar).

## 🔧 Troubleshooting

### Quickshell Issues
```bash
# Check for errors
quickshell -c ~/.config/quickshell/shell.qml

# Restart quickshell
~/.config/quickshell/restart-quickshell.sh
```

### Theme Not Applying
```bash
# Manually run theme switch
~/.config/quickshell/switch-theme.sh Material

# Check Hyprland
hyprctl reload
```

### Notifications Not Working
```bash
# Restart mako
killall mako && mako &

# Test
notify-send "Test" "Notification"
```

## 📚 Documentation

- [Quickshell Setup Guide](config/quickshell/README.md)
- [Mako Notification Setup](config/mako/README.md)
- [Neovim Configuration](config/nvim/README.md)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- [Quickshell](https://github.com/outfoxxed/quickshell) - Desktop environment framework
- [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- [Mako](https://github.com/emersion/mako) - Notification daemon
- [AstroNvim](https://github.com/AstroNvim/AstroNvim) - Neovim configuration
- Theme inspirations from various community projects

## 📸 Screenshots

Coming soon! Check out the [Gallery](https://github.com/bgibson72/yahr-quickshell/wiki) for theme screenshots.

---

**Made with ❤️ for the Arch + Hyprland community**
