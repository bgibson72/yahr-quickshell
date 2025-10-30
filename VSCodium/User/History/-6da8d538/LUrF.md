# YAHR Quickshell - Installation Guide

Complete step-by-step installation guide for YAHR Quickshell.

## 📋 Pre-Installation Checklist

- [ ] Running Arch Linux or Arch-based distro
- [ ] Have `yay` AUR helper installed
- [ ] Have `git` installed
- [ ] Running Hyprland compositor

## 🔧 Step 1: Install Dependencies

### Install all required packages:

```bash
# Core Quickshell
yay -S quickshell-git qt6-base qt6-declarative

# System tools
sudo pacman -S hyprland hyprshot swww python

# Required applications
sudo pacman -S kitty thunar fastfetch pavucontrol \
               networkmanager network-manager-applet

# AUR packages
yay -S nwg-look simple-update-notifier

# Optional but recommended
yay -S gpu-screen-recorder-gui
sudo pacman -S libnotify flatpak
```

## 📥 Step 2: Clone Repository

```bash
cd ~/Downloads  # or wherever you want
git clone https://github.com/bgibson72/yahr-quickshell.git
cd yahr-quickshell
```

## 💾 Step 3: Backup Existing Config

```bash
# Backup current quickshell config if it exists
[ -d ~/.config/quickshell ] && mv ~/.config/quickshell ~/.config/quickshell.backup-$(date +%Y%m%d)

# Backup themes and icons if they exist
[ -d ~/.themes ] && mv ~/.themes ~/.themes.backup-$(date +%Y%m%d)
[ -d ~/.icons ] && mv ~/.icons ~/.icons.backup-$(date +%Y%m%d)
```

## 📦 Step 4: Install Quickshell Config

```bash
# Create directories
mkdir -p ~/.config/quickshell
mkdir -p ~/.themes ~/.icons

# Copy Quickshell configuration
cp -r *.qml scripts themes *.sh *-* settings.json ~/.config/quickshell/

# Make scripts executable
chmod +x ~/.config/quickshell/*.sh
chmod +x ~/.config/quickshell/toggle-*
chmod +x ~/.config/quickshell/scripts/*.sh

echo "✅ Quickshell config installed"
```

## 🎨 Step 5: Install GTK Themes & Icons

```bash
# Install GTK themes
cp -r gtk-themes/* ~/.themes/

# Install icon themes
cp -r gtk-icons/* ~/.icons/

# Update icon cache
for dir in ~/.icons/*/; do
    gtk-update-icon-cache "$dir" 2>/dev/null
done

echo "✅ Themes and icons installed"
```

## ⚙️ Step 6: Configure Hyprland

Add these lines to your `~/.config/hypr/hyprland.conf`:

```bash
cat >> ~/.config/hypr/hyprland.conf << 'EOF'

# ===== YAHR Quickshell Configuration =====

# Auto-start
exec-once = quickshell
exec-once = swww-daemon
exec-once = nm-applet --indicator

# Quickshell widget keybindings
bind = $mainMod, Space, exec, ~/.config/quickshell/toggle-app-launcher
bind = $mainMod, C, exec, ~/.config/quickshell/toggle-calendar
bind = $mainMod, N, exec, ~/.config/quickshell/toggle-notification-center
bind = $mainMod, Escape, exec, ~/.config/quickshell/toggle-power-menu
bind = $mainMod SHIFT, S, exec, ~/.config/quickshell/toggle-screenshot
bind = $mainMod, T, exec, ~/.config/quickshell/toggle-theme-switcher
bind = $mainMod, W, exec, ~/.config/quickshell/toggle-wallpaper-picker

# Screenshot
bind = $mainMod, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots

# Reload Quickshell
bind = $mainMod SHIFT, R, exec, ~/.config/quickshell/restart-quickshell.sh

# ===== End YAHR Quickshell Configuration =====
EOF

echo "✅ Hyprland configured"
```

## 🚀 Step 7: Start Quickshell

```bash
# If Hyprland is already running, start Quickshell:
quickshell &

# Or reload Hyprland:
hyprctl reload
```

## ✅ Step 8: Verify Installation

### Test Quickshell is running:
```bash
pgrep -x quickshell && echo "✅ Quickshell is running" || echo "❌ Quickshell not running"
```

### Test a widget:
```bash
# Try opening the app launcher
~/.config/quickshell/toggle-app-launcher
```

### Test theme switching:
```bash
# Switch to Catppuccin theme
~/.config/quickshell/switch-theme.sh catppuccin-mocha
```

## 🎨 Step 9: Initial Theme Setup

```bash
# Select your GTK theme using nwg-look
nwg-look

# In nwg-look:
# 1. Select a theme (e.g., Catppuccin-Dark)
# 2. Select an icon theme (e.g., Catppuccin-Mocha)
# 3. Click "Apply"
```

## 📸 Step 10: Set Wallpaper

```bash
# Create wallpaper directory
mkdir -p ~/Pictures/Wallpapers

# Add your wallpapers to ~/Pictures/Wallpapers/

# Set wallpaper via widget
# Press Super + W to open wallpaper picker
```

## 🎯 Quick Start Guide

### Common Keybindings:
- `Super + Space` - App Launcher
- `Super + Escape` - Power Menu  
- `Super + C` - Calendar
- `Super + N` - Notification Center
- `Super + T` - Theme Switcher
- `Super + W` - Wallpaper Picker
- `Super + Shift + S` - Screenshot Widget
- `Super + Print` - Quick Screenshot
- `Super + Shift + R` - Reload Quickshell

### Widget Usage:
- **App Launcher**: Type to search, ↑↓ to navigate, Enter to launch
- **Power Menu**: Click or use keyboard (L=Lock, O=Logout, S=Suspend, R=Reboot, P=Shutdown)
- **Theme Switcher**: Click a theme to apply instantly
- **Screenshot**: Choose mode, set delay, save/copy options

## 🔧 Troubleshooting

### Quickshell won't start:
```bash
# Check logs
quickshell  # Run in foreground to see errors
tail -f /run/user/1000/quickshell/by-id/*/log.qslog
```

### Themes don't apply:
```bash
# Verify themes are installed
ls ~/.themes/
ls ~/.icons/

# Re-run theme switch
~/.config/quickshell/switch-theme.sh catppuccin-mocha
```

### Widgets don't open:
```bash
# Check if quickshell is running
pgrep -x quickshell

# Restart quickshell
~/.config/quickshell/restart-quickshell.sh
```

### App launcher shows no apps:
```bash
# Test the script
~/.config/quickshell/scripts/list-apps.sh

# Check permissions
chmod +x ~/.config/quickshell/scripts/list-apps.sh
```

## 📚 Next Steps

- Read the main [README.md](README.md) for detailed feature documentation
- Check [THEMING.md](THEMING.md) for custom theme creation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Join the discussion on GitHub Issues

## 🎉 Enjoy!

You're all set! Enjoy your beautiful YAHR Quickshell setup.

For support, visit: https://github.com/bgibson72/yahr-quickshell/issues
