# Quickshell Installation Fixes - Implementation Guide

This document outlines the fixes needed for the YAHR Quickshell installation script.

## 1. Add Pacseek to Package Installation

**Issue**: Pacseek needs to be installed and properly configured to launch from app launcher.

**Solution**: Add to the missing_critical array check around line 690:

```bash
if ! command_exists "pacseek"; then
    missing_critical+=("pacseek")
fi
```

**Note**: Pacseek terminal launch fix was already completed earlier (kitty -e wrapper).

## 2. Initialize Catppuccin Theme on First Boot

**Location**: Around line 1220 in `initialize_wallpaper()` function

**Current**: Sets catppuccin wallpaper but doesn't initialize theme completely

**Fix Needed**:
- Call theme initialization script after wallpaper setup
- Ensure Catppuccin theme is set as default in hyprland.conf
- Run sync scripts for all applications

**Add after wallpaper initialization**:
```bash
# Initialize Catppuccin theme as default
print_info "Setting Catppuccin as default theme..."
if [ -f "$HOME/.config/hypr/themes/Catppuccin.conf" ]; then
    # Set in hyprland.conf
    sed -i 's|^source.*themes.*\.conf|source = '"$HOME"'/.config/hypr/themes/Catppuccin.conf|' "$HOME/.config/hypr/hyprland.conf" 2>/dev/null || \
        echo "source = $HOME/.config/hypr/themes/Catppuccin.conf" >> "$HOME/.config/hypr/hyprland.conf"
    
    # Run theme sync scripts
    [ -x "$HOME/.config/quickshell/sync-kitty-theme.sh" ] && "$HOME/.config/quickshell/sync-kitty-theme.sh" >/dev/null 2>&1
    [ -x "$HOME/.config/quickshell/sync-nvim-theme.sh" ] && "$HOME/.config/quickshell/sync-nvim-theme.sh" >/dev/null 2>&1
    [ -x "$HOME/.config/quickshell/sync-firefox-theme.sh" ] && "$HOME/.config/quickshell/sync-firefox-theme.sh" >/dev/null 2>&1
    [ -x "$HOME/.config/quickshell/sync-gtk-theme.sh" ] && "$HOME/.config/quickshell/sync-gtk-theme.sh" >/dev/null 2>&1
    
    print_success "Catppuccin theme initialized"
fi
```

## 3. Copy GTK Themes to ~/.themes

**Location**: Around line 1198 in `install_gtk_themes()` function

**Current**: Only creates directories, doesn't copy themes

**Fix**: Add theme copying after directory creation:

```bash
# Install GTK themes
install_gtk_themes() {
    print_header "GTK Theme Setup"
    
    print_info "Setting up GTK theme directories..."
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.icons"
    
    # Copy GTK themes from repo
    if [ -d "$SCRIPT_DIR/quickshell/gtk-themes" ]; then
        print_step "Installing GTK themes..."
        cp -r "$SCRIPT_DIR/quickshell/gtk-themes/"* "$HOME/.themes/"
        print_success "GTK themes installed to ~/.themes"
    fi
    
    print_info "Installed GTK themes will automatically sync with your Quickshell theme."
    print_success "GTK theme system configured"
}
```

## 4. Fix Weather Icons in Calendar Widget

**Issue**: Calendar widget shows black/white weather icons instead of colored emojis

**Root Cause**: Qt doesn't render colored emojis by default. The weather icons from wttr.in are emojis that need proper font support.

**Solution**: Install Noto Color Emoji font and configure Qt to use it

**Fix in install.sh** (add to package checks around line 710):
```bash
# Check for emoji font
if ! fc-list | grep -qi "noto.*color.*emoji"; then
    missing_critical+=("noto-fonts-emoji")
fi
```

**Additional Configuration** (add to install_gtk_themes function):
```bash
# Configure fontconfig for emoji support
mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Use Noto Color Emoji for emoji characters -->
  <match>
    <test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
</fontconfig>
EOF
print_success "Emoji font configuration created"
```

## 5. Add Extras Installation Prompts

**Location**: Add new function before main installation flow (around line 1300)

**New Function**:
```bash
# Install optional extras
install_extras() {
    print_header "Optional Extras Installation"
    
    print_info "This setup includes configurations for optional applications."
    print_info "Would you like to install any of these?"
    echo ""
    
    # Neovim
    if ! command_exists "nvim"; then
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
```

**Call Location**: Add to main installation flow around line 1600, before final summary:
```bash
# Install optional extras
if [ "$INSTALL_MODE" = "full" ]; then
    install_extras
fi
```

## Implementation Order

1. Add pacseek to package checks (simple)
2. Fix GTK themes copying (simple)
3. Add theme initialization for Catppuccin (medium)
4. Investigate and fix weather icons (needs investigation)
5. Add extras installation function (medium)

## Files to Check for Weather Icons

- `quickshell/CalendarWidget.qml`
- May need additional weather icon package from AUR

