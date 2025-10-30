# Mako Notification Configuration

## Overview
Mako is the lightweight notification daemon used by this Hyprland configuration. Notifications appear in the top-right corner with custom theming.

## Configuration
The mako configuration is located at `~/.config/mako/config` and includes:
- Custom theme colors that complement the desktop theme
- Positioned at top-right corner, below the bar
- Color-coded borders based on urgency:
  - **Low**: Green border, 3-second auto-dismiss
  - **Normal**: Yellow border, 5-second auto-dismiss
  - **Critical**: Red border, stays until dismissed
- Support for notification actions and icons
- Max 5 visible notifications at once

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
