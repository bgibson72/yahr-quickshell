# Fastfetch Theme Integration

## ✅ Setup Complete!

Your fastfetch is now fully integrated with your Quickshell theme switcher.

## How It Works

### 1. Logo Location
- Logos are stored in: `~/.config/fastfetch/logos/`
- Naming convention: `themename_arch.png` (lowercase, e.g., `gruvbox_arch.png`)
- Current symlink: `~/.config/fastfetch/current-theme-logo.png` → points to active theme logo

### 2. Automatic Theme Detection
- `get-theme-image.sh` reads current theme from `~/.config/quickshell/ThemeManager.qml`
- Converts theme name to lowercase
- Returns path to matching logo: `~/.config/fastfetch/logos/themename_arch.png`

### 3. Automatic Updates

#### ✅ When Kitty Opens:
Your `.zshrc` automatically:
1. Updates the logo symlink to match current theme
2. Runs fastfetch with the correct logo

#### ✅ When You Change Themes via Quickshell:
The theme switcher (`~/.config/quickshell/theme-switcher-quickshell`) automatically:
1. Updates Quickshell colors
2. Updates Hyprland, wofi, kitty, mako, GTK themes
3. Sets theme wallpaper
4. **Updates fastfetch logo symlink** ← NEW!
5. Syncs VSCodium theme

**No manual intervention needed!** The fastfetch logo updates automatically whenever you switch themes.

### 4. Available Themes
All 11 logos are ready:
- ✅ catppuccin_arch.png
- ✅ dracula_arch.png
- ✅ eldritch_arch.png
- ✅ everforest_arch.png
- ✅ gruvbox_arch.png
- ✅ kanagawa_arch.png
- ✅ material_arch.png
- ✅ nightfox_arch.png
- ✅ nord_arch.png
- ✅ rosepine_arch.png
- ✅ tokyonight_arch.png

## Configuration

### Fastfetch Config (`config.jsonc`)
- **Logo type**: `kitty-direct` - Uses Kitty graphics protocol for pixel-perfect images
- **Logo source**: `~/.config/fastfetch/current-theme-logo.png` - Symlink to active theme
- **Width**: 20 characters
- **Aspect ratio**: Preserved automatically
- **Padding**: Right 3, Top 1

### Logo Display Quality
Images display with:
- Full color via Kitty graphics protocol
- Preserved aspect ratio (no stretching)
- Proper alignment with system info
- All icons visible in system info

## Manual Commands

### Update logo for current theme:
```bash
~/.config/fastfetch/update-theme-logo.sh
```

### Run fastfetch:
```bash
ff
```

### Check which logo is currently active:
```bash
ls -l ~/.config/fastfetch/current-theme-logo.png
```

### Check current theme:
```bash
grep 'themeName:' ~/.config/quickshell/ThemeManager.qml
```

## Integration Status

### ✅ Fully Integrated:
- Quickshell theme switcher
- Kitty terminal startup
- Auto-update on theme change
- All 11 theme logos available

### Integration Points:
1. **`~/.config/quickshell/theme-switcher-quickshell`**
   - Line 768-773: Calls `update-theme-logo.sh` after theme change
   
2. **`~/.zshrc`**
   - Runs on Kitty startup: Updates logo + runs fastfetch
   
3. **`~/.config/fastfetch/config.jsonc`**
   - Uses `kitty-direct` protocol with `current-theme-logo.png` symlink

## Testing

Test the full integration:

1. **Change theme via Quickshell:**
   - Click theme button in bar
   - Select a different theme
   - Logo should update automatically

2. **Open new Kitty terminal:**
   ```bash
   # In Kitty terminal
   ff
   ```
   - Should show correct logo for current theme

3. **Manual verification:**
   ```bash
   # Check current theme
   grep 'themeName:' ~/.config/quickshell/ThemeManager.qml
   
   # Check logo symlink matches
   ls -l ~/.config/fastfetch/current-theme-logo.png
   
   # Should point to same theme's logo
   ```

## Troubleshooting

### Logo doesn't update after theme change:
```bash
# Manually run the update
~/.config/fastfetch/update-theme-logo.sh

# Check if script is executable
ls -l ~/.config/fastfetch/update-theme-logo.sh

# Make executable if needed
chmod +x ~/.config/fastfetch/update-theme-logo.sh
```

### Logo appears stretched:
- The config has `preserveAspectRatio: true`
- If still stretched, adjust `width` in `config.jsonc`

### Logo not showing in VSCode terminal:
- VSCode doesn't support Kitty graphics protocol
- Use actual Kitty terminal for image display
- In VSCode, fastfetch will show ASCII fallback

## Files Overview

**Active Scripts:**
- `get-theme-image.sh` - Detects theme → returns logo path
- `update-theme-logo.sh` - Updates symlink to current theme logo
- `run-fastfetch-kitty.sh` - Updates logo + runs fastfetch
- ~~`theme-switcher-hook.sh`~~ - Not needed (integrated directly)

**Config:**
- `config.jsonc` - Fastfetch configuration
- `current-theme-logo.png` - Symlink to active theme logo (auto-updates)

**Logos:**
- `logos/*.png` - All 11 theme logos

**Documentation:**
- `README.md` - General fastfetch info
- `INTEGRATION.md` - This file
- `check-images.sh` - Utility to verify logos
