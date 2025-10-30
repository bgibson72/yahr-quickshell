# Pluck - Quick Start Guide

## What You've Built

**Pluck** is a modern GTK4 application written in Rust that extracts color palettes from images. It's designed specifically for Wayland compositors and provides a clean, native Linux experience.

## Features

✨ **Extract Color Palettes**: Automatically extract dominant colors from any image
📋 **Easy Copying**: Copy colors in both HEX (`#RRGGBB`) and RGB (`rgb(r, g, b)`) formats
🎛️ **Adjustable**: Choose between 2-20 colors to extract
🖼️ **Format Support**: PNG, JPEG, WebP, and GIF images
💻 **Native Wayland**: Full support for modern Wayland compositors

## Running the Application

From the project directory:
```bash
cargo run --release
```

Or run the compiled binary directly:
```bash
./target/release/pluck
```

## Usage

1. **Open an Image**
   - Click the "Open Image" button in the header bar
   - Select an image file (PNG, JPEG, WebP, or GIF)
   - Colors will be automatically extracted

2. **Adjust Color Count**
   - Use the number spinner in the top-right corner
   - Range: 2-20 colors
   - The palette updates automatically when changed

3. **Copy Colors**
   - Each color card shows the HEX and RGB values
   - Click "Copy HEX" or "Copy RGB" to copy to clipboard
   - Or select the text directly (it's selectable)

## Project Structure

```
Pluck/
├── src/
│   ├── main.rs              # Application entry point
│   ├── app.rs               # Main UI and logic
│   └── color_extractor.rs   # Color extraction module
├── Cargo.toml               # Rust dependencies
├── style.css                # GTK CSS styling (optional)
└── README.md                # Full documentation
```

## Tech Stack

- **Language**: Rust 🦀
- **GUI Framework**: GTK4 with Relm4 (Elm-inspired architecture)
- **Color Extraction**: color-thief (K-means clustering algorithm)
- **Image Processing**: image crate

## Development

### Build for Development
```bash
cargo build
```

### Build Optimized Release
```bash
cargo build --release
```

### Run Tests
```bash
cargo test
```

### Check Code
```bash
cargo clippy
```

## VS Code/VSCodium Extensions Installed

The following Rust development extensions should now be available:
- **rust-analyzer**: Intelligent code completion and analysis
- **CodeLLDB** or **vadimcn.vscode-lldb**: Debugging support
- **crates**: Manage Cargo dependencies

## Tips

- **Wayland**: The app runs natively on Wayland - no X11 required!
- **Performance**: Release builds are significantly faster than debug builds
- **Clipboard**: The clipboard integration works system-wide
- **Image Quality**: Larger images take longer to process but give better color accuracy

## Customization

You can modify:
- **Color count range**: Edit `SpinButton::with_range()` in `app.rs`
- **Window size**: Adjust `set_default_width` and `set_default_height`
- **Styling**: Modify `style.css` (though GTK4 may not load it automatically - this is for future enhancement)
- **Color card size**: Change `width_request` and `height_request` in `create_color_card()`

## Troubleshooting

**App doesn't start:**
- Make sure GTK4 is installed: `pkg-config --modversion gtk4`
- Check terminal output for error messages

**Colors look wrong:**
- Try adjusting the quality parameter in `color_extractor.rs` (currently set to 10)
- Lower quality = faster but less accurate
- Higher quality = slower but more accurate

**Can't copy to clipboard:**
- Ensure your Wayland compositor supports clipboard protocol
- Try selecting the text manually instead

## Next Steps

Consider adding:
- Command-line interface for batch processing
- Export palette to files (JSON, CSS, SCSS, etc.)
- Image preview in the UI
- Recently used images/palettes
- Custom CSS loading support
- Drag-and-drop image support

## License

MIT License - Feel free to modify and distribute!

---

**Enjoy using Pluck! 🎨**
