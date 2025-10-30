# YAHR - Yet Another Hyprland Rice 🍚

Complete Arch Linux + Hyprland desktop configuration with unified theme system.

## Features
- 🎨 11 beautiful themes with instant switching
- 🖥️ Quickshell desktop environment
- ⚡ Synced themes across all apps
- 📦 Ready to use configurations

## Quick Install
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell
# Backup first!
mkdir -p ~/config-backup
cp -r ~/.config/{hypr,kitty,quickshell} ~/config-backup/ 2>/dev/null || true
# Install
cp -r hypr kitty mako nvim quickshell vesktop VSCodium ~/.config/
```

## Included Applications
- **hypr** - Hyprland window manager (+ 11 themes)
- **quickshell** - Custom desktop environment
- **kitty** - Terminal with theme sync
- **mako** - Notification daemon
- **nvim** - Neovim (AstroNvim)
- **VSCodium** - Code editor
- **vesktop** - Discord client

## Quick Start
After installation:
- Press `Super + T` for theme switcher
- Press `Super + D` for app launcher
- Press `Super + C` for calendar

## Documentation
- [Quickshell Guide](quickshell/README.md)
- [Mako Setup](mako/README.md)

## Themes
Material • Catppuccin • Dracula • Eldritch • Everforest • Gruvbox • Kanagawa • NightFox • Nord • Rosé Pine • TokyoNight

---
MIT License • Made with ❤️ for Arch + Hyprland
