#!/bin/bash

# YAHR Quickshell Configuration Installer
# This script installs the complete Hyprland + Quickshell setup

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to backup existing configs
backup_config() {
    local config_path="$1"
    if [ -d "$config_path" ] || [ -f "$config_path" ]; then
        local backup_path="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing config: $config_path -> $backup_path"
        mv "$config_path" "$backup_path"
        print_success "Backup created"
        return 0
    fi
    return 1
}

# Function to install a config directory
install_config() {
    local source_dir="$1"
    local target_dir="$2"
    local config_name="$3"
    
    print_info "Installing $config_name..."
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target_dir")"
    
    # Backup existing config if it exists
    backup_config "$target_dir"
    
    # Copy the config
    cp -r "$source_dir" "$target_dir"
    print_success "$config_name installed to $target_dir"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=()
    local optional_deps=()
    
    # Required dependencies
    if ! command_exists "quickshell"; then
        missing_deps+=("quickshell")
    fi
    
    if ! command_exists "hyprctl"; then
        missing_deps+=("hyprland")
    fi
    
    # Optional but recommended dependencies
    if ! command_exists "kitty"; then
        optional_deps+=("kitty - terminal emulator")
    fi
    
    if ! command_exists "mako"; then
        optional_deps+=("mako - notification daemon")
    fi
    
    if ! command_exists "fastfetch"; then
        optional_deps+=("fastfetch - system info")
    fi
    
    if ! command_exists "starship"; then
        optional_deps+=("starship - shell prompt")
    fi
    
    if ! command_exists "wofi"; then
        optional_deps+=("wofi - application launcher")
    fi
    
    # Report missing required dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        print_info "Please install the missing dependencies and run this script again."
        exit 1
    fi
    
    print_success "All required dependencies found"
    
    # Report missing optional dependencies
    if [ ${#optional_deps[@]} -gt 0 ]; then
        print_warning "Missing optional dependencies:"
        for dep in "${optional_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        print_info "The setup will work without these, but some features may be missing."
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Main installation function
install_configs() {
    print_header "Installing Configurations"
    
    # Install Quickshell configs
    if [ -d "$SCRIPT_DIR/quickshell" ]; then
        install_config "$SCRIPT_DIR/quickshell" "$HOME/.config/quickshell" "Quickshell"
        
        # Make scripts executable
        if [ -d "$HOME/.config/quickshell/scripts" ]; then
            chmod +x "$HOME/.config/quickshell/scripts/"*.sh 2>/dev/null || true
        fi
        chmod +x "$HOME/.config/quickshell/"*.sh 2>/dev/null || true
        chmod +x "$HOME/.config/quickshell/theme-switcher-quickshell" 2>/dev/null || true
        chmod +x "$HOME/.config/quickshell/wallpaper-picker" 2>/dev/null || true
        chmod +x "$HOME/.config/quickshell/toggle-"* 2>/dev/null || true
    fi
    
    # Install Hyprland configs
    if [ -d "$SCRIPT_DIR/hypr" ]; then
        install_config "$SCRIPT_DIR/hypr" "$HOME/.config/hypr" "Hyprland"
    fi
    
    # Install Kitty configs
    if [ -d "$SCRIPT_DIR/kitty" ]; then
        install_config "$SCRIPT_DIR/kitty" "$HOME/.config/kitty" "Kitty"
    fi
    
    # Install Mako configs
    if [ -d "$SCRIPT_DIR/mako" ]; then
        install_config "$SCRIPT_DIR/mako" "$HOME/.config/mako" "Mako"
        chmod +x "$HOME/.config/mako/"*.sh 2>/dev/null || true
    fi
    
    # Install Fastfetch configs
    if [ -d "$SCRIPT_DIR/fastfetch" ]; then
        install_config "$SCRIPT_DIR/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
        chmod +x "$HOME/.config/fastfetch/"*.sh 2>/dev/null || true
    fi
    
    # Install Wofi configs
    if [ -d "$SCRIPT_DIR/wofi" ]; then
        install_config "$SCRIPT_DIR/wofi" "$HOME/.config/wofi" "Wofi"
    fi
    
    # Install Wallpapers
    if [ -d "$SCRIPT_DIR/Pictures/Wallpapers" ]; then
        print_info "Installing wallpapers..."
        mkdir -p "$HOME/Pictures"
        
        if [ -d "$HOME/Pictures/Wallpapers" ]; then
            print_warning "Wallpapers directory already exists at $HOME/Pictures/Wallpapers"
            read -p "Merge wallpapers with existing collection? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp -rn "$SCRIPT_DIR/Pictures/Wallpapers/"* "$HOME/Pictures/Wallpapers/"
                print_success "Wallpapers merged (existing files preserved)"
            fi
        else
            cp -r "$SCRIPT_DIR/Pictures/Wallpapers" "$HOME/Pictures/"
            print_success "Wallpapers installed to $HOME/Pictures/Wallpapers"
        fi
    fi
    
    # Install Nvim configs (optional)
    if [ -d "$SCRIPT_DIR/nvim" ]; then
        read -p "Install Neovim configuration? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_config "$SCRIPT_DIR/nvim" "$HOME/.config/nvim" "Neovim"
        fi
    fi
    
    # Install Vesktop configs (optional)
    if [ -d "$SCRIPT_DIR/vesktop" ]; then
        read -p "Install Vesktop (Discord) configuration? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_config "$SCRIPT_DIR/vesktop" "$HOME/.config/vesktop" "Vesktop"
        fi
    fi
}

# Install Starship config
install_starship() {
    print_header "Installing Starship Configuration"
    
    if [ ! -f "$SCRIPT_DIR/dotfiles/starship.toml" ]; then
        print_warning "Starship config not found in repo, skipping..."
        return
    fi
    
    print_info "Installing Starship config..."
    mkdir -p "$HOME/.config"
    
    # Backup existing starship.toml
    backup_config "$HOME/.config/starship.toml"
    
    cp "$SCRIPT_DIR/dotfiles/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship config installed to $HOME/.config/starship.toml"
}

# Install Firefox userChrome
install_firefox() {
    print_header "Firefox userChrome.css Setup"
    
    if [ ! -f "$SCRIPT_DIR/firefox/userChrome.css" ]; then
        print_warning "Firefox userChrome.css not found in repo, skipping..."
        return
    fi
    
    read -p "Install Firefox userChrome.css theme? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Try to find Firefox profile directory
    local firefox_profiles_dir=""
    if [ -d "$HOME/.mozilla/firefox" ]; then
        firefox_profiles_dir="$HOME/.mozilla/firefox"
    elif [ -d "$HOME/snap/firefox/common/.mozilla/firefox" ]; then
        firefox_profiles_dir="$HOME/snap/firefox/common/.mozilla/firefox"
    fi
    
    if [ -z "$firefox_profiles_dir" ]; then
        print_warning "Firefox profile directory not found."
        print_info "You can manually copy firefox/userChrome.css to your Firefox profile's chrome/ directory later."
        return
    fi
    
    # Find default profile
    local profile_dir=$(find "$firefox_profiles_dir" -maxdepth 1 -type d -name "*.default*" | head -n 1)
    
    if [ -z "$profile_dir" ]; then
        print_warning "No Firefox profile found."
        print_info "You can manually copy firefox/userChrome.css to your Firefox profile's chrome/ directory later."
        return
    fi
    
    print_info "Found Firefox profile: $profile_dir"
    mkdir -p "$profile_dir/chrome"
    
    backup_config "$profile_dir/chrome/userChrome.css"
    
    cp "$SCRIPT_DIR/firefox/userChrome.css" "$profile_dir/chrome/userChrome.css"
    print_success "Firefox userChrome.css installed"
    print_info "Remember to:"
    echo "  1. Go to about:config in Firefox"
    echo "  2. Set toolkit.legacyUserProfileCustomizations.stylesheets to true"
    echo "  3. Set theme to 'Default' in Firefox settings"
    echo "  4. Restart Firefox"
}

# Install GTK themes
install_gtk_themes() {
    print_header "GTK Theme Setup"
    
    print_info "Setting up GTK theme directories..."
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.icons"
    
    print_info "Common GTK themes that work well with this setup:"
    echo "  - Everforest-Dark (GTK theme)"
    echo "  - Gruvbox-Dark (GTK theme)"
    echo "  - Catppuccin-Mocha (GTK theme)"
    echo "  - Papirus-Dark (Icon theme)"
    echo ""
    print_info "Install these themes from your distribution's package manager or AUR."
    print_info "The theme switcher will automatically update GTK apps to match your Quickshell theme."
}

# Post-installation setup
post_install() {
    print_header "Post-Installation Setup"
    
    print_info "Setting up executable permissions..."
    find "$HOME/.config/quickshell" -type f -name "*.sh" -exec chmod +x {} \;
    find "$HOME/.config/mako" -type f -name "*.sh" -exec chmod +x {} \;
    find "$HOME/.config/fastfetch" -type f -name "*.sh" -exec chmod +x {} \;
    
    print_success "Setup complete!"
    
    echo ""
    print_info "Next steps:"
    echo "  1. Log out and log back into Hyprland"
    echo "  2. Quickshell should start automatically"
    echo "  3. Use Super+T to open the theme switcher"
    echo "  4. Use Super+A to open the app launcher"
    echo "  5. Use Super+Shift+E to open the power menu"
    echo ""
    print_info "Key bindings:"
    echo "  Super+Q          - Close window"
    echo "  Super+Return     - Terminal (Kitty)"
    echo "  Super+E          - File manager"
    echo "  Super+A          - App launcher"
    echo "  Super+T          - Theme switcher"
    echo "  Super+Shift+E    - Power menu"
    echo "  Super+P          - Screenshot menu"
    echo "  Super+S          - Settings widget"
    echo "  Super+C          - Calendar widget"
    echo "  Super+W          - Wallpaper picker"
    echo ""
}

# Main installation flow
main() {
    print_header "YAHR Quickshell Installation"
    
    echo "This script will install the complete Hyprland + Quickshell setup."
    echo "Your existing configurations will be backed up with timestamps."
    echo ""
    print_warning "Installation will modify configs in: $HOME/.config/"
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi
    
    # Run installation steps
    check_dependencies
    install_configs
    install_starship
    install_firefox
    install_gtk_themes
    post_install
    
    echo ""
    print_success "Installation complete! Enjoy your new setup! 🚀"
}

# Run main function
main
