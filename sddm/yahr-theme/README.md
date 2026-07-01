# YAHR SDDM Theme

A Material Design 3 inspired SDDM theme that perfectly matches the YAHR Quickshell aesthetic.

![YAHR SDDM Theme Preview](preview.png)

## Features

- 🎨 **Material Design 3** - Modern, clean interface with smooth animations
- 🔤 **MapleMono NF Font** - Consistent typography with your Quickshell setup
- 🌈 **Theme Colors** - Matches Material Palenight color scheme
- 🖼️ **Background Support** - Use custom wallpapers or solid colors
- 💨 **Blur Effect** - Optional background blur for better text readability
- 👤 **Avatar Support** - Shows user avatars from AccountsService
- ⏰ **Clock & Date** - Large, readable time display
- 🔒 **Session Selector** - Easy session selection (X11/Wayland)
- ⚡ **Power Controls** - Suspend, reboot, and shutdown buttons
- 🌍 **Customizable** - Extensive theming options via `theme.conf`

## Installation

### Prerequisites

```bash
# Install SDDM
sudo pacman -S sddm

# Install Qt dependencies
sudo pacman -S qt6-declarative qt6-svg qt6-5compat

# Install MapleMono Nerd Font (required)
yay -S ttf-maple  # or maplemono-nf-unhinted
```

### Install Theme

1. Copy the theme to SDDM themes directory:
```bash
sudo cp -r sddm/yahr-theme /usr/share/sddm/themes/
```

2. Enable the theme in SDDM configuration:
```bash
sudo mkdir -p /etc/sddm.conf.d
sudo nano /etc/sddm.conf.d/theme.conf
```

Add the following:
```ini
[Theme]
Current=yahr-theme
```

3. Enable SDDM at boot (if not already):
```bash
sudo systemctl enable sddm.service
```

### Set Custom Background

#### Automatic Theme Sync (Recommended)

Keep your SDDM theme automatically synced with your current Quickshell theme and wallpaper:

```bash
# Run the sync script (from repo root)
./sddm/sync-sddm-theme.sh
```

This will:
- Extract colors from your current Quickshell theme
- Use your current wallpaper from `swww`
- Update the SDDM theme configuration

**Automate on Theme Change:**
Add this to your `~/.config/quickshell/switch-theme.sh` (after the theme switch):
```bash
# Sync SDDM theme with new colors
~/.config/quickshell/sync-sddm-theme.sh
```

#### Manual Configuration

Place your wallpaper in the theme directory and update `theme.conf`:

```bash
# Copy your wallpaper
sudo cp ~/Pictures/Wallpapers/Material/your-wallpaper.jpg /usr/share/sddm/themes/yahr-theme/background.jpg

# Or edit theme.conf to point to a different location
sudo nano /usr/share/sddm/themes/yahr-theme/theme.conf
```

## Customization

All customization is done through `/usr/share/sddm/themes/yahr-theme/theme.conf`. The theme is extensively configurable:

### Colors

```ini
## Match your Quickshell theme colors
ThemeColor="#82aaff"     # Primary accent color
AccentColor="#c792ea"     # Secondary accent
BgBase="#292d3e"          # Base background
BgSurface="#1e2030"       # Surface color (cards)
FgPrimary="#d9d7ce"       # Primary text
FgSecondary="#7d83a1"     # Secondary text
```

### Background

```ini
## Background image
Background="background.jpg"

## Blur radius (0 to disable, 20 recommended)
BackgroundBlur=20
```

### Font

```ini
## Font settings
Font="MapleMono NF"
FontSize=11
TitleFontSize=32
```

### Features

```ini
## Toggle features
EnableAvatars=true
ShowHostname=true
ShowSessionButton=true
ShowPowerButtons=true
```

### Time & Date Format

```ini
## Qt date/time format strings
## See: https://doc.qt.io/qt-6/qml-qtqml-qt.html#formatDateTime-method
TimeFormat="hh:mm"              # 24-hour format
# TimeFormat="h:mm AP"          # 12-hour format
DateFormat="dddd, MMMM d"       # "Monday, November 20"
```

### Translations

Customize any text shown in the interface:

```ini
TranslateLogin="Login"
TranslateLoginFailed="Login Failed"
TranslateUsername="Username"
TranslatePassword="Password"
TranslateSession="Session"
TranslateSuspend="Suspend"
TranslateReboot="Reboot"
TranslateShutdown="Shutdown"
```

## Testing

Preview the theme without logging out:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/yahr-theme
```

## Troubleshooting

### Theme not loading
- Verify Qt6 packages are installed: `pacman -Q qt6-declarative`
- Check SDDM logs: `journalctl -u sddm -b`
- Ensure `metadata.desktop` has `QtVersion=6`

### Font not displaying correctly
- Install MapleMono Nerd Font: `yay -S ttf-maple`
- Check font name: `fc-list | grep -i maple`

### Avatar not showing
- Enable avatars in `theme.conf`: `EnableAvatars=true`
- Place avatar at: `~/.face.icon` or `/var/lib/AccountsService/icons/username.png`
- Set permissions: `setfacl -m u:sddm:x ~/ && setfacl -m u:sddm:r ~/.face.icon`

### Background not showing
- Check file path in `theme.conf`
- Ensure SDDM has read permissions: `sudo chmod 644 /usr/share/sddm/themes/yahr-theme/background.jpg`

## Matching Quickshell Themes

To match the current theme in your Quickshell setup, update the colors in `theme.conf` to match your Hyprland theme colors from `~/.config/hypr/themes/*.conf`.

### Material (Palenight) - Default
```ini
ThemeColor="#82aaff"
AccentColor="#c792ea"
BgBase="#292d3e"
```

### Catppuccin (Mocha)
```ini
ThemeColor="#89b4fa"
AccentColor="#cba6f7"
BgBase="#1e1e2e"
```

### Dracula
```ini
ThemeColor="#bd93f9"
AccentColor="#ff79c6"
BgBase="#282a36"
```

### Nord
```ini
ThemeColor="#88c0d0"
AccentColor="#81a1c1"
BgBase="#2e3440"
```

## Credits

- Built with Qt6 QML
- Designed for [SDDM](https://github.com/sddm/sddm)
- Part of the [YAHR Project](https://github.com/bgibson72/yahr-quickshell)
- Material Design 3 principles
- MapleMono Nerd Font

## License

MIT License - Feel free to customize and share!
