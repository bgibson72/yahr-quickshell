# Thunar File Manager Configuration

This directory contains Thunar file manager configurations for a consistent look and feel across devices.

## Files Included

- **thunar.xml** - Main Thunar preferences (view settings, zoom, hidden files, etc.)
- **accels.scm** - Keyboard shortcuts and accelerators
- **uca.xml** - Custom Actions (right-click context menu items)

## Installation

### Option 1: Manual Installation (Recommended)

```bash
# Create necessary directories
mkdir -p ~/.config/Thunar
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

# Install Thunar configuration files
cp thunar/accels.scm ~/.config/Thunar/
cp thunar/uca.xml ~/.config/Thunar/
cp thunar/thunar.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/

# Restart Thunar to apply changes
thunar -q
```

### Option 2: Automatic Installation

Run from the repository root:

```bash
./install-thunar-config.sh
```

## Current Settings

Based on the included `thunar.xml`:

- **View**: Icon View (default)
- **Zoom Level**: 150%
- **Show Hidden Files**: Enabled
- **Single Click**: Disabled (double-click to open)
- **Symbolic Icons in Sidebar**: Enabled
- **Shortcuts Icon Size**: 16px
- **Last Window State**: Maximized

## Customization

After installation, you can customize Thunar settings through:
- **Edit → Preferences** in Thunar
- **View** menu for display options
- **Edit → Configure custom actions** for context menu items

Your customizations will be saved to the same files in `~/.config/Thunar/` and `~/.config/xfce4/xfconf/xfce-perchannel-xml/`.

## Backup Current Settings

Before installing, backup your existing Thunar configuration:

```bash
mkdir -p ~/config-backup/thunar
cp -r ~/.config/Thunar/* ~/config-backup/thunar/
cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml ~/config-backup/thunar/
```

## Syncing Settings

To update the repository with your current Thunar settings:

```bash
# From repository root
cp ~/.config/Thunar/* thunar/
cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml thunar/
git add thunar/
git commit -m "Update Thunar configuration"
git push
```
