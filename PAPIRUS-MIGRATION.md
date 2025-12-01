# Migrating to Papirus Icon Theme

## Overview

This guide explains how to migrate from using multiple theme-specific icon packs to a single **Papirus** icon theme with dynamic folder colors.

## Benefits

### Current System (Multiple Icon Themes)
- ❌ Requires 11 different icon theme packages (~1.2 GB total)
- ❌ Each theme stored in `quickshell/gtk-icons/` 
- ❌ More complex maintenance
- ❌ Larger disk footprint

### Papirus System (Single Icon Theme)
- ✅ Single icon theme package (~110 MB)
- ✅ No custom icon storage needed
- ✅ Built-in 25 folder color variants
- ✅ Official package from repos
- ✅ Simpler maintenance
- ✅ 90% disk space savings

## Complexity Assessment

**Migration Difficulty: LOW** 🟢

The migration is straightforward and requires only:
1. Installing Papirus (already done ✓)
2. Creating sync script (done ✓)
3. Updating theme-switcher script (2 line change)
4. Optional: Removing old icon themes

## Color Mapping

Theme-to-folder-color mapping in `sync-papirus-folders.sh`:

| Theme | Folder Color | Rationale |
|-------|--------------|-----------|
| Tokyo Night | `blue` | Signature blue (#7aa2f7) |
| Catppuccin Mocha | `blue` | Blue accent (#89b4fa) |
| Gruvbox Dark | `orange` | Warm orange (#fe8019) |
| Material Palenight | `cyan` | Material cyan |
| Everforest | `green` | Nature green theme |
| Kanagawa | `teal` | Teal/cyan aesthetic |
| Nightfox | `blue` | Blue accent |
| Rose Pine | `pink` | Signature pink |
| Dracula | `magenta` | Purple/magenta |
| Nord | `bluegrey` | Blue-grey palette |
| Eldritch | `violet` | Purple/violet |

Available colors: `adwaita, black, blue, bluegrey, breeze, brown, carmine, cyan, darkcyan, deeporange, green, grey, indigo, magenta, nordic, orange, palebrown, paleorange, pink, red, teal, violet, white, yaru, yellow`

## Migration Steps

### Step 1: Verify Papirus Installation
```bash
pacman -Q papirus-icon-theme
# Should show: papirus-icon-theme 20250501-1
```

### Step 2: Update theme-switcher-quickshell

Edit `quickshell/theme-switcher-quickshell` and replace the icon theme mapping:

**Before:**
```bash
case "$theme_name" in
    "TokyoNight")
        gtk_theme="Tokyonight-Dark"
        icon_theme="Tokyonight-Dark"
        ;;
    "Catppuccin")
        gtk_theme="Catppuccin-Dark"
        icon_theme="Catppuccin-Mocha"
        ;;
    # ... etc for all 11 themes
esac
```

**After:**
```bash
case "$theme_name" in
    "TokyoNight")
        gtk_theme="Tokyonight-Dark"
        icon_theme="Papirus-Dark"
        ;;
    "Catppuccin")
        gtk_theme="Catppuccin-Dark"
        icon_theme="Papirus-Dark"
        ;;
    # ... etc - all use "Papirus-Dark"
esac
```

### Step 3: Add Papirus sync to theme switcher

Add this line to the theme switching section (around line 255):
```bash
# Sync Papirus folder colors
"$QUICKSHELL_DIR/sync-papirus-folders.sh" &
```

### Step 4: Test the Migration

```bash
# Test Papirus sync script
~/.config/quickshell/sync-papirus-folders.sh

# Switch themes to verify
~/.config/quickshell/theme-switcher-quickshell Catppuccin
~/.config/quickshell/theme-switcher-quickshell Gruvbox
```

### Step 5: Deploy to Live Config

```bash
# Copy the sync script
cp ~/Dev/yahr-quickshell/quickshell/sync-papirus-folders.sh ~/.config/quickshell/
chmod +x ~/.config/quickshell/sync-papirus-folders.sh

# Update the theme-switcher
cp ~/Dev/yahr-quickshell/quickshell/theme-switcher-quickshell ~/.config/quickshell/
```

### Step 6 (Optional): Clean Up Old Icon Themes

**⚠️ Only after confirming Papirus works correctly!**

```bash
# Remove old custom icon themes
rm -rf ~/.config/quickshell/gtk-icons/

# Uninstall theme-specific icon packages (if installed via AUR)
# Examples:
yay -R tokyonight-gtk-theme-git
yay -R catppuccin-mocha-gtk-theme-git
# ... etc
```

## Rollback Plan

If you need to revert:

1. Restore old theme-switcher:
```bash
git checkout quickshell/theme-switcher-quickshell
cp ~/Dev/yahr-quickshell/quickshell/theme-switcher-quickshell ~/.config/quickshell/
```

2. Remove Papirus sync call from theme-switcher

3. Restore old icon themes (from backup or git)

## Fine-Tuning Folder Colors

If you want to adjust the color mapping, edit `sync-papirus-folders.sh`:

```bash
case "$theme_name" in
    "gruvbox-dark"|"Gruvbox")
        folder_color="orange"  # Change to "brown", "yellow", etc.
        ;;
esac
```

Test with:
```bash
# Preview available colors
papirus-folders --list

# Test a color manually
papirus-folders -C yellow --theme Papirus-Dark
```

## Advantages Summary

1. **Simplicity**: One icon theme vs. 11 separate themes
2. **Maintenance**: Official package, auto-updates via pacman
3. **Consistency**: All apps use the same high-quality icon set
4. **Flexibility**: 25 color variants for customization
5. **Space**: ~1.1 GB saved on disk
6. **Performance**: Faster icon lookups (single theme cache)

## Compatibility

- ✅ Works with GTK 2/3/4 applications
- ✅ Compatible with all desktop environments
- ✅ Supports both light (Papirus) and dark (Papirus-Dark) variants
- ✅ Includes symbolic icons for system tray
- ✅ Over 5000 application icons

## Recommendation

**Yes, migrate to Papirus.** The complexity is minimal (just 2 file changes + 1 new script), and the benefits are substantial. The current multi-theme approach was necessary when you didn't have a good folder color option, but Papirus solves that elegantly.
