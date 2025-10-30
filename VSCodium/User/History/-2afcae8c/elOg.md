# Vencord Theme Sync

Automatically sync your Hyprland/Quickshell theme colors to Vencord/Vesktop.

## Overview

This setup allows you to use the same color scheme across your system (Hyprland, Quickshell) and Vencord/Vesktop. When you switch themes in Quickshell, you can regenerate the Vencord theme to match.

## Files

- **`sync-vencord-theme.sh`** - Main sync script
- **`~/.config/vesktop/themes/QuickshellSync.theme.css`** - Auto-generated theme file
- **`~/.config/hypr/themes/*.conf`** - Source theme files (Hyprland format)
- **`settings.json`** - Quickshell settings (contains current theme name)

## Usage

### Quick Start

```bash
# Generate and display CSS
~/.config/quickshell/sync-vencord-theme.sh

# Update the theme file (recommended)
~/.config/quickshell/sync-vencord-theme.sh --theme-file

# Update QuickCSS directly (requires Vesktop restart)
~/.config/quickshell/sync-vencord-theme.sh --quickcss

# Output only CSS (for piping or copying)
~/.config/quickshell/sync-vencord-theme.sh --output
```

### Apply Theme in Vencord

#### Method 1: Theme File (Recommended)

1. Run the sync script with `--theme-file`:
   ```bash
   ~/.config/quickshell/sync-vencord-theme.sh --theme-file
   ```

2. Open Vesktop

3. Go to: **Settings** → **Vencord** → **Themes**

4. Enable **"Quickshell Sync"** theme

5. Theme updates automatically when you re-run the script

#### Method 2: QuickCSS

1. Run the sync script:
   ```bash
   ~/.config/quickshell/sync-vencord-theme.sh
   ```

2. Copy the generated CSS output

3. Open Vesktop

4. Go to: **Settings** → **Vencord** → **Vencord** tab

5. Click **"Edit QuickCSS"**

6. Paste the CSS and save

#### Method 3: Auto-update QuickCSS (Advanced)

```bash
~/.config/quickshell/sync-vencord-theme.sh --quickcss
```

Then restart Vesktop to see changes.

## Integration with Theme Switcher

You can add this to your `switch-theme.sh` script to automatically update Vencord when you switch themes:

```bash
# At the end of switch-theme.sh, add:
~/.config/quickshell/sync-vencord-theme.sh --theme-file
echo "✓ Vencord theme synced"
```

## Available Themes

Your system has these themes available:
- Catppuccin
- Dracula
- Eldritch
- Everforest
- Gruvbox
- Kanagawa
- Material
- NightFox
- Nord
- RosePine
- TokyoNight

Current theme: **TokyoNight** (from `settings.json`)

## Color Mapping

The script maps your Hyprland theme colors to Discord's UI:

| Hyprland Variable | Discord Element |
|------------------|-----------------|
| `bg-crust` | Server list, user panel |
| `bg-mantle` | Sidebar, secondary backgrounds |
| `bg-base` | Main chat area |
| `surface-0/1/2` | Buttons, inputs, cards |
| `fg-primary` | Main text |
| `fg-secondary` | Muted text |
| `accent-blue` | Brand color, links |
| `accent-green` | Positive status |
| `accent-yellow` | Warning status |
| `accent-red` | Danger status |
| `border-0/1/2` | Borders and dividers |

## Customization

To customize the generated CSS, edit `sync-vencord-theme.sh` and modify the `CSS_CONTENT` variable. You can:

- Change which color variables are used
- Add custom CSS rules
- Adjust opacity values
- Target specific Discord elements

### Finding Discord Classes

1. Open DevTools: `Ctrl + Shift + I`
2. Use the Inspect Element tool (top-left corner)
3. Click on any Discord element
4. Find the class name in the DevTools inspector
5. Add custom CSS targeting that class

## Troubleshooting

### Theme not showing up

- Make sure Vesktop has been opened at least once
- Check that the theme file exists: `ls ~/.config/vesktop/themes/`
- Verify Vencord is installed and enabled

### Colors not updating

- Run the script with `--theme-file` flag
- Disable and re-enable the theme in Vencord settings
- Restart Vesktop

### Script errors

- Ensure `jq` is installed: `sudo pacman -S jq`
- Check that theme files exist: `ls ~/.config/hypr/themes/`
- Verify `settings.json` has valid JSON: `jq . ~/.config/quickshell/settings.json`

## Dependencies

- `jq` - JSON processor
- `bash` - Shell
- `sed`, `grep` - Text processing (usually pre-installed)

Install missing dependencies:
```bash
sudo pacman -S jq
```

## Tips

1. **Live Preview**: Keep Vesktop open while running the script to see changes immediately

2. **Backup**: Your original settings are safe - the script only modifies theme files

3. **Per-theme Customization**: Edit individual theme files in `~/.config/hypr/themes/` to adjust colors

4. **Quick Toggle**: Create an alias in your `~/.zshrc`:
   ```bash
   alias vencord-sync='~/.config/quickshell/sync-vencord-theme.sh --theme-file'
   ```

## Advanced: Auto-sync on Theme Change

To automatically update Vencord when you change themes in Quickshell:

```bash
# Add to ~/.config/quickshell/switch-theme.sh
~/.config/quickshell/sync-vencord-theme.sh --theme-file && \
    notify-send "Theme Synced" "Vencord theme updated to $THEME_NAME"
```

## Examples

### Sync to match current Quickshell theme
```bash
~/.config/quickshell/sync-vencord-theme.sh --theme-file
```

### Output CSS for manual editing
```bash
~/.config/quickshell/sync-vencord-theme.sh --output > my-custom-theme.css
```

### Check current theme
```bash
jq -r '.theme.current' ~/.config/quickshell/settings.json
```

---

**Note**: Discord class names may change with updates. If styling breaks, use DevTools to find updated class names and modify the script accordingly.
