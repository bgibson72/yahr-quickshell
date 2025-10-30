# Mako Notification Setup

## Overview
This directory contains the configuration for mako, the lightweight notification daemon for Wayland compositors. Mako has replaced the custom quickshell notification system.

## What Changed
- **Removed from quickshell:**
  - `NotificationService.qml` (backed up as .bak)
  - `NotificationPopup.qml` (backed up as .bak)
  - `NotificationCenter.qml` (backed up as .bak)
  - `NotificationIndicator.qml` (backed up as .bak)
  - `toggle-notification-center` script integration

- **Added:**
  - Mako notification daemon (installed via pacman)
  - `/home/bryan/.config/mako/config` - mako configuration
  - `exec-once = mako` in hyprland.conf

- **Modified:**
  - `Bar.qml` - removed NotificationIndicator component
  - `shell.qml` - removed NotificationService and notification-related windows
  - `hyprland.conf` - changed Super+N keybind from quickshell toggle to `makoctl restore`

## Configuration
The mako configuration is located at `~/.config/mako/config` and includes:
- Material/Palenight theme matching your quickshell setup
- Positioned at top-right, below the quickshell bar
- Color-coded borders based on urgency (green=low, yellow=normal, red=critical)
- Auto-dismiss timers (3s for low, 5s for normal, none for critical)
- Support for notification actions and icons

## Useful Commands

### Basic Controls
```bash
# Dismiss all notifications
makoctl dismiss

# Dismiss last notification
makoctl dismiss --group

# Restore last dismissed notification
makoctl restore

# Enable/disable Do Not Disturb mode
makoctl mode -a dnd
makoctl mode -r dnd

# List notifications
makoctl list

# Get history
makoctl history
```

### Testing
```bash
# Send a test notification
notify-send "Test" "This is a test notification"

# Send with different urgency levels
notify-send -u low "Low Priority" "This is less important"
notify-send -u normal "Normal" "Standard notification"
notify-send -u critical "Critical!" "This is urgent"

# Send with icon
notify-send -i dialog-information "Info" "With an icon"

# Send with actions
notify-send -A "action1=Yes" -A "action2=No" "Question" "Do you agree?"
```

### Reload Configuration
```bash
# Reload mako after config changes
makoctl reload
```

## Keybindings (in hyprland.conf)
- `Super + N` - Restore last dismissed notification

## Autostart
Mako is automatically started by Hyprland via the `exec-once = mako` line in hyprland.conf.

## Theme Colors
The current configuration uses these Material/Palenight colors:
- Background: #0f111a (with transparency)
- Text: #eeffff
- Border (normal): #82aaff (blue)
- Border (low): #c3e88d (green)
- Border (critical): #ff5370 (red)
- Border (urgent): #ffcb6b (yellow)

To change colors, edit `~/.config/mako/config` and run `makoctl reload`.

## Troubleshooting

### Notifications not showing
```bash
# Check if mako is running
ps aux | grep mako

# If not, start it
mako &

# Check for errors
journalctl --user -u mako -f
```

### Multiple notification daemons
If you see "Failed to acquire service name", another notification daemon is running:
```bash
# Kill all notification daemons
killall dunst mako notify-osd

# Start mako
mako &
```

### Config errors
```bash
# Test config syntax
mako --help

# View current config
makoctl list
```

## Documentation
- Official docs: https://github.com/emersion/mako
- Man page: `man mako` and `man makoctl`
- Configuration: `man 5 mako`
