# 🔍 Finding and Fixing Black Backgrounds in Vencord

## Quick Steps

### 1. Open DevTools
Press **`Ctrl + Shift + I`** in Vesktop

### 2. Enable Inspect Element Mode
- Click the 🔍 icon in the top-left of DevTools
- Or press **`Ctrl + Shift + C`**

### 3. Click the Black Background
Hover and click on the area that's still showing black

### 4. Find the Class Name
In the Elements panel, look for something like:
```html
<div class="someClass_abc123 anotherClass_def456">
```

The class names end with random characters (e.g., `someClass_abc123`)

### 5. Add It to Your Theme

#### Option A: Quick Test (Temporary)
In DevTools, go to the **Console** tab and paste:

```javascript
document.querySelector('.THE_CLASS_NAME').style.backgroundColor = '#1e2326';
```

Replace `THE_CLASS_NAME` with the class you found. This tests if it works (resets when you reload).

#### Option B: Add to Sync Script (Permanent)

Edit `~/.config/quickshell/sync-vencord-theme.sh` and find this section (around line 145):

```css
/* ===== FORCE APP BACKGROUND (Critical for removing black) ===== */
body,
html,
#app-mount,
.app_bd26cc,
.bg_b02b02,
.wrapper_a7e7a8 {
    background-color: #\${bg_crust} !important;
}
```

**Add your class** to the list:

```css
/* ===== FORCE APP BACKGROUND (Critical for removing black) ===== */
body,
html,
#app-mount,
.app_bd26cc,
.bg_b02b02,
.wrapper_a7e7a8,
.YOUR_NEW_CLASS_HERE {
    background-color: #\${bg_crust} !important;
}
```

#### Option C: Add to Theme File Directly (Quick Fix)

Edit `~/.config/vesktop/themes/QuickshellSync.theme.css` and add:

```css
/* Custom fix for specific black background */
.YOUR_CLASS_NAME_HERE {
    background-color: #1e2326 !important;  /* or whatever your bg-crust color is */
}
```

Add this at the end of the file.

**Note:** Option C will be overwritten next time you run the sync script, so Option B is better for permanent fixes.

## 🎯 Pro Tips

### Tip 1: Check Parent Elements
Sometimes the black background is on a parent element. In DevTools:
- Click the element with black background
- Look at the elements above it in the tree
- Try selecting parent divs to find which one has the black background

### Tip 2: Check Computed Styles
In DevTools, click the **Computed** tab to see:
- What the actual background-color value is
- Which CSS rule is applying it
- Where that rule comes from

### Tip 3: Use the Color Picker
If you find the black background:
1. Click on the color swatch next to `background-color` in DevTools
2. Use the eyedropper to pick your theme color from elsewhere
3. Note the hex color code

### Tip 4: Search for Inline Styles
Some elements have inline styles. Look for:
```html
<div style="background-color: #000000;">
```

These require `!important` to override.

## 🔧 Common Black Background Classes

Based on Discord's current structure, check these areas:

### App Background
```css
.app_bd26cc,
.bg_b02b02,
#app-mount,
body,
html
```

### Layer/Container
```css
.layers_a23c37,
.layer_cd0de5,
.container_fc4f04
```

### Base/Content
```css
.base_a4d4d9,
.content_a4d4d9,
.wrapper_a7e7a8
```

### Chat Area
```css
.chat__52833,
.chatContent__5dca8,
.messagesWrapper_ea2b0b
```

**Note:** Discord changes these class names with every update, so yours might be different!

## 🚀 Example Workflow

Let's say you find the class `.someNewClass_xyz789`:

### Test it:
```javascript
// In DevTools Console
document.querySelector('.someNewClass_xyz789').style.backgroundColor = '#1e2326';
```

### If it works, add permanently:
```bash
# Edit the sync script
nano ~/.config/quickshell/sync-vencord-theme.sh

# Find line 145-152 and add your class:
# .someNewClass_xyz789,

# Save and regenerate theme
~/.config/quickshell/sync-vencord-theme.sh --theme-file

# Reload Vesktop
# Ctrl + R
```

## 📸 DevTools Screenshot Guide

When DevTools is open, you'll see:

```
┌─────────────────────────────────────┐
│  Vesktop Window                     │
│  ┌─────────────────────────────┐   │
│  │ 🔍 ← Click this to inspect  │   │
│  │                             │   │
│  │    Elements | Console       │   │
│  │    ├── html                 │   │
│  │    │  ├── body              │   │
│  │    │     ├── div.app_bd26cc│   │
│  │    │        └── ...         │   │
│  │                             │   │
│  │    Styles →                 │   │
│  │    .app_bd26cc {            │   │
│  │      background: #000000;   │   │
│  │    }                        │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## 🎨 Current Theme Colors Reference

For **Everforest**:
- `bg-crust`: #1e2326 (darkest - app background)
- `bg-mantle`: #272e33 (dark - sidebar)
- `bg-base`: #2b3339 (base - chat area)

Replace any `#000000` or black backgrounds with `#1e2326` (or your current `bg-crust`).

## 🆘 Still See Black?

If you still see black backgrounds after trying the above:

1. **Take a screenshot** with DevTools showing the element
2. **Check if it's actually black** or just very dark theme color
3. **Look for these patterns:**
   - `background-color: #000000` or `#000`
   - `background: black`
   - `background-image` with dark overlay
   - `filter: brightness(0)` or similar

4. **Check transparency:**
   ```css
   background-color: rgba(0, 0, 0, 0.5);  /* Semi-transparent black */
   ```

Would you like me to help you identify a specific black background? Let me know what area of Vesktop is showing black and I can help you find the right class!
