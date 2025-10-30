# Vencord Theme Not Updating? Here's Why

## The Issue

The Vencord theme file (`QuickshellSync.theme.css`) **has been updated** with your new theme colors (Everforest), but Vesktop/Discord needs to **reload** the theme to see the changes.

## ✅ Current Status

- **Quickshell Theme**: Everforest ✓
- **Theme File Updated**: Yes ✓ (as of $(date))
- **Vencord Needs**: Reload to see changes

## 🔄 How to Apply Updated Theme

### Option 1: Toggle the Theme (Fastest)

1. Open Vesktop
2. Go to **Settings** → **Vencord** → **Themes**
3. **Disable** "Quickshell Sync (Everforest)"
4. **Enable** it again
5. Colors should now be Everforest! 🌲

### Option 2: Restart Vesktop

Simply close and reopen Vesktop completely.

### Option 3: Reload Discord

Press `Ctrl + R` in Vesktop to reload (like refreshing a webpage)

## 🔧 How the Workflow Should Be

When you switch themes using Quickshell:

1. **Change theme in Quickshell settings** (or run `switch-theme.sh`)
2. **The sync script runs automatically** (already integrated!)
3. **Theme file gets updated** with new colors
4. **Reload Vencord** to see changes (manual step for now)

## 💡 Why the Filename Stays the Same

The theme file is intentionally named `QuickshellSync.theme.css` (static name) so that:
- ✅ You only need to enable the theme **once** in Vencord
- ✅ Theme updates just require a reload, not re-enabling
- ✅ No multiple theme files cluttering your themes folder

The **theme name** in Vencord's UI shows the current theme (e.g., "Quickshell Sync (Everforest)").

## 🚀 Quick Test

Run this to verify everything is working:

\`\`\`bash
# Check current theme
echo "Current theme: $(jq -r '.theme.current' ~/.config/quickshell/settings.json)"

# Sync to Vencord
~/.config/quickshell/sync-vencord-theme.sh --theme-file

# Check theme file header
head -5 ~/.config/vesktop/themes/QuickshellSync.theme.css
\`\`\`

## 📋 Integration with switch-theme.sh

Your `switch-theme.sh` already includes Vencord sync! When you run:

\`\`\`bash
~/.config/quickshell/switch-theme.sh everforest
\`\`\`

It automatically:
1. ✓ Switches Quickshell theme
2. ✓ Syncs Zed theme
3. ✓ Syncs Vencord theme ← Already happening!
4. Then you just reload Vencord

## 🎯 Current Theme Colors

Your Everforest theme is now using:
- **Background**: #1e2326 (dark green-gray)
- **Sidebar**: #272e33 (medium green-gray)
- **Chat**: #2b3339 (light green-gray)
- **Accent**: #a7c080 (forest green)

Compare this to TokyoNight which had blues (#7aa2f7) and darker backgrounds (#1a1b26).

## 🔄 Future: Auto-Reload (Advanced)

If you want Vencord to auto-reload when you switch themes, you could:

1. Add a notification to remind you:
\`\`\`bash
# In switch-theme.sh, after the Vencord sync:
notify-send "Theme Updated" "Reload Vesktop (Ctrl+R) to see Vencord changes"
\`\`\`

2. Or use a more advanced approach with Vencord's IPC (if available)

---

**Quick Fix Right Now**: Press `Ctrl + R` in Vesktop or toggle the theme off/on!
