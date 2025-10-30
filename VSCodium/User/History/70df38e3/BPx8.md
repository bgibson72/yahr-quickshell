# Fastfetch Image Quality Settings

## The Problem
Chafa image quality settings cannot be set in `config.jsonc` - they must be passed as command-line arguments.

## Solutions

### Option 1: Shell Alias (Recommended)
Add this to your `~/.zshrc`:

```bash
alias ff='fastfetch --chafa-canvas-mode TRUECOLOR --chafa-symbols all --chafa-dither-mode diffusion'
```

Then just run `ff` instead of `fastfetch` for high-quality images.

### Option 2: Use the Wrapper Script
Run `~/.config/fastfetch/run-fastfetch.sh` which includes the quality settings.

### Option 3: Always Use Quality Settings
Replace `/usr/bin/fastfetch` with a wrapper script (requires sudo):
```bash
# Create wrapper
sudo mv /usr/bin/fastfetch /usr/bin/fastfetch-original
sudo tee /usr/bin/fastfetch << 'EOF'
#!/bin/bash
exec /usr/bin/fastfetch-original \
    --chafa-canvas-mode TRUECOLOR \
    --chafa-symbols all \
    --chafa-dither-mode diffusion \
    "$@"
EOF
sudo chmod +x /usr/bin/fastfetch
```

## Available Quality Options

### Canvas Mode (--chafa-canvas-mode)
- **TRUECOLOR**: Best quality, full 24-bit color (recommended)
- INDEXED_256: 256 colors
- INDEXED_240: 256 colors, avoiding lower 16
- INDEXED_16: 16 colors
- INDEXED_8: 8 colors

### Symbols (--chafa-symbols)
- **all**: Use all available Unicode characters for best detail
- block: Use block elements only
- border: Use border characters
- space: Use spaces only (color blocks)

### Dither Mode (--chafa-dither-mode)
- **diffusion**: Error diffusion dithering (best for photos)
- ordered: Ordered Bayer dithering
- none: No dithering

### Color Space (--chafa-color-space)
- **rgb**: Standard RGB (recommended for most images)
- din99d: DIN99d color space (better perceptual uniformity)

## Current Config Settings

The `config.jsonc` has:
- `width: 40` - Image width in characters
- `height: 22` - Image height in characters  
- `pipe: false` - Allows images in VSCode terminal

You can adjust width/height in the config, but quality settings must be command-line arguments.

## Recommendation

Use **Option 1** (alias) for the best balance of convenience and quality:
```bash
echo "alias ff='fastfetch --chafa-canvas-mode TRUECOLOR --chafa-symbols all --chafa-dither-mode diffusion'" >> ~/.zshrc
source ~/.zshrc
```
