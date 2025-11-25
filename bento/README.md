# Bento Browser Start Page

A beautiful, minimalist browser start page that automatically syncs with your Hyprland theme colors.

## Features

- 🎨 **Auto-syncing colors** - Matches your current Hyprland theme
- 🌓 **Light/Dark mode** - Toggle between inverted color schemes
- ��️ **Weather widget** - Shows current weather and forecast
- ⏰ **Clock and greeting** - Time, date, and personalized greetings
- 🔗 **Quick links** - Customizable shortcuts to your favorite sites
- 📱 **Responsive design** - Looks great on any screen size

## Installation

The Bento start page is automatically installed when you run the YAHR Quickshell installer and choose to install optional components.

### Manual Installation

1. Copy this directory to `~/bento`
2. Set your browser's homepage to: `file:///home/yourusername/bento/index.html`
3. The colors will automatically sync when you switch themes!

## Configuration

Edit `config.js` to customize:
- Your name for greetings
- Quick link buttons and URLs
- Weather location
- Other personal preferences

## Theme Synchronization

The start page uses CSS custom properties that are automatically updated by the `sync-bento-theme.sh` script when you switch themes via the Quickshell theme switcher.

### Color Mapping

**Dark Mode:**
- Background: `bg-base` (dark)
- Cards: `surface-1` (lighter than background)
- Text: `fg-primary` (light)
- Accent: `accent-blue`

**Light Mode (inverted):**
- Background: `fg-primary` (light)
- Cards: `fg-secondary` (darker than background)
- Text: `bg-base` (dark)
- Accent: `accent-blue`

## Credits

Based on the [Bento](https://github.com/migueravila/Bento) project by Miguel Ávila.
Modified for YAHR Quickshell with automatic theme synchronization.
