# YAHR Quickshell Configuration

A comprehensive Quickshell desktop environment for Hyprland with integrated theme switching across multiple applications.

## Features

- 🎨 **Unified Theme System** - Switch themes across Hyprland, Kitty, VSCodium, Vesktop, and more
- 🚀 **Custom Widgets** - Calendar, app launcher, power menu, screenshot tools, settings panel
- 🔔 **Notifications** - Integrated with mako notification daemon
- 🖼️ **Wallpaper Management** - Dynamic wallpaper picker with theme integration
- 📊 **System Monitoring** - Battery, network, audio, system tray, workspace management
- ⌨️ **Keyboard Driven** - Quick access via keybindings for all widgets

## Supported Themes

- Material (Palenight)
- Catppuccin (Mocha)
- Dracula
- Eldritch
- Everforest
- Gruvbox
- Kanagawa
- NightFox
- Nord
- Rosé Pine
- TokyoNight

## Installation

### Prerequisites

```bash
# Required
sudo pacman -S quickshell hyprland kitty mako swww

# Optional (for full theme integration)
yay -S vesktop-bin vscodium-bin
```

### Setup

1. Clone this repository:
```bash
git clone https://github.com/bgibson72/yahr-quickshell.git
```

2. Copy config directories:
```bash
# Backup existing configs
mkdir -p ~/config-backups
cp -r ~/.config/hypr ~/config-backups/
cp -r ~/.config/kitty ~/config-backups/
cp -r ~/.config/quickshell ~/config-backups/ 2>/dev/null || true

# Install new configs
cp -r yahr-quickshell/config/hypr ~/.config/
cp -r yahr-quickshell/config/kitty ~/.config/
cp -r yahr-quickshell/config/mako ~/.config/
cp -r yahr-quickshell/config/quickshell ~/.config/
```

3. Start or restart Hyprland

## Usage

### Keybindings (Super/Mod key)

| Key | Action |
|-----|--------|
| `Super + Enter` | Launch terminal (Kitty) |
| `Super + D` | App launcher |
| `Super + C` | Calendar widget |
| `Super + T` | Theme switcher |
| `Super + N` | Restore last notification |
| `Super + Shift + S` | Screenshot widget |
| `Super + Shift + W` | Wallpaper picker |
| `Super + B` | Browser (Firefox) |
| `Super + Z` | Restart Quickshell |

### Theme Switching

The theme switcher synchronizes colors across:
- Hyprland (borders, colors, window rules)
- Kitty terminal
- Quickshell widgets and bar
- VSCodium editor
- Vesktop (Discord client)
- Zed editor
- Mako notifications
- GTK applications

**To switch themes:**
1. Press `Super + T` to open theme switcher
2. Click on a theme to apply it
3. All applications will update automatically

### Widgets

#### App Launcher
- Access: `Super + D` or click Arch logo in bar
- Fuzzy search for applications
- Launch with Enter or click

#### Calendar
- Access: `Super + C` or click clock in bar
- View month calendar with current date highlighted
- Navigate months, close with ESC

#### Power Menu
- Access: Click power button in bar
- Options: Shutdown, Reboot, Logout, Lock, Sleep

#### Screenshot Widget
- Access: `Super + Shift + S`
- Modes: Selection, Window, Full screen
- Options: Save to file and/or copy to clipboard

#### Settings
- Access: Click gear icon in quick access drawer
- Configure bar transparency
- More settings coming soon

### Notification System (Mako)

Quickshell uses the **mako** notification daemon (separate from quickshell) for handling all desktop notifications. Notifications appear in the top-right corner with custom theming that matches your selected theme.

**Urgency Levels:**
- **Low urgency**: Green border, 3-second auto-dismiss
- **Normal urgency**: Yellow border, 5-second auto-dismiss
- **Critical**: Red border, stays until dismissed

**Keybinding:**
- `Super + N` - Restore last dismissed notification

**Useful Commands:**
```bash
# Dismiss all notifications
makoctl dismiss

# Restore last notification
makoctl restore

# Enable/disable Do Not Disturb mode
makoctl mode -a dnd  # Enable
makoctl mode -r dnd  # Disable

# Reload mako config
makoctl reload

# View notification history
makoctl history
```

**Note:** Mako runs independently and notifications are NOT part of the quickshell bar. See `~/.config/mako/README.md` for detailed mako configuration.

## File Structure

```
quickshell/
├── shell.qml              # Main shell entry point
├── Bar.qml               # Top bar component
├── ThemeManager.qml      # Theme color singleton
├── ThemeSwitcher.qml     # Theme switcher widget
├── settings.json         # User settings (bar config, etc.)
├── themes/               # Quickshell theme definitions
├── scripts/              # Utility scripts
├── switch-theme.sh       # Main theme switching script
└── sync-*-theme.sh       # App-specific theme sync scripts
```

## Customization

### Bar Transparency

Edit `~/.config/quickshell/settings.json`:
```json
{
  "bar": {
    "transparentBackground": false
  },
  "calendar": {
    "events": []
  }
}
```

Or use the Settings widget: click gear icon → toggle transparency

### Theme Colors

Themes are defined in:
- `~/.config/hypr/themes/*.conf` - Hyprland colors
- `~/.config/quickshell/ThemeManager.qml` - Active theme colors
- `~/.config/kitty/themes/*.conf` - Kitty themes

To create a new theme:
1. Add a new `.conf` file in `~/.config/hypr/themes/`
2. Follow the format of existing theme files
3. Theme will appear in theme switcher automatically

### Adding Custom Widgets

1. Create a new `.qml` file in `~/.config/quickshell/`
2. Import in `shell.qml`:
   ```qml
   MyWidget {
       visible: shellRoot.myWidgetVisible
   }
   ```
3. Add toggle keybinding in `hyprland.conf`

## Troubleshooting

### Quickshell won't start
```bash
# Check for errors
quickshell -c ~/.config/quickshell/shell.qml

# Restart
~/.config/quickshell/restart-quickshell.sh
```

### Theme not applying
```bash
# Manually run theme switcher
~/.config/quickshell/switch-theme.sh Material

# Check logs
journalctl --user -xe | grep quickshell
```

### Notifications not showing
```bash
# Check if mako is running
ps aux | grep mako

# Restart mako
killall mako && mako &

# Test notification
notify-send "Test" "Notification test"
```

### Bar not visible
```bash
# Check Hyprland config
grep "exec-once = quickshell" ~/.config/hypr/hyprland.conf

# Restart Hyprland
hyprctl reload
```

## Development

### Running in Development Mode

```bash
# Run with console output
quickshell -c ~/.config/quickshell/shell.qml

# Watch for changes and reload
while true; do quickshell -c ~/.config/quickshell/shell.qml; sleep 1; done
```

### Debugging

- Console logs appear in systemd journal: `journalctl --user -f | grep quickshell`
- QML errors are logged to: `/run/user/1000/quickshell/by-id/*/log.qslog`
- Use `console.log()` in QML files for debugging

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT License - See LICENSE file for details

## Credits

- Built with [Quickshell](https://github.com/outfoxxed/quickshell)
- Designed for [Hyprland](https://hyprland.org/)
- Notification system uses [Mako](https://github.com/emersion/mako)
- Inspired by various tiling WM configurations

## Links

- [Quickshell Documentation](https://outfoxxed.github.io/quickshell/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Theme Gallery](https://github.com/bgibson72/yahr-quickshell/wiki/Themes) (coming soon)

---

**YAHR** - Yet Another Hyprland Rice 🍚
