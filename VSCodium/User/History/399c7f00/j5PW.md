# Pluck - Color Palette Extractor

A simple GTK4 application for extracting color palettes from images, written in Rust.

## Features

- 🎨 Extract color palettes from images
- 📋 Copy colors in HEX or RGB format
- 🎯 Adjustable number of colors (2-20)
- 🖼️ Support for PNG, JPEG, WebP, and GIF images
- 💻 Native Wayland support via GTK4

## Requirements

### System Dependencies

You need GTK4 development libraries installed:

**Arch Linux / Manjaro:**
```bash
sudo pacman -S gtk4 rust
```

**Ubuntu / Debian:**
```bash
sudo apt install libgtk-4-dev build-essential
```

**Fedora:**
```bash
sudo dnf install gtk4-devel rust cargo
```

## Building

```bash
cargo build --release
```

## Running

```bash
cargo run --release
```

Or after building:
```bash
./target/release/pluck
```

## Usage

1. Click "Open Image" to select an image file
2. The color palette will be automatically extracted
3. Adjust the number of colors using the spin button in the header
4. Click on color values to select them, or use the Copy buttons
5. Colors are copied to your clipboard for easy use

## Architecture

- **GUI Framework**: GTK4 with Relm4 (Elm-inspired architecture)
- **Color Extraction**: color-thief library (Rust port)
- **Image Handling**: image crate for loading various formats

## License

MIT
