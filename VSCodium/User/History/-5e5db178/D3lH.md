# Vencord/Vesktop Theme Integration - Quick Setup Guide

## ✅ What's Been Set Up

I've created a system to sync your Hyprland/Quickshell theme colors to Vencord/Vesktop automatically.

### Files Created

1. **`~/.config/quickshell/sync-vencord-theme.sh`** 
   - Main sync script that reads your current theme and generates Vencord CSS

2. **`~/.config/vesktop/themes/QuickshellSync.theme.css`**
   - Auto-generated theme file (currently using TokyoNight colors)

3. **`~/.config/quickshell/VENCORD_THEME_SYNC.md`**
   - Detailed documentation and usage guide

4. **`~/.config/quickshell/vencord-integration.sh`**
   - Integration snippet for your theme switcher

## 🚀 How to Use

### Option 1: Manual Sync (Easiest)

Whenever you want to update Vencord to match your current Quickshell theme:

```bash
~/.config/quickshell/sync-vencord-theme.sh --theme-file
```

Then in Vesktop:
1. Open **Settings** → **Vencord** → **Themes**
2. Enable **"Quickshell Sync (TokyoNight)"** theme
3. Enjoy your synchronized colors!

### Option 2: Auto-Sync with Theme Switcher

Add these lines to your `~/.config/quickshell/switch-theme.sh` (after the Zed sync section):

```bash
# Sync Vencord/Vesktop theme
if [ -f "$HOME/.config/quickshell/sync-vencord-theme.sh" ]; then
    echo "Syncing Vencord theme..."
    "$HOME/.config/quickshell/sync-vencord-theme.sh" --theme-file
    echo ""
fi
```

Now Vencord will automatically update when you switch Quickshell themes!

### Option 3: QuickCSS (Alternative)

If you prefer using QuickCSS instead of a theme file:

```bash
~/.config/quickshell/sync-vencord-theme.sh
```

Then copy the output and paste into **Settings** → **Vencord** → **Edit QuickCSS**

## 📋 Current Setup

- **Current Theme**: TokyoNight (from `settings.json`)
- **Theme Source**: `~/.config/hypr/themes/TokyoNight.conf`
- **Output**: `~/.config/vesktop/themes/QuickshellSync.theme.css`

## 🎨 Color Mapping

Your theme colors are mapped to Discord UI like this:

| Your Theme | Discord UI Element |
|-----------|-------------------|
| `bg-crust` (#0f0f14) | Server list, user panel |
| `bg-mantle` (#16161e) | Sidebar |
| `bg-base` (#1a1b26) | Main chat background |
| `surface-0/1/2` | Buttons, inputs, modals |
| `fg-primary` (#c0caf5) | Main text |
| `accent-blue` (#7aa2f7) | Brand color, links, selections |
| `accent-green` (#9ece6a) | Online status |
| `accent-yellow` (#e0af68) | Warnings |
| `accent-red` (#f7768e) | Errors, DND status |

## 🔧 Script Options

```bash
# Display CSS (default)
~/.config/quickshell/sync-vencord-theme.sh

# Update theme file
~/.config/quickshell/sync-vencord-theme.sh --theme-file

# Update QuickCSS directly
~/.config/quickshell/sync-vencord-theme.sh --quickcss

# Output CSS only (for piping)
~/.config/quickshell/sync-vencord-theme.sh --output
```

## 🔄 Workflow Example

1. Switch to Dracula theme in Quickshell
2. Run: `~/.config/quickshell/sync-vencord-theme.sh --theme-file`
3. Theme file is updated with Dracula colors
4. Open Vesktop - theme updates automatically (may need to disable/re-enable)
5. All your apps now use the same color scheme! ✨

## 📦 Available Themes

All these themes from `~/.config/hypr/themes/` will work:

- ✓ Catppuccin
- ✓ Dracula  
- ✓ Eldritch
- ✓ Everforest
- ✓ Gruvbox
- ✓ Kanagawa
- ✓ Material
- ✓ NightFox
- ✓ Nord
- ✓ RosePine
- ✓ TokyoNight ← Currently active

## 🛠️ Customization

Want to customize how colors are applied? Edit the `CSS_CONTENT` section in `sync-vencord-theme.sh`.

For example, to make the sidebar more transparent:

```bash
# In sync-vencord-theme.sh, find:
--background-secondary: #${bg_mantle};

# Change to:
--background-secondary: #${bg_mantle}cc;  # Add 'cc' for 80% opacity
```

## 📚 More Info

Read the full documentation: `~/.config/quickshell/VENCORD_THEME_SYNC.md`

## 🐛 Troubleshooting

**Theme not showing?**
- Open Vesktop at least once to create config directories
- Check file exists: `ls ~/.config/vesktop/themes/`
- Restart Vesktop

**Colors wrong?**
- Verify current theme: `jq -r '.theme.current' ~/.config/quickshell/settings.json`
- Re-run sync script
- Check theme file exists: `ls ~/.config/hypr/themes/TokyoNight.conf`

**Need help?**
- Check the full guide: `cat ~/.config/quickshell/VENCORD_THEME_SYNC.md`
- Test the script: `~/.config/quickshell/sync-vencord-theme.sh`

---

**Pro Tip**: Create a shell alias for quick access:

```bash
# Add to ~/.zshrc
alias vcs='~/.config/quickshell/sync-vencord-theme.sh --theme-file'
```

Then just type `vcs` to sync your Vencord theme!
