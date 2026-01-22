# SDDM Theme Sync - Issue Fixed

## Problem
The SDDM theme was not updating when switching themes in Quickshell.

## Root Causes
1. **Missing Script**: The `sync-sddm-theme.sh` script was not copied to `~/.config/quickshell/`
   - Script existed in source: `/home/bryan/yahr-quickshell/sddm/sync-sddm-theme.sh`
   - Expected location: `~/.config/quickshell/sync-sddm-theme.sh`
   - The `switch-theme.sh` script was looking for it but couldn't find it

2. **Missing Sudoers Configuration**: The script requires sudo permissions to update SDDM theme files
   - Needs to copy wallpaper to `/usr/share/sddm/themes/yahr-theme/`
   - Needs to update `/usr/share/sddm/themes/yahr-theme/theme.conf`
   - Without sudoers rule, it prompts for password (interrupting automated theme switching)

## Solutions Applied

### ✅ Immediate Fix
1. **Copied sync script to config directory**:
   ```bash
   cp /home/bryan/yahr-quickshell/sddm/sync-sddm-theme.sh ~/.config/quickshell/
   chmod +x ~/.config/quickshell/sync-sddm-theme.sh
   ```
   - Script is now in the correct location
   - Theme switching will now attempt to sync SDDM

### ⚠️ Setup Required (One-Time)
2. **Install sudoers rule for passwordless sync**:
   ```bash
   /home/bryan/yahr-quickshell/sddm/setup-sudoers.sh
   ```
   - This will create `/etc/sudoers.d/sddm-sync-yahr`
   - Allows passwordless `cp` and `tee` to SDDM theme directory
   - Only needs to be run once

### 🔄 Future Protection
3. **Updated install.sh**:
   - Added automatic sudoers setup to the SDDM installation section
   - Future installations will include both the script and sudoers configuration
   - Located at lines 1218-1242 in `install.sh`

## Testing

### Test SDDM Sync Manually
```bash
~/.config/quickshell/sync-sddm-theme.sh
```
- Should sync without password prompt (after running setup-sudoers.sh)
- Outputs current theme name, wallpaper path, and colors
- Success message: "✓ SDDM theme synced successfully!"

### Test SDDM Theme Preview
```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/yahr-theme
```
- Opens SDDM login screen preview
- Should show current theme colors and wallpaper
- Press Ctrl+Alt+F2 to exit test mode

### Test Theme Switching
```bash
~/.config/quickshell/switch-theme.sh catppuccin-mocha
# or any other theme name
```
- Should sync all components including SDDM
- Check console output for "Syncing SDDM theme..." message

## Files Modified

### Source Repository
- ✅ `/home/bryan/yahr-quickshell/install.sh` - Added sudoers setup
- ✅ `/home/bryan/yahr-quickshell/sddm/setup-sudoers.sh` - New standalone setup script

### Config Directory  
- ✅ `~/.config/quickshell/sync-sddm-theme.sh` - Copied from source

### System Files (via setup script)
- ⏳ `/etc/sudoers.d/sddm-sync-yahr` - Run setup-sudoers.sh to create

## Next Steps

1. **Run the sudoers setup** (one-time):
   ```bash
   /home/bryan/yahr-quickshell/sddm/setup-sudoers.sh
   ```

2. **Test the fix**:
   ```bash
   ~/.config/quickshell/switch-theme.sh <theme-name>
   ```

3. **Verify SDDM preview**:
   ```bash
   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/yahr-theme
   ```

## Technical Details

### How It Works
1. `switch-theme.sh` changes the Quickshell theme
2. Calls `sync-sddm-theme.sh` as part of theme sync process
3. `sync-sddm-theme.sh`:
   - Reads current theme from Hyprland config
   - Extracts color values from theme file
   - Gets current wallpaper from `swww`
   - Copies wallpaper to SDDM theme directory (requires sudo)
   - Updates `theme.conf` with colors and wallpaper path (requires sudo)

### Sudoers Configuration
```sudoers
# Allow SDDM theme sync without password
%wheel ALL=(ALL) NOPASSWD: /usr/bin/cp * /usr/share/sddm/themes/yahr-theme/*
%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /usr/share/sddm/themes/yahr-theme/theme.conf
```
- Restricts passwordless access to only SDDM theme operations
- Only allows `cp` to specific directory
- Only allows `tee` to specific config file
- Requires user to be in `wheel` group (standard for Arch Linux)

## Status
- ✅ **Script Location**: Fixed (copied to config directory)
- ⏳ **Sudoers Setup**: Ready to run (execute setup-sudoers.sh)
- ✅ **Install Script**: Updated for future installations
- ✅ **Documentation**: Complete

Date: January 22, 2026
