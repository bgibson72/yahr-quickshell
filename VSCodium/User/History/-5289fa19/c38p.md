# Quickshell to Mako Notification Migration - Summary

## Date: October 30, 2025

## What Was Done

### 1. Installed Mako
- Installed `mako` notification daemon via pacman
- Created configuration at `~/.config/mako/config`
- Theme matches Material/Palenight color scheme

### 2. Removed Quickshell Notification Components
The following files were backed up (renamed to .bak) and removed from active use:
- `NotificationService.qml` → `NotificationService.qml.bak`
- `NotificationPopup.qml` → `NotificationPopup.qml.bak`
- `NotificationCenter.qml` → `NotificationCenter.qml.bak`
- `NotificationIndicator.qml` → `NotificationIndicator.qml.bak`

### 3. Modified Core Files

#### `shell.qml`
- Removed `NotificationService` component initialization
- Removed `notificationService` property
- Removed `notificationCenterVisible` property
- Removed `dndEnabled` property
- Removed `toggleNotificationCenter()` function
- Removed notification center IPC watcher (`notificationCenterWatcher`)
- Removed notification center popup window (Variants section)
- Removed notification popups window (Variants section)
- Removed notification-related connections in Bar section

#### `Bar.qml`
- Removed `notificationService` required property
- Removed `dndEnabled` property
- Removed `notificationComponent` alias
- Removed `NotificationIndicator` component from the right section
- Removed debug log for notification service

#### `hyprland.conf`
- Added `exec-once = mako` to autostart section
- Changed keybinding: `Super+N` now executes `makoctl restore` instead of quickshell toggle

### 4. Created New Files
- `~/.config/mako/config` - Mako configuration file
- `~/.config/mako/README.md` - Comprehensive documentation
- `~/.config/mako/mako-control.sh` - Helper script for common mako operations

## Current Status

✅ Mako is installed and running
✅ Quickshell loads without errors
✅ Notifications are handled by mako
✅ Theme matches existing quickshell aesthetic
✅ All backup files preserved

## Key Features of New Setup

### Mako Configuration
- **Position**: Top-right corner (12px margins, 50px from top to clear bar)
- **Size**: 400px wide, up to 150px tall per notification
- **Max visible**: 5 notifications at once
- **Theme**: Material/Palenight colors matching quickshell

### Urgency Levels
- **Low**: Green border (#c3e88d), 3-second timeout
- **Normal**: Yellow border (#ffcb6b), 5-second timeout
- **Critical**: Red border (#ff5370), no timeout (stays until dismissed)

### Controls
- **Left click**: Invoke default action
- **Middle click**: None
- **Right click**: Dismiss notification
- **Super+N**: Restore last dismissed notification

## Testing Performed

1. ✅ Mako starts without errors
2. ✅ Test notifications display correctly
3. ✅ Quickshell restarts without errors
4. ✅ Bar displays correctly without notification indicator
5. ✅ No reference errors in quickshell logs

## Next Steps (Optional)

### If you want to customize further:
1. Edit `~/.config/mako/config` to change colors, position, or behavior
2. Run `makoctl reload` to apply changes
3. Use `~/.config/mako/mako-control.sh` for quick common operations

### If you want to add a notification indicator back:
You could create a simple script that:
- Runs `makoctl list | wc -l` to count notifications
- Displays the count in a custom widget
- Calls `makoctl restore` when clicked

### If you experience issues:
1. Check if mako is running: `ps aux | grep mako`
2. Restart mako: `killall mako && mako &`
3. Check logs: `journalctl --user -xe | grep mako`
4. Restore quickshell notifications by renaming .bak files back

## Files to Keep

### Critical - Do Not Delete
- `/home/bryan/.config/mako/config`
- `/home/bryan/.config/quickshell/shell.qml`
- `/home/bryan/.config/quickshell/Bar.qml`
- `/home/bryan/.config/hypr/hyprland.conf`

### Backup - Can Delete If Sure
- `/home/bryan/.config/quickshell/NotificationService.qml.bak`
- `/home/bryan/.config/quickshell/NotificationPopup.qml.bak`
- `/home/bryan/.config/quickshell/NotificationCenter.qml.bak`
- `/home/bryan/.config/quickshell/NotificationIndicator.qml.bak`

## Rollback Instructions

If you need to revert to quickshell notifications:

1. Restore backed up files:
   ```bash
   cd ~/.config/quickshell
   mv NotificationService.qml.bak NotificationService.qml
   mv NotificationPopup.qml.bak NotificationPopup.qml
   mv NotificationCenter.qml.bak NotificationCenter.qml
   mv NotificationIndicator.qml.bak NotificationIndicator.qml
   ```

2. Git revert the changes to shell.qml and Bar.qml:
   ```bash
   cd ~/.config/quickshell
   git diff shell.qml  # Review changes
   git checkout HEAD -- shell.qml Bar.qml
   ```

3. Remove mako from hyprland.conf
4. Stop mako: `killall mako`
5. Restart quickshell: `~/.config/quickshell/restart-quickshell.sh`

---

Migration completed successfully! 🎉
