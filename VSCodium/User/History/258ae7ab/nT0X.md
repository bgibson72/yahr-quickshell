# Fastfetch Theme-Aware Images - Setup Guide

## Current Status

✅ **Theme detection is working!** Fastfetch now displays your current theme (Eldritch).

⚠️ **Image display requires additional setup** - Follow the steps below.

---

## Option 1: Using the Wrapper Script (Recommended)

The easiest way to get theme-aware images is to use the provided wrapper script.

### Step 1: Install chafa (for image rendering)

```bash
sudo pacman -S chafa
```

### Step 2: Use the wrapper script

Instead of running `fastfetch`, run:

```bash
~/.config/fastfetch/run-fastfetch.sh
```

###Step 3: Create an alias (optional)

Add to your `~/.zshrc`:

```bash
alias ff='~/.config/fastfetch/run-fastfetch.sh'
# OR replace fastfetch entirely:
alias fastfetch='~/.config/fastfetch/run-fastfetch.sh'
```

Then reload: `source ~/.zshrc`

---

## Option 2: Manual Command (Testing)

After installing chafa, you can test with:

```bash
fastfetch --chafa ~/.config/fastfetch/images/Eldritch/Eldritch.png --logo-width 40 --logo-height 20
```

---

## Option 3: Kitty Terminal Protocol

If you're using Kitty terminal:

1. Make sure you're running fastfetch from within Kitty
2. Set your TERM variable: `export TERM=xterm-kitty`
3. Run:
```bash
fastfetch --kitty ~/.config/fastfetch/images/Eldritch/Eldritch.png --logo-width 30 --logo-height 15
```

---

## Why Images Don't Work in config.jsonc

Fastfetch's JSON configuration doesn't support dynamic command substitution (like `$(command)`). 

**Solutions:**
1. Use the wrapper script (`run-fastfetch.sh`) which dynamically detects your theme
2. Create a shell alias/function that runs the wrapper
3. Manually update the config file when you change themes (not recommended)

---

## Testing

After installing chafa, test the wrapper script:

```bash
~/.config/fastfetch/run-fastfetch.sh
```

You should see your Eldritch.png image displayed!

---

## Troubleshooting

### "Command not found: chafa"
Install it: `sudo pacman -S chafa`

### Image doesn't display
- Make sure the image exists: `ls -la ~/.config/fastfetch/images/Eldritch/Eldritch.png`
- Try running the script directly: `~/.config/fastfetch/get-theme-image.sh`
- Check that chafa is installed: `which chafa`

### Wrong theme detected
- Check ThemeManager.qml: `grep themeName ~/.config/quickshell/ThemeManager.qml`
- Verify the theme directory exists with matching capitalization

---

## Files Created

- `config.jsonc` - Main fastfetch config (uses default ASCII logo)
- `get-theme-image.sh` - Detects current theme and returns image path
- `run-fastfetch.sh` - Wrapper script that runs fastfetch with theme image
- `check-images.sh` - Check status of all theme images

---

## Current Theme

Your current theme is: **Eldritch**
Image location: `~/.config/fastfetch/images/Eldritch/Eldritch.png`

Run `./check-images.sh` to see the status of all theme images.
