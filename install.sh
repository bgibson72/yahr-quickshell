#!/bin/bash

# YAHR Quickshell Configuration Installer
# This script installs the complete Hyprland + Quickshell setup

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation mode (full or minimal)
INSTALL_MODE="full"

# YOLO mode - unattended installation (auto-answer all prompts)
YOLO_MODE=false

# Track what gets installed for summary
declare -a INSTALLED_COMPONENTS=()
declare -a SKIPPED_COMPONENTS=()

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

print_step() {
    echo -e "${CYAN}→${NC} $1"
}

print_step() {
    echo -e "${CYAN}→${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a config directory (no prompts, just overwrite)
install_config() {
    local source_dir="$1"
    local target_dir="$2"
    local config_name="$3"
    
    print_step "Installing $config_name..."
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target_dir")"
    
    # Remove existing config and copy new one
    rm -rf "$target_dir"
    cp -r "$source_dir" "$target_dir"
    print_success "$config_name installed"
    INSTALLED_COMPONENTS+=("$config_name")
}

# Check if running as root (we shouldn't be)
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Do not run this script as root or with sudo"
        print_info "The script will request sudo access when needed"
        exit 1
    fi
}

# Pre-flight check - show what will be installed
preflight_check() {
    print_header "Pre-Flight Check"
    
    print_info "Installation mode: $INSTALL_MODE"
    echo ""
    
    # Detect and show GPU info
    print_info "Detecting GPU hardware..."
    local gpu_info=$(lspci | grep -E "VGA|3D|Display")
    if [ -n "$gpu_info" ]; then
        echo "$gpu_info" | while read -r line; do
            echo "  + $line"
        done
    else
        echo "  - No GPU detected"
    fi
    echo ""
    
    print_info "The following will be installed/configured:"
    echo ""
    
    # GPU and graphics stack
    echo "[*] Graphics Stack:"
    echo "  + GPU drivers (auto-detected)"
    echo "  + Mesa & Vulkan libraries"
    echo "  + Wayland & XWayland"
    echo "  + Qt5/Qt6 Wayland support"
    echo ""
    
    # Core components (always installed)
    echo "[*] Core Components:"
    [ -d "$SCRIPT_DIR/quickshell" ] && echo "  + Quickshell configuration"
    [ -d "$SCRIPT_DIR/hypr" ] && echo "  + Hyprland configuration"
    [ -d "$SCRIPT_DIR/kitty" ] && echo "  + Kitty terminal"
    [ -d "$SCRIPT_DIR/mako" ] && echo "  + Mako notifications"
    [ -d "$SCRIPT_DIR/Pictures/Wallpapers" ] && echo "  + Wallpapers collection"
    [ -f "$SCRIPT_DIR/dotfiles/starship.toml" ] && echo "  + Starship prompt"
    echo ""
    
    if [ "$INSTALL_MODE" = "full" ]; then
        echo "[*] Additional Components (Full Install):"
        [ -d "$SCRIPT_DIR/fastfetch" ] && echo "  + Fastfetch system info"
        [ -d "$SCRIPT_DIR/wofi" ] && echo "  + Wofi launcher (fallback)"
        [ -d "$SCRIPT_DIR/hypremoji" ] && echo "  + Hypremoji picker"
        [ -d "$SCRIPT_DIR/firefox" ] && echo "  - Firefox userChrome (optional)"
        [ -d "$SCRIPT_DIR/nvim" ] && echo "  - Neovim config (optional)"
        [ -d "$SCRIPT_DIR/vesktop" ] && echo "  - Vesktop/Discord (optional)"
        [ -d "$SCRIPT_DIR/VSCodium" ] && echo "  - VSCodium (optional)"
        [ -d "$SCRIPT_DIR/thunar" ] && echo "  - Thunar file manager (optional)"
        echo ""
    fi
    
    echo "[*] System Configuration:"
    echo "  + Create default settings.json"
    echo "  + Setup Papirus icon folders"
    echo "  + Configure sudo for theme switching"
    echo "  + Initialize wallpaper system"
    echo "  + Apply default theme (catppuccin-mocha)"
    echo "  + Make all scripts executable"
    echo ""
    
    print_info "Installation location: ~/.config/"
    echo ""
}

# Show installation summary at the end
show_summary() {
    print_header "Installation Summary"
    
    if [ ${#INSTALLED_COMPONENTS[@]} -gt 0 ]; then
        print_success "Successfully installed (${#INSTALLED_COMPONENTS[@]} components):"
        for component in "${INSTALLED_COMPONENTS[@]}"; do
            echo "  + $component"
        done
        echo ""
    fi
    
    if [ ${#SKIPPED_COMPONENTS[@]} -gt 0 ]; then
        print_info "Skipped components (${#SKIPPED_COMPONENTS[@]}):"
        for component in "${SKIPPED_COMPONENTS[@]}"; do
            echo "  - $component"
        done
        echo ""
    fi
}

# Install AUR helper
install_aur_helper() {
    print_header "Installing AUR Helper"
    
    print_info "An AUR helper is required to install packages from the Arch User Repository"
    echo ""
    
    local helper_name=""
    if [ "$YOLO_MODE" = true ]; then
        print_info "YOLO mode: Auto-selecting yay as AUR helper"
        helper_name="yay"
    else
        echo "Available options:"
        echo "  [1] yay - Popular, feature-rich AUR helper"
        echo "  [2] paru - Modern, rust-based AUR helper"
        echo ""
        read -p "Choose AUR helper (1/2) [1]: " helper_choice
        
        case $helper_choice in
            2)
                helper_name="paru"
                ;;
            1|"")
                helper_name="yay"
                ;;
            *)
                print_error "Invalid choice. Installing yay by default."
                helper_name="yay"
                ;;
        esac
    fi
    
    print_info "Installing $helper_name..."
    
    # Install base-devel and git if not present
    print_step "Ensuring base-devel and git are installed..."
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone and install
    print_step "Cloning $helper_name from AUR..."
    git clone "https://aur.archlinux.org/${helper_name}.git"
    cd "$helper_name"
    
    print_step "Building and installing $helper_name..."
    makepkg -si --noconfirm
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    if command_exists "$helper_name"; then
        print_success "$helper_name installed successfully"
        return 0
    else
        print_error "Failed to install $helper_name"
        return 1
    fi
}

# Detect GPU vendor
detect_gpu() {
    print_header "Detecting GPU Hardware"
    
    local gpu_info=$(lspci | grep -E "VGA|3D|Display")
    local nvidia_detected=false
    local amd_detected=false
    local intel_detected=false
    
    if echo "$gpu_info" | grep -iq "nvidia"; then
        nvidia_detected=true
        print_info "NVIDIA GPU detected:"
        echo "$gpu_info" | grep -i nvidia
    fi
    
    if echo "$gpu_info" | grep -iq "amd\|radeon"; then
        amd_detected=true
        print_info "AMD GPU detected:"
        echo "$gpu_info" | grep -iE "amd|radeon"
    fi
    
    if echo "$gpu_info" | grep -iq "intel"; then
        intel_detected=true
        print_info "Intel GPU detected:"
        echo "$gpu_info" | grep -i intel
    fi
    
    # Determine GPU type
    local gpu_type=""
    local gpu_count=0
    $nvidia_detected && ((gpu_count++))
    $amd_detected && ((gpu_count++))
    $intel_detected && ((gpu_count++))
    
    if [ $gpu_count -eq 0 ]; then
        print_warning "No GPU detected - this is unusual"
        gpu_type="none"
    elif [ $gpu_count -gt 1 ]; then
        print_info "Hybrid GPU configuration detected"
        gpu_type="hybrid"
    else
        if $nvidia_detected; then
            gpu_type="nvidia"
        elif $amd_detected; then
            gpu_type="amd"
        elif $intel_detected; then
            gpu_type="intel"
        fi
    fi
    
    echo "$gpu_type"
}

# Install GPU drivers and graphics stack
install_gpu_drivers() {
    print_header "Installing GPU Drivers & Graphics Stack"
    
    local gpu_type=$(detect_gpu)
    local aur_helper=""
    
    # Detect AUR helper
    if command_exists "paru"; then
        aur_helper="paru"
    elif command_exists "yay"; then
        aur_helper="yay"
    else
        print_error "AUR helper required for GPU driver installation"
        exit 1
    fi
    
    print_success "GPU type: $gpu_type"
    echo ""
    
    # Common graphics packages for all GPU types
    local common_packages=(
        "mesa"
        "lib32-mesa"
        "wayland"
        "xorg-xwayland"
        "libinput"
        "xf86-input-libinput"
        "seatd"
        "polkit"
        "qt5-wayland"
        "qt5-graphicaleffects"
        "qt6-wayland"
        "qt6-5compat"
        "glfw-wayland"
    )
    
    print_info "Installing common graphics libraries..."
    if [ "$YOLO_MODE" = true ]; then
        sudo pacman -S --needed --noconfirm "${common_packages[@]}"
    else
        sudo pacman -S --needed "${common_packages[@]}"
    fi
    print_success "Common graphics libraries installed"
    
    case "$gpu_type" in
        nvidia)
            install_nvidia_drivers "$aur_helper"
            ;;
        amd)
            install_amd_drivers
            ;;
        intel)
            install_intel_drivers
            ;;
        hybrid)
            install_hybrid_drivers "$aur_helper"
            ;;
        none)
            print_warning "No GPU detected - skipping GPU-specific drivers"
            ;;
    esac
    
    echo ""
    print_success "GPU drivers and graphics stack installed"
}

# Install NVIDIA drivers
install_nvidia_drivers() {
    local aur_helper="$1"
    
    print_warning "NVIDIA GPU detected"
    echo ""
    print_info "NVIDIA driver options:"
    echo "  [1] Proprietary (nvidia-dkms) - Recommended for best Wayland support"
    echo "  [2] Open source (nouveau) - Limited Wayland support, not recommended"
    echo ""
    
    local driver_choice=""
    if [ "$YOLO_MODE" = true ]; then
        print_info "YOLO mode: Auto-selecting proprietary NVIDIA drivers"
        driver_choice="1"
    else
        read -p "Choose NVIDIA driver (1/2) [1]: " driver_choice
    fi
    
    case $driver_choice in
        2)
            print_info "Installing nouveau (open source)..."
            print_warning "Note: nouveau has poor Wayland/Hyprland performance"
            if [ "$YOLO_MODE" = true ]; then
                sudo pacman -S --needed --noconfirm mesa xf86-video-nouveau
            else
                sudo pacman -S --needed mesa xf86-video-nouveau
            fi
            ;;
        1|"")
            print_info "Installing NVIDIA proprietary drivers..."
            
            local nvidia_packages=(
                "nvidia-dkms"
                "nvidia-utils"
                "lib32-nvidia-utils"
                "nvidia-settings"
                "linux-headers"
            )
            
            if [ "$YOLO_MODE" = true ]; then
                sudo pacman -S --needed --noconfirm "${nvidia_packages[@]}"
            else
                sudo pacman -S --needed "${nvidia_packages[@]}"
            fi
            
            print_success "NVIDIA drivers installed"
            configure_nvidia
            ;;
    esac
}

# Configure NVIDIA for Hyprland
configure_nvidia() {
    print_info "Configuring NVIDIA for Hyprland..."
    
    # Enable nvidia-drm modeset
    local modprobe_conf="/etc/modprobe.d/nvidia.conf"
    if [ ! -f "$modprobe_conf" ] || ! grep -q "nvidia-drm.modeset=1" "$modprobe_conf"; then
        print_info "Enabling nvidia-drm modeset..."
        echo "options nvidia-drm modeset=1" | sudo tee -a "$modprobe_conf" > /dev/null
    fi
    
    # Add NVIDIA environment variables to Hyprland config
    local hypr_nvidia_conf="$HOME/.config/hypr/nvidia.conf"
    print_info "Creating NVIDIA environment configuration..."
    
    cat > "$hypr_nvidia_conf" << 'EOF'
# NVIDIA-specific environment variables for Hyprland
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# NVIDIA-specific cursor fix
cursor {
    no_hardware_cursors = true
}
EOF
    
    # Source it from main hyprland.conf if not already there
    local hypr_config="$HOME/.config/hypr/hyprland.conf"
    if [ -f "$hypr_config" ] && ! grep -q "source.*nvidia.conf" "$hypr_config"; then
        print_info "Adding NVIDIA config to hyprland.conf..."
        echo "" >> "$hypr_config"
        echo "# NVIDIA configuration" >> "$hypr_config"
        echo "source = ~/.config/hypr/nvidia.conf" >> "$hypr_config"
    fi
    
    print_success "NVIDIA configuration complete"
    print_warning "IMPORTANT: Reboot required for NVIDIA drivers to take effect"
}

# Install AMD drivers
install_amd_drivers() {
    print_info "Installing AMD drivers (open source)..."
    
    local amd_packages=(
        "vulkan-radeon"
        "lib32-vulkan-radeon"
        "libva-mesa-driver"
        "lib32-libva-mesa-driver"
        "mesa-vdpau"
        "lib32-mesa-vdpau"
        "xf86-video-amdgpu"
    )
    
    if [ "$YOLO_MODE" = true ]; then
        sudo pacman -S --needed --noconfirm "${amd_packages[@]}"
    else
        sudo pacman -S --needed "${amd_packages[@]}"
    fi
    
    print_success "AMD drivers installed"
}

# Install Intel drivers
install_intel_drivers() {
    print_info "Installing Intel drivers (open source)..."
    
    local intel_packages=(
        "vulkan-intel"
        "lib32-vulkan-intel"
        "libva-intel-driver"
        "libva-utils"
        "intel-media-driver"
    )
    
    if [ "$YOLO_MODE" = true ]; then
        sudo pacman -S --needed --noconfirm "${intel_packages[@]}"
    else
        sudo pacman -S --needed "${intel_packages[@]}"
    fi
    
    print_success "Intel drivers installed"
}

# Install drivers for hybrid GPU systems
install_hybrid_drivers() {
    local aur_helper="$1"
    
    print_warning "Hybrid GPU system detected"
    echo ""
    
    local gpu_info=$(lspci | grep -E "VGA|3D|Display")
    local has_nvidia=false
    local has_amd=false
    local has_intel=false
    
    echo "$gpu_info" | grep -iq "nvidia" && has_nvidia=true
    echo "$gpu_info" | grep -iq "amd\|radeon" && has_amd=true
    echo "$gpu_info" | grep -iq "intel" && has_intel=true
    
    # Install drivers for each detected GPU
    if $has_intel; then
        install_intel_drivers
    fi
    
    if $has_amd; then
        install_amd_drivers
    fi
    
    if $has_nvidia; then
        print_info "NVIDIA detected in hybrid configuration"
        echo ""
        print_info "For hybrid NVIDIA systems, we recommend envycontrol for GPU switching"
        echo ""
        
        local install_envycontrol=false
        if [ "$YOLO_MODE" = true ]; then
            print_info "YOLO mode: Installing envycontrol and NVIDIA drivers"
            install_envycontrol=true
        else
            read -p "Install NVIDIA drivers and envycontrol for GPU switching? (y/n) " -n 1 -r
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && install_envycontrol=true
        fi
        
        if [ "$install_envycontrol" = true ]; then
            install_nvidia_drivers "$aur_helper"
            
            print_info "Installing envycontrol..."
            if [ "$aur_helper" = "yay" ]; then
                if [ "$YOLO_MODE" = true ]; then
                    $aur_helper -S --needed --noconfirm --answerclean All --answerdiff None envycontrol
                else
                    $aur_helper -S --needed envycontrol
                fi
            elif [ "$aur_helper" = "paru" ]; then
                if [ "$YOLO_MODE" = true ]; then
                    $aur_helper -S --needed --noconfirm envycontrol
                else
                    $aur_helper -S --needed envycontrol
                fi
            fi
            
            print_success "envycontrol installed"
            print_info "Use 'sudo envycontrol -s hybrid' for hybrid mode"
            print_info "Use 'sudo envycontrol -s integrated' for integrated GPU only"
            print_info "Use 'sudo envycontrol -s nvidia' for NVIDIA only"
        fi
    fi
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_critical=()
    local missing_recommended=()
    local aur_helper=""
    
    # Detect AUR helper
    if command_exists "paru"; then
        aur_helper="paru"
    elif command_exists "yay"; then
        aur_helper="yay"
    else
        print_warning "No AUR helper found (paru or yay required)"
        
        if [ "$YOLO_MODE" = true ]; then
            print_info "YOLO mode: Auto-installing yay"
            # Auto-install yay in YOLO mode
            print_step "Ensuring base-devel and git are installed..."
            sudo pacman -S --needed --noconfirm base-devel git
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            git clone "https://aur.archlinux.org/yay.git"
            cd yay
            makepkg -si --noconfirm
            cd "$HOME"
            rm -rf "$temp_dir"
            
            if command_exists "yay"; then
                aur_helper="yay"
            else
                print_error "Failed to install yay"
                exit 1
            fi
        else
            read -p "Install an AUR helper now? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_aur_helper
                # Detect which one was installed
                if command_exists "paru"; then
                    aur_helper="paru"
                elif command_exists "yay"; then
                    aur_helper="yay"
                else
                    print_error "AUR helper installation failed"
                    exit 1
                fi
            else
                print_error "AUR helper is required for installation"
                print_info "Install manually with:"
                echo "  sudo pacman -S --needed git base-devel"
                echo "  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
                exit 1
            fi
        fi
    fi
    
    print_success "Found AUR helper: $aur_helper"
    
    # Critical dependencies - must have these
    print_info "Checking critical dependencies..."
    
    if ! command_exists "quickshell"; then
        missing_critical+=("quickshell-git")
    fi
    
    if ! command_exists "hyprctl"; then
        missing_critical+=("hyprland")
    fi
    
    if ! command_exists "kitty"; then
        missing_critical+=("kitty")
    fi
    
    if ! command_exists "swww"; then
        missing_critical+=("swww")
    fi
    
    if ! command_exists "mako"; then
        missing_critical+=("mako")
    fi
    
    if ! command_exists "notify-send"; then
        missing_critical+=("libnotify")
    fi
    
    if ! command_exists "hyprshot"; then
        missing_critical+=("hyprshot")
    fi
    
    if ! command_exists "grim"; then
        missing_critical+=("grim")
    fi
    
    if ! command_exists "slurp"; then
        missing_critical+=("slurp")
    fi
    
    if ! command_exists "nwg-look"; then
        missing_critical+=("nwg-look")
    fi
    
    if ! command_exists "papirus-folders"; then
        missing_critical+=("papirus-folders-git")
    fi
    
    # Check for Papirus icon theme
    if [ ! -d "/usr/share/icons/Papirus" ] && [ ! -d "/usr/share/icons/Papirus-Dark" ]; then
        missing_critical+=("papirus-icon-theme")
    fi
    
    # Check for required fonts
    if ! fc-list | grep -qi "nerd.*font.*symbols"; then
        missing_critical+=("ttf-nerd-fonts-symbols")
    fi
    
    # Check for Maple Mono font family (need multiple packages for complete coverage)
    local maple_found=false
    if fc-list | grep -qi "maple"; then
        maple_found=true
    fi
    
    if [ "$maple_found" = false ]; then
        # Install all Maple Mono variants for proper font coverage
        missing_critical+=("maplemono-nf-unhinted")
        missing_critical+=("maplemono-ttf")
        missing_critical+=("maplemononl-ttf")
        missing_critical+=("maplemono-cn-unhinted")
    fi
    
    # Recommended dependencies
    print_info "Checking recommended dependencies..."
    
    if ! command_exists "wireplumber"; then
        missing_recommended+=("wireplumber pipewire-pulse")
    fi
    
    if ! command_exists "pavucontrol"; then
        missing_recommended+=("pavucontrol")
    fi
    
    if ! command_exists "blueman-manager"; then
        missing_recommended+=("blueman")
    fi
    
    if ! command_exists "nmtui"; then
        missing_recommended+=("networkmanager")
    fi
    
    if ! command_exists "thunar"; then
        missing_recommended+=("thunar")
    fi
    
    if ! command_exists "firefox"; then
        missing_recommended+=("firefox")
    fi
    
    if ! command_exists "brightnessctl"; then
        missing_recommended+=("brightnessctl")
    fi
    
    if ! command_exists "hyprlock"; then
        missing_recommended+=("hyprlock")
    fi
    
    if ! command_exists "hypridle"; then
        missing_recommended+=("hypridle")
    fi
    
    if ! command_exists "fastfetch"; then
        missing_recommended+=("fastfetch")
    fi
    
    if ! command_exists "starship"; then
        missing_recommended+=("starship")
    fi
    
    # Install critical dependencies
    if [ ${#missing_critical[@]} -gt 0 ]; then
        print_error "Missing critical dependencies:"
        for dep in "${missing_critical[@]}"; do
            echo "  - $dep"
        done
        echo ""
        print_info "Installing critical dependencies..."
        
        # Add appropriate flags for YOLO mode
        if [ "$aur_helper" = "yay" ]; then
            if [ "$YOLO_MODE" = true ]; then
                $aur_helper -S --needed --noconfirm --answerclean All --answerdiff None ${missing_critical[@]}
            else
                $aur_helper -S --needed ${missing_critical[@]}
            fi
        elif [ "$aur_helper" = "paru" ]; then
            if [ "$YOLO_MODE" = true ]; then
                $aur_helper -S --needed --noconfirm ${missing_critical[@]}
            else
                $aur_helper -S --needed ${missing_critical[@]}
            fi
        fi
        
        if [ $? -ne 0 ]; then
            print_error "Failed to install critical dependencies"
            exit 1
        fi
        print_success "Critical dependencies installed"
    else
        print_success "All critical dependencies found"
    fi
    
    # Offer to install recommended dependencies
    if [ ${#missing_recommended[@]} -gt 0 ]; then
        print_warning "Missing recommended dependencies:"
        for dep in "${missing_recommended[@]}"; do
            echo "  - $dep"
        done
        echo ""
        
        local install_recommended=false
        if [ "$YOLO_MODE" = true ]; then
            print_info "YOLO mode: Auto-installing recommended dependencies"
            install_recommended=true
        else
            read -p "Install recommended dependencies? (y/n) " -n 1 -r
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && install_recommended=true
        fi
        
        if [ "$install_recommended" = true ]; then
            if [ "$aur_helper" = "yay" ]; then
                if [ "$YOLO_MODE" = true ]; then
                    $aur_helper -S --needed --noconfirm --answerclean All --answerdiff None ${missing_recommended[@]}
                else
                    $aur_helper -S --needed ${missing_recommended[@]}
                fi
            elif [ "$aur_helper" = "paru" ]; then
                if [ "$YOLO_MODE" = true ]; then
                    $aur_helper -S --needed --noconfirm ${missing_recommended[@]}
                else
                    $aur_helper -S --needed ${missing_recommended[@]}
                fi
            fi
            print_success "Recommended dependencies installed"
        else
            print_info "Skipping recommended dependencies (some features may not work)"
        fi
    else
        print_success "All recommended dependencies found"
    fi
}

# Main installation function
install_configs() {
    print_header "Installing Configurations"
    
    # Install Quickshell configs
    if [ -d "$SCRIPT_DIR/quickshell" ]; then
        install_config "$SCRIPT_DIR/quickshell" "$HOME/.config/quickshell" "Quickshell"
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
    fi
    
    # Install Fastfetch configs (full mode only)
    if [ "$INSTALL_MODE" = "full" ] && [ -d "$SCRIPT_DIR/fastfetch" ]; then
        install_config "$SCRIPT_DIR/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
    fi
    
    # Install Wofi configs (full mode only)
    if [ "$INSTALL_MODE" = "full" ] && [ -d "$SCRIPT_DIR/wofi" ]; then
        install_config "$SCRIPT_DIR/wofi" "$HOME/.config/wofi" "Wofi"
    fi
    
    # Install Hypremoji configs (full mode only)
    if [ "$INSTALL_MODE" = "full" ] && [ -d "$SCRIPT_DIR/hypremoji" ]; then
        install_config "$SCRIPT_DIR/hypremoji" "$HOME/.config/hypremoji" "Hypremoji"
    fi
    
    # Install Wallpapers
    if [ -d "$SCRIPT_DIR/Pictures/Wallpapers" ]; then
        print_step "Installing wallpapers..."
        mkdir -p "$HOME/Pictures"
        cp -r "$SCRIPT_DIR/Pictures/Wallpapers" "$HOME/Pictures/"
        print_success "Wallpapers installed"
        INSTALLED_COMPONENTS+=("Wallpapers")
    fi
    
    # Optional components (only in full mode and if user confirms)
    if [ "$INSTALL_MODE" = "full" ]; then
        # Install Nvim configs (optional)
        if [ -d "$SCRIPT_DIR/nvim" ]; then
            local install_nvim=false
            if [ "$YOLO_MODE" = true ]; then
                print_info "YOLO mode: Skipping optional Neovim config"
            else
                read -p "Install Neovim configuration? (y/n) " -n 1 -r
                echo
                [[ $REPLY =~ ^[Yy]$ ]] && install_nvim=true
            fi
            
            if [ "$install_nvim" = true ]; then
                install_config "$SCRIPT_DIR/nvim" "$HOME/.config/nvim" "Neovim"
            else
                SKIPPED_COMPONENTS+=("Neovim")
            fi
        fi
        
        # Install Vesktop configs (optional)
        if [ -d "$SCRIPT_DIR/vesktop" ]; then
            local install_vesktop=false
            if [ "$YOLO_MODE" = true ]; then
                print_info "YOLO mode: Skipping optional Vesktop config"
            else
                read -p "Install Vesktop (Discord) configuration? (y/n) " -n 1 -r
                echo
                [[ $REPLY =~ ^[Yy]$ ]] && install_vesktop=true
            fi
            
            if [ "$install_vesktop" = true ]; then
                install_config "$SCRIPT_DIR/vesktop" "$HOME/.config/vesktop" "Vesktop"
            else
                SKIPPED_COMPONENTS+=("Vesktop")
            fi
        fi
        
        # Install VSCodium configs (optional)
        if [ -d "$SCRIPT_DIR/VSCodium" ]; then
            local install_vscodium=false
            if [ "$YOLO_MODE" = true ]; then
                print_info "YOLO mode: Skipping optional VSCodium config"
            else
                read -p "Install VSCodium configuration? (y/n) " -n 1 -r
                echo
                [[ $REPLY =~ ^[Yy]$ ]] && install_vscodium=true
            fi
            
            if [ "$install_vscodium" = true ]; then
                install_config "$SCRIPT_DIR/VSCodium" "$HOME/.config/VSCodium" "VSCodium"
            else
                SKIPPED_COMPONENTS+=("VSCodium")
            fi
        fi
        
        # Install Thunar configs (optional)
        if [ -d "$SCRIPT_DIR/thunar" ]; then
            local install_thunar=false
            if [ "$YOLO_MODE" = true ]; then
                print_info "YOLO mode: Skipping optional Thunar config"
            else
                read -p "Install Thunar configuration? (y/n) " -n 1 -r
                echo
                [[ $REPLY =~ ^[Yy]$ ]] && install_thunar=true
            fi
            
            if [ "$install_thunar" = true ]; then
                install_config "$SCRIPT_DIR/thunar" "$HOME/.config/Thunar" "Thunar"
                # Also install xfce4 thunar.xml
                if [ -f "$SCRIPT_DIR/thunar/thunar.xml" ]; then
                    mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
                    cp "$SCRIPT_DIR/thunar/thunar.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
                fi
            else
                SKIPPED_COMPONENTS+=("Thunar")
            fi
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
    cp "$SCRIPT_DIR/dotfiles/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship config installed to $HOME/.config/starship.toml"
}

# Setup Papirus folders with sudo permissions
setup_papirus() {
    print_header "Setting Up Papirus Folders"
    
    if ! command_exists "papirus-folders"; then
        print_error "papirus-folders not installed - was it skipped during dependency check?"
        return
    fi
    
    # Create sudoers.d file for passwordless papirus-folders
    print_info "Configuring passwordless sudo for papirus-folders..."
    
    local sudoers_content="$USER ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders"
    local sudoers_file="/etc/sudoers.d/papirus-folders"
    
    # Create temp file with content
    echo "$sudoers_content" | sudo tee "$sudoers_file" > /dev/null
    
    # Set proper permissions (must be 0440)
    sudo chmod 0440 "$sudoers_file"
    
    # Validate sudoers file
    if sudo visudo -c -f "$sudoers_file" &> /dev/null; then
        print_success "Sudoers configured for papirus-folders"
    else
        print_error "Failed to validate sudoers file"
        sudo rm -f "$sudoers_file"
        return 1
    fi
    
    # Note: Papirus folder color will be set on first theme switch
    print_info "Papirus folder colors will be configured on first theme switch"
}

# Create default settings.json
create_settings() {
    print_header "Creating Default Settings"
    
    local settings_file="$HOME/.config/quickshell/settings.json"
    
    if [ -f "$settings_file" ]; then
        print_info "Settings file already exists, skipping..."
        return
    fi
    
    print_info "Creating default settings.json..."
    
    cat > "$settings_file" << 'EOF'
{
  "general": {
    "clockFormat24hr": false,
    "showSeconds": false
  },
  "systemTray": {
    "showBatteryDetails": true,
    "showVolumeDetails": true,
    "showNetworkDetails": true
  },
  "currentTheme": "Catppuccin"
}
EOF
    
    print_success "Default settings created at $settings_file"
}

# Make all scripts executable
fix_permissions() {
    print_header "Setting Script Permissions"
    
    print_info "Making scripts executable..."
    
    # Quickshell scripts
    if [ -d "$HOME/.config/quickshell/scripts" ]; then
        chmod +x "$HOME/.config/quickshell/scripts/"*.sh 2>/dev/null || true
    fi
    chmod +x "$HOME/.config/quickshell/"*.sh 2>/dev/null || true
    chmod +x "$HOME/.config/quickshell/theme-switcher-quickshell" 2>/dev/null || true
    chmod +x "$HOME/.config/quickshell/wallpaper-picker" 2>/dev/null || true
    chmod +x "$HOME/.config/quickshell/toggle-"* 2>/dev/null || true
    
    # Mako scripts
    if [ -d "$HOME/.config/mako" ]; then
        chmod +x "$HOME/.config/mako/"*.sh 2>/dev/null || true
    fi
    
    # Fastfetch scripts
    if [ -d "$HOME/.config/fastfetch" ]; then
        chmod +x "$HOME/.config/fastfetch/"*.sh 2>/dev/null || true
    fi
    
    print_success "Script permissions configured"
}

# Install Firefox userChrome
install_firefox() {
    print_header "Firefox userChrome.css Setup"
    
    if [ ! -f "$SCRIPT_DIR/firefox/userChrome.css" ]; then
        print_warning "Firefox userChrome.css not found in repo, skipping..."
        return
    fi
    
    local install_firefox=false
    if [ "$YOLO_MODE" = true ]; then
        print_info "YOLO mode: Skipping optional Firefox userChrome"
        return
    else
        read -p "Install Firefox userChrome.css theme? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_firefox=true
    fi
    
    if [ "$install_firefox" = false ]; then
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

# Initialize wallpaper system
initialize_wallpaper() {
    print_header "Initializing Wallpaper System"
    
    # Check if we're in a Wayland session
    if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        print_info "Not in a Wayland session - wallpaper will be initialized on first launch"
        print_info "The wallpaper system is configured and ready to use"
        return
    fi
    
    # Check if swww is running
    if ! pgrep -x swww-daemon > /dev/null; then
        print_info "Starting swww daemon..."
        swww-daemon &
        sleep 2
    else
        print_info "swww daemon already running"
    fi
    
    # Set default wallpaper if available
    local default_wallpaper="$HOME/Pictures/Wallpapers/catppuccin-macchiato.png"
    
    if [ -f "$default_wallpaper" ]; then
        print_info "Setting default wallpaper..."
        swww img "$default_wallpaper" --transition-type fade --transition-duration 2
        print_success "Default wallpaper applied"
    else
        # Try to find any wallpaper
        local any_wallpaper=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" \) | head -n 1)
        if [ -n "$any_wallpaper" ]; then
            print_info "Setting wallpaper..."
            swww img "$any_wallpaper" --transition-type fade --transition-duration 2
            print_success "Wallpaper applied"
        else
            print_warning "No wallpapers found in ~/Pictures/Wallpapers"
        fi
    fi
}

# Apply default theme
apply_default_theme() {
    print_header "Applying Default Theme"
    
    # Skip theme application during installation to avoid Papirus async issues
    # Theme will be applied automatically on first Quickshell launch
    print_info "Theme will be applied on first Quickshell launch"
    print_info "Default theme: catppuccin-mocha"
}

# Test theme switching functionality
test_theme_switching() {
    print_header "Testing Theme System"
    
    # Skip active theme testing during installation to avoid Papirus async issues
    # Just verify files exist
    local switch_theme_script="$HOME/.config/quickshell/switch-theme.sh"
    
    if [ ! -f "$switch_theme_script" ]; then
        print_error "Theme switcher script not found"
        return 1
    fi
    
    print_step "Verifying theme system files..."
    
    # Test by checking if ThemeManager.qml exists and has themes
    local theme_manager="$HOME/.config/quickshell/ThemeManager.qml"
    if [ ! -f "$theme_manager" ]; then
        print_error "ThemeManager.qml not found"
        return 1
    fi
    
    # Count available themes
    local theme_count=$(grep -c "name:" "$theme_manager" || echo "0")
    if [ "$theme_count" -gt 0 ]; then
        print_success "Found $theme_count themes available"
        print_info "Themes can be switched with Super+T"
    else
        print_warning "Could not detect themes in ThemeManager.qml"
    fi
    
    return 0
}

# Verify Quickshell configuration
verify_installation() {
    print_header "Verifying Installation"
    
    local errors=0
    
    # Check if Quickshell is installed
    print_step "Checking Quickshell installation..."
    if command_exists "quickshell"; then
        print_success "Quickshell is installed"
    else
        print_error "Quickshell not found in PATH"
        ((errors++))
    fi
    
    # Check if shell.qml exists
    print_step "Checking configuration files..."
    if [ -f "$HOME/.config/quickshell/shell.qml" ]; then
        print_success "Main configuration found"
    else
        print_error "shell.qml not found"
        ((errors++))
    fi
    
    # Check if settings.json exists
    if [ -f "$HOME/.config/quickshell/settings.json" ]; then
        print_success "Settings file found"
    else
        print_warning "settings.json not found (will be created on first run)"
    fi
    
    # Test Quickshell syntax
    print_step "Testing Quickshell configuration syntax..."
    
    # Skip launch test during installation to avoid process conflicts
    print_info "Skipping Quickshell launch test during installation"
    print_info "Quickshell will start automatically via Hyprland autostart"
    print_info "You can test manually with: quickshell"
    
    # Check script permissions
    print_step "Checking script permissions..."
    local scripts_executable=0
    if [ -x "$HOME/.config/quickshell/switch-theme.sh" ]; then
        ((scripts_executable++))
    fi
    if [ -x "$HOME/.config/quickshell/scripts/list-apps.sh" ]; then
        ((scripts_executable++))
    fi
    
    if [ $scripts_executable -eq 2 ]; then
        print_success "Scripts are executable"
    else
        print_warning "Some scripts may not be executable"
    fi
    
    echo ""
    if [ $errors -eq 0 ]; then
        print_success "Verification complete - no critical errors"
        return 0
    else
        print_warning "Verification found $errors issue(s) - please review"
        return 1
    fi
}

# Configure Hyprland autostart
configure_hyprland() {
    print_header "Configuring Hyprland Integration"
    
    local hypr_config="$HOME/.config/hypr/hyprland.conf"
    
    if [ ! -f "$hypr_config" ]; then
        print_warning "Hyprland config not found at $hypr_config"
        return
    fi
    
    # Check if quickshell is already in autostart
    if grep -q "exec-once.*quickshell" "$hypr_config"; then
        print_info "Quickshell already configured in Hyprland autostart"
        return
    fi
    
    print_info "Quickshell autostart is configured in hypr/autostart.conf"
    print_info "This file is included by hyprland.conf"
    
    # Check if autostart.conf is sourced
    if ! grep -q "source.*autostart.conf" "$hypr_config"; then
        print_warning "autostart.conf is not sourced in hyprland.conf"
        
        local add_source=false
        if [ "$YOLO_MODE" = true ]; then
            print_info "YOLO mode: Auto-adding autostart.conf source"
            add_source=true
        else
            read -p "Add source line to hyprland.conf? (y/n) " -n 1 -r
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && add_source=true
        fi
        
        if [ "$add_source" = true ]; then
            echo "" >> "$hypr_config"
            echo "# Autostart applications" >> "$hypr_config"
            echo "source = ~/.config/hypr/autostart.conf" >> "$hypr_config"
            print_success "Added autostart.conf source to hyprland.conf"
        fi
    else
        print_success "Hyprland is configured to use autostart.conf"
    fi
}

# Post-installation setup
post_install() {
    print_header "Post-Installation Summary"
    
    print_success "Installation completed successfully!"
    
    echo ""
    print_info "What was installed:"
    echo "  ✓ Quickshell configuration"
    echo "  ✓ Hyprland configuration"
    echo "  ✓ Kitty terminal configuration"
    echo "  ✓ Mako notification daemon configuration"
    echo "  ✓ Wallpapers collection"
    echo "  ✓ Default settings and theme"
    echo "  ✓ All required scripts and permissions"
    echo ""
    
    print_info "Next steps:"
    echo "  1. Log out and log back into Hyprland"
    echo "  2. Quickshell should start automatically"
    echo "  3. Try switching themes with Super+T"
    echo "  4. Open app launcher with Super+A"
    echo ""
    print_info "Key bindings:"
    echo "  Super+Q          - Close window"
    echo "  Super+Return     - Terminal (Kitty)"
    echo "  Super+E          - File manager (Thunar)"
    echo "  Super+B          - Browser (Firefox)"
    echo "  Super+A          - App launcher"
    echo "  Super+T          - Theme switcher"
    echo "  Super+Shift+E    - Power menu"
    echo "  Super+P          - Screenshot menu"
    echo "  Super+S          - Settings widget"
    echo "  Super+C          - Calendar widget"
    echo "  Super+W          - Wallpaper picker"
    echo ""
}

# Rollback function in case of failure
rollback_installation() {
    print_header "Installation Failed - Rollback"
    
    print_error "An error occurred during installation"
    print_warning "Note: This installer overwrites configs without backup"
    print_info "You may need to restore from your own backups"
    
    echo ""
    print_info "To try again:"
    echo "  1. Fix any dependency issues"
    echo "  2. Re-run: ./install.sh"
    echo ""
    
    exit 1
}

# Main installation flow
main() {
    # Set up error handling
    trap rollback_installation ERR
    
    print_header "YAHR Quickshell Installation"
    
    # Check we're not running as root
    check_not_root
    
    # Show banner
    echo "Complete Hyprland + Quickshell desktop environment"
    echo "with unified theme system and modern aesthetics"
    echo ""
    
    # YOLO mode prompt
    print_info "Installation mode:"
    echo "  [Y] YOLO mode - Fully unattended installation (auto-skips optional prompts)"
    echo "  [N] Normal mode - Interactive prompts for optional components"
    echo ""
    read -p "Enable YOLO mode? (y/N) [N]: " yolo_choice
    
    case $yolo_choice in
        [Yy]*)
            YOLO_MODE=true
            print_success "YOLO mode enabled - buckle up!"
            ;;
        *)
            YOLO_MODE=false
            print_info "Normal mode selected"
            ;;
    esac
    
    echo ""
    
    # Select installation mode
    print_info "Select installation mode:"
    echo "  [1] Full - All configs and optional components (recommended)"
    echo "  [2] Minimal - Core components only (Quickshell, Hyprland, Kitty, Mako)"
    echo ""
    read -p "Choose mode (1/2) [1]: " mode_choice
    
    case $mode_choice in
        2)
            INSTALL_MODE="minimal"
            print_info "Minimal installation selected"
            ;;
        1|"")
            INSTALL_MODE="full"
            print_info "Full installation selected"
            ;;
        *)
            print_error "Invalid choice. Using full installation."
            INSTALL_MODE="full"
            ;;
    esac
    
    echo ""
    
    # Run pre-flight check
    preflight_check
    
    # Warning about overwriting configs
    print_warning "⚠️  IMPORTANT: Backup your existing configs!"
    echo ""
    print_info "This installer will OVERWRITE existing configurations in:"
    echo "  • ~/.config/quickshell/"
    echo "  • ~/.config/hypr/"
    echo "  • ~/.config/kitty/"
    echo "  • ~/.config/mako/"
    if [ "$INSTALL_MODE" = "full" ]; then
        echo "  • ~/.config/fastfetch/"
        echo "  • ~/.config/wofi/"
    fi
    echo "  • ~/.config/starship.toml"
    echo ""
    print_warning "If you have custom configs, back them up NOW!"
    echo ""
    
    if [ "$YOLO_MODE" = false ]; then
        read -p "Continue with installation? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled."
            exit 0
        fi
    else
        print_info "YOLO mode: Proceeding without confirmation"
    fi
    
    echo ""
    print_info "Starting installation..."
    echo ""
    
    # Run installation steps in order
    install_gpu_drivers
    check_dependencies
    install_configs
    install_starship
    create_settings
    fix_permissions
    setup_papirus
    configure_hyprland
    initialize_wallpaper
    apply_default_theme
    test_theme_switching
    
    # Optional components (full mode only)
    if [ "$INSTALL_MODE" = "full" ]; then
        install_firefox
    fi
    
    install_gtk_themes
    
    # Verify installation
    verify_installation
    
    # Show summary
    show_summary
    
    post_install
    
    # Disable error trap on successful completion
    trap - ERR
    
    echo ""
    print_header "Installation Complete!"
    print_success "✨ YahrShell has been successfully installed! 🚀"
    echo ""
    
    # Check if NVIDIA drivers were installed
    local needs_reboot=false
    if lspci | grep -iq "nvidia" && command_exists "nvidia-smi"; then
        needs_reboot=true
        print_warning "NVIDIA drivers installed - reboot required for proper functionality"
    fi
    
    print_info "To complete the setup:"
    if [ "$needs_reboot" = true ]; then
        echo "  1. Reboot your system (required for NVIDIA drivers)"
        echo "  2. Log into Hyprland"
        echo "  3. YahrShell will start automatically"
    else
        echo "  1. Log out and log into Hyprland"
        echo "  2. YahrShell will start automatically"
    fi
    echo ""
    
    # Prompt for reboot
    if [ "$needs_reboot" = true ] || [ "$YOLO_MODE" = false ]; then
        if [ "$YOLO_MODE" = false ]; then
            read -p "Would you like to reboot now? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Rebooting system..."
                sudo reboot
            else
                print_info "Remember to reboot before using Hyprland"
            fi
        else
            print_info "YOLO mode: Skipping reboot prompt"
            print_warning "Please reboot manually before using Hyprland"
        fi
    fi
    
    echo ""
}

# Run main function
main
