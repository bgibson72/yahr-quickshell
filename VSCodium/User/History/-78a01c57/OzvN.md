# Quickshell Troubleshooting Guide

## Common Issues and Solutions

### 1. Quickshell won't start

**Symptoms:** Nothing appears when running `quickshell`

**Solutions:**
```bash
# Check for errors
quickshell 2>&1 | tee ~/quickshell-error.log

# Make sure Waybar isn't running
killall waybar

# Check if the config file exists
ls -la ~/.config/quickshell/shell.qml

# Run with debug output
QT_LOGGING_RULES="quickshell.*=true" quickshell
```

### 2. "Module not found" errors

**Symptoms:** Errors about `Quickshell.Hyprland` or other modules

**Solutions:**
```bash
# Reinstall quickshell-git with all dependencies
yay -S quickshell-git --rebuild

# Check if you're running Hyprland
echo $XDG_CURRENT_DESKTOP

# Try without Hyprland modules first (remove from shell.qml):
# import Quickshell.Hyprland
```

### 3. Icons not showing / Font issues

**Symptoms:** Boxes or missing icons instead of symbols

**Solutions:**
```bash
# Install required fonts
yay -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
# or
yay -S nerd-fonts-complete

# Update font cache
fc-cache -fv

# Check installed fonts
fc-list | grep -i "nerd\|symbol"
```

### 4. Workspace switcher not working

**Symptoms:** WorkspaceBar doesn't show or clicking doesn't switch

**Solutions:**
- Make sure you're running Hyprland
- Check if Hyprland IPC is available:
  ```bash
  ls -la /tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock
  ```
- Verify in Hyprland you have workspaces configured
- Try using `hyprctl dispatch workspace 1` manually

### 5. Bar appears but modules don't update

**Symptoms:** Clock frozen, battery not updating, etc.

**Solutions:**
```bash
# Check if required commands are available
which pactl wpctl checkupdates

# Install missing dependencies
sudo pacman -S pulseaudio pulseaudio-alsa
sudo pacman -S pacman-contrib  # for checkupdates

# Check timer intervals in the QML files
# Look for Timer { interval: ... }
```

### 6. Process.execute() or Process.exec() not working

**Symptoms:** Buttons don't launch apps, scripts don't run

**Solutions:**
- Check command paths: `which kitty firefox nautilus`
- Use full paths: `/usr/bin/kitty` instead of `kitty`
- Check script permissions: `chmod +x ~/.config/waybar/scripts/powermenu.sh`
- Test command in terminal first
- Check Quickshell console output for errors

### 7. High CPU usage

**Symptoms:** Quickshell using excessive CPU

**Solutions:**
- Increase Timer intervals (less frequent updates)
- Use `exec-if` conditions before running heavy commands
- Check for infinite loops in custom code
- Profile with: `QT_LOGGING_RULES="*.debug=true" quickshell`

### 8. Bar not showing on all monitors

**Symptoms:** Bar only appears on primary monitor

**Solutions:**
- Check the Variants block in shell.qml
- Verify: `Variants { model: Quickshell.screens }`
- Test with: `echo $QUICKSHELL_SCREENS`
- Check Hyprland monitor configuration

### 9. Styling/colors not matching

**Symptoms:** Colors look different than expected

**Solutions:**
- Colors in QML use hex format: `#RRGGBB` or `#AARRGGBB`
- Alpha channel is first: `#D91A1B26` = 85% opacity
- Use Qt.rgba() for programmatic colors
- Check theme inheritance in nested components

### 10. Can't click through transparent areas

**Symptoms:** Entire bar blocks mouse even in transparent areas

**Solutions:**
- Set specific component widths/heights
- Use `enabled: false` for non-interactive elements
- Adjust PanelWindow exclusionMode if available
- Check if `hoverEnabled: false` where not needed

## Debugging Commands

```bash
# Check Quickshell version
quickshell --version

# Run with full debug output
QT_LOGGING_RULES="*=true" quickshell 2>&1 | less

# Check QML syntax (requires qt6-tools)
qmllint ~/.config/quickshell/*.qml

# Monitor system calls
strace -e trace=open,read,write quickshell

# Check resource usage
pidof quickshell | xargs ps -p

# Test individual QML components
quickshell -c ~/test.qml
```

## Testing Individual Components

Create a test file to isolate issues:

```qml
// test.qml
import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
        }
        
        width: 200
        height: 42
        color: "#1a1b26"
        
        Text {
            anchors.centerIn: parent
            text: "Test"
            color: "white"
        }
    }
}
```

Run with: `quickshell -c test.qml`

## Getting Help

1. **Quickshell Documentation**: https://quickshell.outfoxxed.me/
2. **GitHub Issues**: https://github.com/outfoxxed/quickshell/issues
3. **Qt QML Documentation**: https://doc.qt.io/qt-6/qmlapplications.html
4. **Hyprland Wiki**: https://wiki.hyprland.org/

## Configuration Validation Checklist

- [ ] Quickshell installed: `which quickshell`
- [ ] Config directory exists: `~/.config/quickshell`
- [ ] shell.qml is present and valid
- [ ] All .qml files use correct imports
- [ ] Font packages installed
- [ ] Waybar is stopped
- [ ] Running on Hyprland (if using Hyprland modules)
- [ ] Scripts are executable
- [ ] Commands in Process.execute() are valid

## Rolling Back to Waybar

If you need to revert:

```bash
# Stop Quickshell
killall quickshell

# Start Waybar
waybar &

# Re-enable in Hyprland config
# Edit ~/.config/hypr/hyprland.conf
# Change: exec-once = quickshell
# To: exec-once = waybar

# Restart Hyprland
hyprctl reload
```

Your Waybar configuration is still intact in `~/.config/waybar`!
