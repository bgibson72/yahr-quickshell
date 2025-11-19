# Theme Wallpaper Fetcher

Automatically fetch wallpapers from [Wallhaven.cc](https://wallhaven.cc) that match your theme color palettes.

## Features

- 🎨 Extracts colors from your Hyprland theme files
- 🖼️ Searches Wallhaven for matching wallpapers
- 📁 Organizes wallpapers by theme in `~/Pictures/Themes/`
- 🎯 Focuses on the most distinctive colors from each palette
- 🔄 Supports batch processing for all themes
- ⚡ Skips duplicate downloads

## Installation

The script is already included in `scripts/fetch-theme-wallpapers.sh` and ready to use.

## Usage

### Fetch for a specific theme
```bash
./scripts/fetch-theme-wallpapers.sh Catppuccin 20
```
This will download up to 20 wallpapers per color for the Catppuccin theme.

### Use default count (5 per color)
```bash
./scripts/fetch-theme-wallpapers.sh Dracula
```

### Fetch for all themes
```bash
./scripts/fetch-theme-wallpapers.sh --all 10
```

### List available themes
```bash
./scripts/fetch-theme-wallpapers.sh --list
```

### Show help
```bash
./scripts/fetch-theme-wallpapers.sh --help
```

## Output

Wallpapers are saved to theme-specific directories:
- `~/Pictures/Themes/Catppuccin/`
- `~/Pictures/Themes/Dracula/`
- `~/Pictures/Themes/Nord/`
- etc.

Review the downloaded images and delete any you don't like at your leisure.

## How It Works

1. **Color Extraction**: Reads your theme configuration files from `~/.config/hypr/themes/`
2. **Color Selection**: Picks the top 5 most distinctive colors from each theme
3. **API Search**: Queries Wallhaven API for wallpapers matching each color
4. **Download**: Saves matching wallpapers (minimum 1920x1080 resolution)
5. **Organization**: Stores in theme-specific folders for easy management

## Requirements

- `curl` (already installed on most systems)
- Internet connection
- Wallhaven.cc access (public API, no account needed)

## API Limits

The script is respectful of Wallhaven's API:
- 1 second delay between color searches
- Random sorting to get variety
- Safe for work images only (purity=100)

## Tips

- **First run**: Start with a small number (5-10) to see if you like the results
- **Batch mode**: Use `--all 5` to get a small sample for each theme
- **Cleanup**: Sort through `~/Pictures/Themes/[ThemeName]/` and delete unwanted images
- **Re-run**: The script skips existing files, so you can run it multiple times safely

## Examples

```bash
# Quick test with Catppuccin
./scripts/fetch-theme-wallpapers.sh Catppuccin 5

# Get more wallpapers for your favorite theme
./scripts/fetch-theme-wallpapers.sh Nord 30

# Batch fetch for all themes
./scripts/fetch-theme-wallpapers.sh --all 10
```

## Integration with Wallpaper Picker

Once you have wallpapers downloaded, you can use them with the quickshell wallpaper picker:

1. Copy your favorites to `~/Pictures/Wallpapers/`
2. Open the wallpaper picker: `Super + Shift + W`
3. Browse and select your theme-matched wallpapers!
