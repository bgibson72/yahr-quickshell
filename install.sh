#!/bin/bash

# YAHR Quickshell Configuration Installer
# This script installs the complete Hyprland + Quickshell setup

# Note: We don't use 'set -e' to allow the installer to be more resilient
# Critical errors are handled explicitly with error trap

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

# Dry-run mode - preview prompts and preflight without making changes
DRY_RUN=false

# Track what gets installed for summary
declare -a INSTALLED_COMPONENTS=()
declare -a SKIPPED_COMPONENTS=()

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[*]${NC} $1"
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

show_usage() {
    cat << 'EOF'
Usage: ./install.sh [--dry-run] [--help]

Options:
  --dry-run  Run prompts and preflight, then exit before making changes
  --help     Show this help message
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
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
    if [ "$DRY_RUN" = true ]; then
        print_info "Dry-run mode: changes will not be applied"
    fi
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
        [ -f "$SCRIPT_DIR/firefox/userChrome.css" ] && echo "  - Firefox userChrome (optional)"
        [ -d "$SCRIPT_DIR/sddm" ] && echo "  - SDDM display manager (optional)"
        [ -d "$SCRIPT_DIR/plymouth/yahr" ] && echo "  - Plymouth boot animation (optional)"
        [ -d "$SCRIPT_DIR/nvim" ] && echo "  - Neovim config (optional)"
        [ -d "$SCRIPT_DIR/vesktop" ] && echo "  - Vesktop/Discord (optional)"
        [ -d "$SCRIPT_DIR/VSCodium" ] && echo "  - VSCodium (optional)"
        [ -d "$SCRIPT_DIR/thunar" ] && echo "  - Thunar file manager (optional)"
        echo "  - Spotify + Spicetify (optional, requires AUR)"
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
        "qt5-imageformats"
        "qt6-wayland"
        "qt6-5compat"
        "qt6-shadertools"
        "qt6-imageformats"
        "qt6-svg"
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
    local hypr_nvidia_conf="$HOME/.config/hypr/nvidia.lua"
    print_info "Creating NVIDIA environment configuration..."
    
    cat > "$hypr_nvidia_conf" << 'EOF'
-- NVIDIA-specific environment variables for Hyprland (auto-generated by installer)
hl.env("LIBVA_DRIVER_NAME",          "nvidia")
hl.env("XDG_SESSION_TYPE",           "wayland")
hl.env("GBM_BACKEND",                "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME",  "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS",    "1")

hl.config({ cursor = { no_hardware_cursors = true } })
EOF
    
    # Inject require("nvidia") into hyprland.lua if not already there
    local hypr_lua="$HOME/.config/hypr/hyprland.lua"
    if [ -f "$hypr_lua" ] && ! grep -q 'require("nvidia")' "$hypr_lua"; then
        print_info "Adding NVIDIA module to hyprland.lua..."
        echo '' >> "$hypr_lua"
        echo '-- NVIDIA configuration (added by installer)' >> "$hypr_lua"
        echo 'require("nvidia")' >> "$hypr_lua"
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
    
    if ! command_exists "cliphist"; then
        missing_critical+=("cliphist")
    fi
    
    if ! command_exists "wofi"; then
        missing_critical+=("wofi")
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
    
    # Check for Sen font (UI text font) – downloaded from GitHub, not pacman
    if ! fc-list | grep -qi "Sen:"; then
        print_step "Installing Sen font..."
        local sen_dir="$HOME/.local/share/fonts/sen"
        mkdir -p "$sen_dir"
        local sen_base="https://raw.githubusercontent.com/philatype/Sen/master/fonts/ttf"
        for weight in Regular Medium SemiBold Bold ExtraBold; do
            curl -sL "${sen_base}/Sen-${weight}.ttf" -o "${sen_dir}/Sen-${weight}.ttf"
        done
        fc-cache -f "$sen_dir"
        print_success "Sen font installed"
    fi
    
    # Check for emoji font (needed for colored weather icons)
    if ! fc-list | grep -qi "noto.*color.*emoji"; then
        missing_critical+=("noto-fonts-emoji")
    fi
    
    # Check for pacseek
    if ! command_exists "pacseek"; then
        missing_critical+=("pacseek")
    fi

    # Check for hyprpolkitagent (polkit authentication agent for Hyprland)
    if ! command_exists "hyprpolkitagent"; then
        missing_critical+=("hyprpolkitagent")
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
    
    # Check for Bluetooth stack
    if ! command_exists "bluetoothctl"; then
        missing_recommended+=("bluez" "bluez-utils")
    fi
    
    if ! command_exists "nmtui"; then
        missing_recommended+=("networkmanager")
    fi
    
    if ! command_exists "thunar"; then
        missing_recommended+=("thunar" "tumbler" "ffmpegthumbnailer" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman" "file-roller")
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

    if ! command_exists "magick"; then
        missing_recommended+=("imagemagick")
    fi
    
    if ! command_exists "starship"; then
        missing_recommended+=("starship")
    fi
    
    if ! command_exists "checkupdates"; then
        missing_recommended+=("pacman-contrib")
    fi

    if ! command_exists "sensors"; then
        missing_recommended+=("lm_sensors")
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
        
        # Add fastfetch to .bashrc if not already present
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q "fastfetch" "$HOME/.bashrc"; then
                echo "" >> "$HOME/.bashrc"
                echo "# Display system info with fastfetch" >> "$HOME/.bashrc"
                echo "fastfetch" >> "$HOME/.bashrc"
                print_info "Added fastfetch to .bashrc"
            fi
        fi
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

# Install and configure Plymouth boot animation
install_plymouth() {
    print_header "Plymouth Boot Animation Setup"

    if [ ! -d "$SCRIPT_DIR/plymouth/yahr" ]; then
        print_warning "Plymouth theme not found in repo, skipping..."
        return
    fi

    local install_ply=false
    if [ "$YOLO_MODE" = true ]; then
        print_info "YOLO mode: Skipping optional Plymouth boot animation"
        SKIPPED_COMPONENTS+=("Plymouth boot animation")
        return
    else
        print_info "Plymouth replaces the kernel text scroll with an animated boot screen."
        echo ""
        read -p "Install Plymouth boot animation (yahr theme)? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_ply=true
    fi

    if [ "$install_ply" = false ]; then
        SKIPPED_COMPONENTS+=("Plymouth boot animation")
        return
    fi

    # Install plymouth package
    print_info "Installing Plymouth..."
    if [ "$YOLO_MODE" = true ]; then
        sudo pacman -S --needed --noconfirm plymouth
    else
        sudo pacman -S --needed plymouth
    fi

    if [ $? -ne 0 ]; then
        print_error "Failed to install Plymouth"
        return 1
    fi
    print_success "Plymouth installed"

    # Install theme files
    print_info "Installing yahr Plymouth theme..."
    sudo mkdir -p /usr/share/plymouth/themes/yahr
    sudo cp -r "$SCRIPT_DIR/plymouth/yahr/"* /usr/share/plymouth/themes/yahr/
    print_success "Plymouth theme installed to /usr/share/plymouth/themes/yahr/"

    # Configure mkinitcpio - add 'plymouth' hook after 'kms' (or 'udev' fallback)
    # IMPORTANT: Plymouth must load AFTER the kms hook so the DRM/KMS framebuffer
    # is available; placing it before kms results in a blank/text-only boot screen.
    print_info "Configuring mkinitcpio for Plymouth..."
    local mkinitcpio_conf="/etc/mkinitcpio.conf"

    if grep -q "^HOOKS=" "$mkinitcpio_conf"; then
        # First remove any stale 'plymouth' entry to avoid duplicates
        sudo sed -i 's/ \bplymouth\b//' "$mkinitcpio_conf"

        if grep "^HOOKS=" "$mkinitcpio_conf" | grep -q '\bkms\b'; then
            # Insert 'plymouth' immediately after 'kms'
            sudo sed -i 's/\bkms\b/kms plymouth/' "$mkinitcpio_conf"
            print_success "Plymouth hook added to mkinitcpio.conf (after kms)"
        else
            # Fallback: insert after 'udev' and warn
            sudo sed -i 's/\budev\b/udev plymouth/' "$mkinitcpio_conf"
            print_success "Plymouth hook added to mkinitcpio.conf (after udev)"
            print_warning "For best Plymouth graphics, add the 'kms' hook before 'plymouth' in mkinitcpio.conf"
        fi
    else
        print_warning "Could not find HOOKS line in mkinitcpio.conf — add 'plymouth' manually after 'kms'"
    fi

    # Configure bootloader: ensure 'quiet splash' in kernel cmdline
    # GRUB
    if [ -f "/etc/default/grub" ]; then
        print_info "Configuring GRUB for Plymouth..."
        if grep -q "quiet.*splash\|splash.*quiet" /etc/default/grub; then
            print_info "GRUB cmdline already contains 'quiet splash'"
        else
            sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 quiet splash"/' /etc/default/grub
            print_success "Added 'quiet splash' to GRUB_CMDLINE_LINUX_DEFAULT"
        fi
        print_step "Regenerating GRUB configuration..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        print_success "GRUB configuration updated"
    fi

    # systemd-boot — classic entries
    if ls /boot/loader/entries/*.conf &>/dev/null 2>&1; then
        print_info "Configuring systemd-boot entries for Plymouth..."
        for entry in /boot/loader/entries/*.conf; do
            if grep -q "^options" "$entry"; then
                if grep -q "splash" "$entry"; then
                    print_info "$(basename "$entry") already has 'splash'"
                else
                    sudo sed -i '/^options/s/$/ quiet splash/' "$entry"
                    print_success "Updated $(basename "$entry")"
                fi
            fi
        done
    fi

    # systemd-boot — UKI (Unified Kernel Image): cmdline lives in /etc/kernel/cmdline
    if ls /boot/EFI/Linux/*.efi &>/dev/null 2>&1; then
        print_info "UKI detected — checking /etc/kernel/cmdline for 'quiet splash'..."
        if [ -f "/etc/kernel/cmdline" ]; then
            if grep -q "quiet.*splash\|splash.*quiet" /etc/kernel/cmdline; then
                print_info "/etc/kernel/cmdline already contains 'quiet splash'"
            else
                sudo sed -i 's/$/ quiet splash loglevel=3/' /etc/kernel/cmdline
                print_success "Added 'quiet splash loglevel=3' to /etc/kernel/cmdline"
            fi
        else
            # Inherit the current cmdline and append splash flags
            local base_cmdline
            base_cmdline=$(cat /proc/cmdline | sed 's/ quiet\| splash\| loglevel=[0-9]//g' | xargs)
            echo "${base_cmdline} quiet splash loglevel=3" | sudo tee /etc/kernel/cmdline > /dev/null
            print_success "Created /etc/kernel/cmdline with 'quiet splash loglevel=3'"
        fi
    fi

    # Set theme and rebuild initramfs in one step
    print_info "Setting yahr as default Plymouth theme and rebuilding initramfs..."
    print_warning "This may take a minute..."
    sudo plymouth-set-default-theme -R yahr

    if [ $? -eq 0 ]; then
        print_success "Initramfs rebuilt with Plymouth yahr theme"
        INSTALLED_COMPONENTS+=("Plymouth boot animation")
        print_info "The yahr boot animation will display on next boot"
    else
        print_error "plymouth-set-default-theme failed — run manually: sudo plymouth-set-default-theme -R yahr"
        return 1
    fi
}

# Install and configure SDDM
install_sddm() {
    print_header "SDDM Display Manager Setup"
    
    if [ ! -d "$SCRIPT_DIR/sddm" ]; then
        print_warning "SDDM config not found in repo, skipping..."
        return
    fi
    
    local install_sddm=false
    if [ "$YOLO_MODE" = true ]; then
        print_info "YOLO mode: Skipping optional SDDM installation"
        return
    else
        print_info "SDDM is a display manager (login screen) for Wayland/X11"
        echo ""
        read -p "Install and configure SDDM? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_sddm=true
    fi
    
    if [ "$install_sddm" = false ]; then
        return
    fi
    
    # Install SDDM package
    print_info "Installing SDDM..."
    if [ "$YOLO_MODE" = true ]; then
        sudo pacman -S --needed --noconfirm sddm
    else
        sudo pacman -S --needed sddm
    fi
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install SDDM"
        return 1
    fi
    
    # Install SDDM theme
    print_info "Installing SDDM theme..."
    sudo mkdir -p /usr/share/sddm/themes
    
    if [ -d "$SCRIPT_DIR/sddm/yahr-theme" ]; then
        print_step "Installing yahr-theme..."
        sudo cp -r "$SCRIPT_DIR/sddm/yahr-theme" /usr/share/sddm/themes/
        print_success "SDDM theme installed to /usr/share/sddm/themes/yahr-theme"
    fi
    
    # Install SDDM config
    print_info "Installing SDDM configuration..."
    sudo mkdir -p /etc/sddm.conf.d
    
    # Create theme configuration
    print_step "Configuring SDDM to use yahr-theme..."
    sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'EOF'
[Theme]
Current=yahr-theme
CursorTheme=Adwaita

[General]
Numlock=on
EOF
    
    print_success "SDDM configuration installed"
    
    # Copy sync script to quickshell directory
    # Prefer the feature-complete version in quickshell/; fall back to sddm/
    local sddm_sync_src=""
    if [ -f "$SCRIPT_DIR/quickshell/sync-sddm-theme.sh" ]; then
        sddm_sync_src="$SCRIPT_DIR/quickshell/sync-sddm-theme.sh"
    elif [ -f "$SCRIPT_DIR/sddm/sync-sddm-theme.sh" ]; then
        sddm_sync_src="$SCRIPT_DIR/sddm/sync-sddm-theme.sh"
    fi
    if [ -n "$sddm_sync_src" ]; then
        print_step "Installing SDDM theme sync script..."
        cp "$sddm_sync_src" "$HOME/.config/quickshell/sync-sddm-theme.sh"
        chmod +x "$HOME/.config/quickshell/sync-sddm-theme.sh"
        print_success "SDDM sync script installed to ~/.config/quickshell/"
    fi
    
    # Create SDDM system faces directory so avatar picker works
    sudo mkdir -p /usr/share/sddm/faces

    # Setup sudoers for passwordless SDDM theme sync + avatar
    print_info "Setting up passwordless SDDM theme sync..."
    local sudoers_file="/etc/sudoers.d/sddm-sync-yahr"

    # Use the template from the repo if available; fall back to inline
    if [ -f "$SCRIPT_DIR/sddm/sddm-sync-sudoers" ]; then
        # Strip comment lines so only the rules remain
        grep -v '^#' "$SCRIPT_DIR/sddm/sddm-sync-sudoers" | grep -v '^$' \
            | sudo tee "$sudoers_file" > /dev/null
    else
        sudo tee "$sudoers_file" > /dev/null << 'SUDOERS'
# Allow SDDM theme sync without password
%wheel ALL=(ALL) NOPASSWD: /usr/bin/cp * /usr/share/sddm/themes/yahr-theme/*
%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /usr/share/sddm/themes/yahr-theme/theme.conf
%wheel ALL=(ALL) NOPASSWD: /usr/bin/cp * /usr/share/sddm/faces/*
SUDOERS
    fi

    if [ $? -eq 0 ]; then
        sudo chmod 0440 "$sudoers_file"

        # Validate sudoers file
        if sudo visudo -c -f "$sudoers_file" &> /dev/null; then
            print_success "Sudoers configured for SDDM theme sync + avatar"
        else
            print_error "Failed to validate sudoers file"
            sudo rm -f "$sudoers_file"
        fi
    else
        print_error "Failed to create sudoers file"
    fi
    
    # Enable SDDM service
    print_info "Enabling SDDM service..."
    sudo systemctl enable sddm
    
    if [ $? -eq 0 ]; then
        print_success "SDDM enabled - will start on next boot"
        print_info "To start SDDM now: sudo systemctl start sddm"
        INSTALLED_COMPONENTS+=("SDDM")
    else
        print_error "Failed to enable SDDM service"
        return 1
    fi
}

# Install GTK themes
install_gtk_themes() {
    print_header "GTK Theme Setup"
    
    print_info "Setting up GTK theme directories..."
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.icons"
    
    # Copy GTK themes from repo
    if [ -d "$SCRIPT_DIR/quickshell/gtk-themes" ]; then
        print_step "Installing GTK themes from repository..."
        cp -r "$SCRIPT_DIR/quickshell/gtk-themes/"* "$HOME/.themes/" 2>/dev/null || true
        print_success "GTK themes installed to ~/.themes"
    fi
    
    # Configure fontconfig for colored emoji support
    print_step "Configuring emoji font support..."
    mkdir -p "$HOME/.config/fontconfig"
    cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Use Noto Color Emoji for emoji characters only, append to fallback -->
  <match>
    <test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>serif</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>monospace</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
</fontconfig>
EOF
    print_success "Emoji font configuration created"
    
    # Rebuild font cache
    print_step "Rebuilding font cache..."
    fc-cache -fv > /dev/null 2>&1
    print_success "Font cache rebuilt"
    
    print_info "Installed GTK themes will automatically sync with your Quickshell theme."
    print_success "GTK theme system configured"
}

# Initialize wallpaper system
initialize_wallpaper() {
    print_header "Initializing Wallpaper System"
    
    # Check if we're in a Wayland session
    if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        print_info "Not in a Wayland session - wallpaper will be set on first launch"
        
        # Still set default theme wallpaper in settings.json for wallpaper picker
        print_info "Setting default Catppuccin wallpaper for first launch..."
        local catppuccin_wallpapers=("$HOME/Pictures/Wallpapers/Catppuccin/"*)
        if [ -f "${catppuccin_wallpapers[0]}" ]; then
            # Pick a random Catppuccin wallpaper
            local random_wallpaper="${catppuccin_wallpapers[$RANDOM % ${#catppuccin_wallpapers[@]}]}"
            
            # Update settings.json with the wallpaper
            local settings_file="$HOME/.config/quickshell/settings.json"
            if [ -f "$settings_file" ]; then
                # Use sed to update the currentWallpaper field
                sed -i "s|\"currentWallpaper\": \".*\"|\"currentWallpaper\": \"$random_wallpaper\"|" "$settings_file"
                print_success "Default wallpaper configured: $(basename "$random_wallpaper")"
            fi
        fi
        
        # Initialize Catppuccin theme as default
        print_info "Initializing Catppuccin as default theme..."
        if [ -f "$HOME/.config/hypr/themes/Catppuccin.conf" ]; then
            # Write the theme name – hyprland.lua reads this on every reload
            echo "Catppuccin" > "$HOME/.config/hypr/.current-theme" 2>/dev/null || true
            print_success "Catppuccin set as default Hyprland theme"
            
            # Run theme sync scripts to initialize all application themes
            print_step "Syncing Catppuccin theme to applications..."
            [ -x "$HOME/.config/quickshell/sync-kitty-theme.sh" ] && "$HOME/.config/quickshell/sync-kitty-theme.sh" >/dev/null 2>&1 && print_success "Kitty theme synced"
            [ -x "$HOME/.config/quickshell/sync-nvim-theme.sh" ] && "$HOME/.config/quickshell/sync-nvim-theme.sh" >/dev/null 2>&1 && print_success "Neovim theme synced"
            [ -x "$HOME/.config/quickshell/sync-firefox-theme.sh" ] && "$HOME/.config/quickshell/sync-firefox-theme.sh" >/dev/null 2>&1 && print_success "Firefox theme synced"
            [ -x "$HOME/.config/quickshell/sync-gtk-theme.sh" ] && "$HOME/.config/quickshell/sync-gtk-theme.sh" >/dev/null 2>&1 && print_success "GTK theme synced"
            [ -x "$HOME/.config/quickshell/sync-hyprlock-theme.sh" ] && "$HOME/.config/quickshell/sync-hyprlock-theme.sh" >/dev/null 2>&1 && print_success "Hyprlock theme synced"
            print_success "Theme synchronization complete"
        fi
        
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
    
    # Set a random Catppuccin wallpaper
    local catppuccin_wallpapers=("$HOME/Pictures/Wallpapers/Catppuccin/"*)
    
    if [ -f "${catppuccin_wallpapers[0]}" ]; then
        # Pick a random Catppuccin wallpaper
        local random_wallpaper="${catppuccin_wallpapers[$RANDOM % ${#catppuccin_wallpapers[@]}]}"
        print_info "Setting random Catppuccin wallpaper..."
        swww img "$random_wallpaper" --transition-type fade --transition-duration 2
        
        # Update settings.json with the wallpaper
        local settings_file="$HOME/.config/quickshell/settings.json"
        if [ -f "$settings_file" ]; then
            sed -i "s|\"currentWallpaper\": \".*\"|\"currentWallpaper\": \"$random_wallpaper\"|" "$settings_file"
        fi
        
        print_success "Wallpaper applied: $(basename "$random_wallpaper")"
    else
        # Fallback to any wallpaper
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
    print_info "Default theme: Catppuccin"
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
    else
        print_warning "Verification found $errors issue(s) - please review"
    fi
    
    # Always return 0 to not trigger error trap
    return 0
}

# Install and configure Spotify + Spicetify
install_spotify_spicetify() {
    print_header "Spotify & Spicetify Setup"

    local aur_helper=""
    if command_exists "paru"; then
        aur_helper="paru"
    elif command_exists "yay"; then
        aur_helper="yay"
    else
        print_error "AUR helper required for Spotify/Spicetify installation"
        SKIPPED_COMPONENTS+=("Spotify/Spicetify")
        return
    fi

    # ── Prompt ────────────────────────────────────────────────────────────────
    local install_choice="n"
    if [ "$YOLO_MODE" = true ]; then
        install_choice="y"
    else
        echo ""
        print_info "Spotify is a music streaming app.  Spicetify themes it to match YAHR."
        echo ""
        read -p "$(echo -e ${CYAN}?${NC}) Install / configure Spotify + Spicetify? (y/n): " install_choice
    fi

    if [[ ! "$install_choice" =~ ^[Yy]$ ]]; then
        print_info "Skipping Spotify / Spicetify setup"
        SKIPPED_COMPONENTS+=("Spotify/Spicetify")
        return
    fi

    # ── Install Spotify ───────────────────────────────────────────────────────
    if ! command_exists "spotify"; then
        print_step "Installing Spotify (AUR)…"
        if [ "$YOLO_MODE" = true ]; then
            $aur_helper -S --needed --noconfirm spotify
        else
            $aur_helper -S --needed spotify
        fi
        if command_exists "spotify"; then
            print_success "Spotify installed"
            INSTALLED_COMPONENTS+=("Spotify")
        else
            print_error "Spotify installation failed – skipping Spicetify"
            SKIPPED_COMPONENTS+=("Spicetify")
            return
        fi
    else
        print_info "Spotify already installed"
    fi

    # ── Install Spicetify CLI ─────────────────────────────────────────────────
    if ! command_exists "spicetify"; then
        print_step "Installing Spicetify CLI (AUR)…"
        if [ "$YOLO_MODE" = true ]; then
            $aur_helper -S --needed --noconfirm spicetify-cli
        else
            $aur_helper -S --needed spicetify-cli
        fi
    fi

    if ! command_exists "spicetify"; then
        print_error "Spicetify CLI not found after install attempt"
        SKIPPED_COMPONENTS+=("Spicetify")
        return
    fi

    print_success "Spicetify CLI ready"

    # ── Fix Spotify directory permissions (required by Spicetify on AUR pkg) ──
    print_step "Fixing Spotify directory permissions for Spicetify…"
    if [ -d "/opt/spotify" ]; then
        sudo chmod a+wr /opt/spotify
        sudo chmod a+wr /opt/spotify/Apps -R
        print_success "Permissions set on /opt/spotify"
    else
        print_warning "/opt/spotify not found – skipping permission fix"
    fi

    # ── Install community Spicetify themes ────────────────────────────────────
    local themes_dir="$HOME/.config/spicetify/Themes"
    mkdir -p "$themes_dir"

    # Official community themes (Dribbblish, Sleek, Flow, etc.)
    print_step "Installing Spicetify community themes…"
    local tmp_themes
    tmp_themes=$(mktemp -d)
    if git clone --depth=1 https://github.com/spicetify/spicetify-themes.git "$tmp_themes/spicetify-themes" 2>/dev/null; then
        # Copy each theme directory (skip README and non-directory items)
        for theme_dir in "$tmp_themes/spicetify-themes"/*/; do
            local tname
            tname=$(basename "$theme_dir")
            [[ "$tname" == "README.md" || "$tname" == "*.md" ]] && continue
            [[ -d "$theme_dir" ]] || continue
            cp -r "$theme_dir" "$themes_dir/$tname"
        done
        print_success "Community themes installed"
    else
        print_warning "Could not clone spicetify-themes (network issue?)"
    fi
    rm -rf "$tmp_themes"

    # Official Catppuccin Spicetify theme
    print_step "Installing Catppuccin Spicetify theme…"
    local tmp_cat
    tmp_cat=$(mktemp -d)
    if git clone --depth=1 https://github.com/catppuccin/spicetify.git "$tmp_cat/catppuccin-spicetify" 2>/dev/null; then
        mkdir -p "$themes_dir/catppuccin"
        # Repo stores theme files directly at the root catppuccin/ directory
        local src_dir
        src_dir=$(find "$tmp_cat/catppuccin-spicetify" -name "color.ini" | head -1 | xargs dirname 2>/dev/null)
        if [[ -n "$src_dir" ]]; then
            cp "$src_dir/color.ini" "$src_dir/user.css" "$themes_dir/catppuccin/"
            print_success "Catppuccin Spicetify theme installed"
        else
            print_warning "Could not locate color.ini in catppuccin/spicetify repo"
        fi
    else
        print_warning "Could not clone catppuccin/spicetify (network issue?)"
    fi
    rm -rf "$tmp_cat"

    # ── Generate default Spicetify config & run initial backup + apply ────────
    print_step "Initialising Spicetify (backup + apply)…"

    # Make sure prefs_path is set correctly
    spicetify config prefs_path "$HOME/.config/spotify/prefs" 2>/dev/null

    # Backup original Spotify files
    spicetify backup 2>/dev/null

    # Apply default theme (Catppuccin mocha – matches YAHR default)
    local default_theme="catppuccin"
    local default_scheme="mocha"

    if [ ! -d "$themes_dir/$default_theme" ]; then
        # Fallback to Dribbblish if Catppuccin theme wasn't cloned
        default_theme="Dribbblish"
        default_scheme="base"
    fi

    spicetify config current_theme "$default_theme" 2>/dev/null
    spicetify config color_scheme "$default_scheme" 2>/dev/null
    spicetify config inject_theme_js 1 2>/dev/null

    # AUR spotify package requires explicit write permission on every apply
    sudo chmod a+wr /opt/spotify /opt/spotify/Apps -R 2>/dev/null

    if spicetify apply 2>/dev/null; then
        print_success "Spicetify applied: $default_theme ($default_scheme)"
    else
        print_warning "spicetify apply returned non-zero – Spotify may need to be opened once first"
        print_info "Re-run: spicetify backup apply"
    fi

    # ── Install sync script to live config ───────────────────────────────────
    local qs_config="$HOME/.config/quickshell"
    local sync_src="$SCRIPT_DIR/quickshell/sync-spicetify-theme.sh"
    if [ -f "$sync_src" ]; then
        cp "$sync_src" "$qs_config/sync-spicetify-theme.sh"
        chmod +x "$qs_config/sync-spicetify-theme.sh"
        print_success "Spicetify theme sync script installed"
    fi

    INSTALLED_COMPONENTS+=("Spotify + Spicetify")
    echo ""
    print_success "Spotify + Spicetify setup complete"
    print_info "Theme will sync automatically whenever you switch themes in YAHR."
    print_info "To re-apply manually: ~/.config/quickshell/sync-spicetify-theme.sh"
}

# Install optional extras
install_extras() {
    print_header "Optional Extras Installation"
    
    print_info "This setup includes configurations for optional applications."
    print_info "Would you like to install any of these?"
    echo ""
    
    # Neovim
    if ! command_exists "nvim"; then
        local neovim_choice="n"
        if [ "$YOLO_MODE" = true ]; then
            neovim_choice="y"
        else
            read -p "$(echo -e ${CYAN}?${NC}) Install Neovim (AstroVim config included)? (y/n): " neovim_choice
        fi
        
        if [[ "$neovim_choice" =~ ^[Yy]$ ]]; then
            print_step "Installing Neovim..."
            if command_exists "paru"; then
                paru -S --needed neovim
            elif command_exists "yay"; then
                yay -S --needed neovim
            else
                sudo pacman -S --needed neovim
            fi
            print_success "Neovim installed"
            INSTALLED_COMPONENTS+=("Neovim")
        else
            SKIPPED_COMPONENTS+=("Neovim")
        fi
    else
        print_info "Neovim already installed"
    fi
    
    # Vesktop (Discord)
    if ! command_exists "vesktop"; then
        local vesktop_choice="n"
        if [ "$YOLO_MODE" = true ]; then
            vesktop_choice="y"
        else
            read -p "$(echo -e ${CYAN}?${NC}) Install Vesktop (Discord client with Vencord)? (y/n): " vesktop_choice
        fi
        
        if [[ "$vesktop_choice" =~ ^[Yy]$ ]]; then
            print_step "Installing Vesktop..."
            if command_exists "paru"; then
                paru -S --needed vesktop-bin
            elif command_exists "yay"; then
                yay -S --needed vesktop-bin
            fi
            print_success "Vesktop installed"
            INSTALLED_COMPONENTS+=("Vesktop")
        else
            SKIPPED_COMPONENTS+=("Vesktop")
        fi
    else
        print_info "Vesktop already installed"
    fi
    
    # VS Code variants
    if ! command_exists "code" && ! command_exists "codium"; then
        local vscode_choice="4"
        if [ "$YOLO_MODE" = true ]; then
            vscode_choice="2"  # Default to VSCodium in YOLO mode
        else
            echo ""
            print_info "Which VS Code variant would you like to install?"
            echo "  1) Code OSS (Open source, from official repos)"
            echo "  2) VSCodium (Binary release, no telemetry)"
            echo "  3) Visual Studio Code (Microsoft build, with telemetry)"
            echo "  4) None - Skip installation"
            read -p "$(echo -e ${CYAN}?${NC}) Enter choice (1-4): " vscode_choice
        fi
        
        case "$vscode_choice" in
            1)
                print_step "Installing Code OSS..."
                sudo pacman -S --needed code
                print_success "Code OSS installed"
                INSTALLED_COMPONENTS+=("Code OSS")
                ;;
            2)
                print_step "Installing VSCodium..."
                if command_exists "paru"; then
                    paru -S --needed vscodium-bin
                elif command_exists "yay"; then
                    yay -S --needed vscodium-bin
                fi
                print_success "VSCodium installed"
                INSTALLED_COMPONENTS+=("VSCodium")
                ;;
            3)
                print_step "Installing Visual Studio Code..."
                if command_exists "paru"; then
                    paru -S --needed visual-studio-code-bin
                elif command_exists "yay"; then
                    yay -S --needed visual-studio-code-bin
                fi
                print_success "Visual Studio Code installed"
                INSTALLED_COMPONENTS+=("VS Code")
                ;;
            *)
                print_info "Skipping VS Code installation"
                SKIPPED_COMPONENTS+=("VS Code")
                ;;
        esac
    else
        print_info "VS Code variant already installed"
    fi
    
    echo ""
    print_success "Optional extras configuration complete"
}

# Install Sip StartPage browser start page
install_sip_startpage() {
    print_header "Sip StartPage Browser Start Page"

    local sip_dir="$HOME/Sip-StartPage"

    # Ask if user wants to install Sip StartPage
    local install_choice="n"
    if [ "$YOLO_MODE" = true ]; then
        install_choice="y"
    else
        echo ""
        print_info "Sip StartPage is a beautiful browser homepage."
        echo ""
        read -p "$(echo -e ${CYAN}?${NC}) Install Sip StartPage browser start page? (y/n): " install_choice
    fi

    if [[ ! "$install_choice" =~ ^[Yy]$ ]]; then
        print_info "Skipping Sip StartPage installation"
        SKIPPED_COMPONENTS+=("Sip StartPage")
        return
    fi

    # Check if git is available
    if ! command_exists git; then
        print_error "git is required to install Sip StartPage but was not found"
        return 1
    fi

    # Check if already exists
    if [ -d "$sip_dir" ]; then
        print_warning "Sip StartPage directory already exists at $sip_dir"
        local overwrite="n"
        if [ "$YOLO_MODE" = true ]; then
            print_info "YOLO mode: Pulling latest changes"
            overwrite="y"
        else
            read -p "$(echo -e ${CYAN}?${NC}) Update existing Sip StartPage? (y/n): " overwrite
        fi

        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
            print_step "Updating Sip StartPage..."
            git -C "$sip_dir" pull && print_success "Sip StartPage updated"
        else
            print_info "Skipping Sip StartPage update"
            SKIPPED_COMPONENTS+=("Sip StartPage")
        fi
        return
    fi

    # Clone from GitHub
    print_step "Cloning Sip StartPage from GitHub..."
    git clone https://github.com/bgibson72/Sip-StartPage.git "$sip_dir"

    if [ $? -eq 0 ]; then
        print_success "Sip StartPage installed to $sip_dir"
        echo ""
        print_info "To use Sip StartPage, set your browser's homepage to:"
        echo "  file://$sip_dir/index.html"
        echo ""
        INSTALLED_COMPONENTS+=("Sip StartPage")
    else
        print_error "Failed to clone Sip StartPage"
        return 1
    fi
}

# Configure Hyprland autostart
# Enable system services
enable_services() {
    print_header "Enabling System Services"
    
    # Enable Bluetooth service
    if command_exists "bluetoothctl"; then
        print_info "Enabling Bluetooth service..."
        sudo systemctl enable bluetooth.service
        if [ $? -eq 0 ]; then
            print_success "Bluetooth service enabled"
            print_info "Starting Bluetooth service..."
            sudo systemctl start bluetooth.service 2>/dev/null && print_success "Bluetooth service started" || print_info "Bluetooth will start on next boot"
        else
            print_warning "Failed to enable Bluetooth service"
        fi
    fi
    
    # Enable NetworkManager service
    if command_exists "nmcli"; then
        print_info "Enabling NetworkManager service..."
        sudo systemctl enable NetworkManager.service
        if [ $? -eq 0 ]; then
            print_success "NetworkManager service enabled"
            # Start if not already running
            if ! systemctl is-active --quiet NetworkManager.service; then
                print_info "Starting NetworkManager service..."
                sudo systemctl start NetworkManager.service 2>/dev/null && print_success "NetworkManager service started" || print_info "NetworkManager will start on next boot"
            fi
        else
            print_warning "Failed to enable NetworkManager service"
        fi
    fi
}

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
    echo "  1. Reboot your system"
    echo "  2. Log into Hyprland"
    echo "  3. YahrShell will start automatically"
    echo "  4. Try switching themes with Super+T"
    echo "  5. Open app launcher with Super+A"
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
    parse_args "$@"

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

    if [ "$DRY_RUN" = true ]; then
        print_success "Dry run complete"
        print_info "Reviewed prompts and pre-flight checks without making changes"
        return 0
    fi
    
    # Run installation steps in order
    # Note: check_dependencies must come before install_gpu_drivers (needs AUR helper)
    check_dependencies
    install_gpu_drivers
    install_configs
    install_starship
    create_settings
    fix_permissions
    setup_papirus
    enable_services
    configure_hyprland
    initialize_wallpaper
    apply_default_theme
    test_theme_switching
    
    # Optional components (full mode only)
    if [ "$INSTALL_MODE" = "full" ]; then
        install_firefox
        install_sddm
        install_plymouth
    fi
    
    install_gtk_themes
    install_extras
    install_spotify_spicetify
    install_sip_startpage
    
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
        echo "  1. Reboot your system (required for GPU drivers to load)"
    else
        echo "  1. Reboot your system (recommended)"
    fi
    echo "  2. Log into Hyprland"
    echo "  3. YahrShell will start automatically"
    echo ""
    
    # Prompt for reboot
    if [ "$YOLO_MODE" = false ]; then
        read -p "Would you like to reboot now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Rebooting system..."
            sudo reboot
        else
            print_info "Remember to reboot to complete setup"
        fi
    else
        print_info "YOLO mode: Skipping reboot prompt"
        print_warning "Please reboot to complete setup"
    fi
    
    echo ""
}

# Run main function
main "$@"
