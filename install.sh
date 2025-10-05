#!/bin/bash

# versionzero - Unified Arch Linux Rice Installer
# Supports full installation and config-only updates
# Repository: https://github.com/LortBree/versionzero.git

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/LortBree/versionzero.git"
REPO_DIR="/tmp/versionzero"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Installation mode (will be set by user)
MODE=""

# Logging
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
success() { echo -e "${CYAN}[SUCCESS]${NC} $1"; }

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
╔══════════════════════════════════════════════════╗
║                                                  ║
║            versionzero - Arch Linux              ║
║         Hyprland Rice Installer v1.0             ║
║                                                  ║
╚══════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root! Run as normal user."
    fi
}

# Check internet connection
check_internet() {
    log "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        error "No internet connection. Please check your network."
    fi
    success "Internet connection OK"
}

# Detect installation mode
detect_mode() {
    # Check for command line flag
    if [[ "$1" == "--update" ]] || [[ "$1" == "-u" ]]; then
        MODE="update"
        log "Update mode enabled (config only)"
        return
    fi
    
    # Interactive mode selection
    echo -e "${BLUE}Installation Mode:${NC}"
    echo "1) Full install - Packages + Configuration (first time)"
    echo "2) Update config - Replace configuration files only"
    echo
    read -p "Choose mode [1/2]: " mode_choice
    
    case "$mode_choice" in
        2)
            MODE="update"
            log "Update mode selected"
            ;;
        *)
            MODE="full"
            log "Full installation mode selected"
            ;;
    esac
}

# Update system
update_system() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm
    success "System updated"
}

# Install core packages
install_core_packages() {
    log "Installing core packages..."
    
    local core_packages=(
        # Base & Build tools
        "base-devel"
        "git"
        "wget"
        "curl"
        
        # Hyprland & Wayland
        "hyprland"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
        
        # Display Manager
        "sddm"
        
        # Status Bar & Widgets
        "waybar"
        
        # Launcher & UI
        "wofi"
        
        # Notifications
        "mako"
        
        # Screen Lock & Idle
        "swaylock"
        "swayidle"
        
        # Wallpaper
        "swww"
        
        # Terminal Emulators
        "foot"
        "kitty"
        "alacritty"
        
        # Shell & Prompt
        "fish"
        "starship"
        
        # System Tools
        "btop"
        "fastfetch"
        "cava"
        
        # Audio
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "wireplumber"
        "pamixer"
        "playerctl"
        "pavucontrol"
        
        # Brightness & Power
        "brightnessctl"
        "cpupower"
        
        # Clipboard
        "wl-clipboard"
        
        # Screenshot
        "grim"
        "slurp"
        
        # File Manager
        "thunar"
        "thunar-archive-plugin"
        "file-roller"
        
        # Fonts
        "ttf-dejavu"
        "ttf-liberation"
        "noto-fonts"
        "noto-fonts-emoji"
        "ttf-material-design-icons-extended"
        
        # Python (for scripts)
        "python"
        "python-pip"
        
        # Network
        "networkmanager"
        "network-manager-applet"
        
        # Bluetooth
        "bluez"
        "bluez-utils"
        "blueman"
        
        # Authentication
        "polkit-kde-agent"
        
        # JSON processor
        "jq"
        
        # Night light
        "gammastep"
        
        # System monitoring
        "lm_sensors"
        "sysstat"
        
        # GTK theme tools
        "nwg-look"
        
        # Utilities
        "unzip"
        "zip"
        "tar"
        "xz"
    )
    
    for package in "${core_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log "Installing $package..."
            sudo pacman -S --noconfirm "$package" || warn "Failed to install $package"
        else
            log "$package already installed"
        fi
    done
    
    success "Core packages installed"
}

# Install AUR helper (yay)
install_aur_helper() {
    if command -v yay &>/dev/null; then
        log "yay is already installed"
        return 0
    fi
    
    log "Installing yay (AUR helper)..."
    
    local yay_dir="/tmp/yay"
    rm -rf "$yay_dir"
    
    git clone https://aur.archlinux.org/yay.git "$yay_dir"
    cd "$yay_dir"
    makepkg -si --noconfirm
    cd -
    rm -rf "$yay_dir"
    
    success "yay installed"
}

# Install AUR packages
install_aur_packages() {
    log "Installing AUR packages..."
    
    local aur_packages=(
        # EWW widgets
        "eww"
        
        # Nerd Fonts
        "ttf-jetbrains-mono-nerd"
        
        # Power menu
        "wlogout"
        
        # Clipboard manager
        "cliphist"
        
        # SDDM Theme
        "sddm-sugar-candy-git"
    )
    
    for package in "${aur_packages[@]}"; do
        if ! yay -Q "$package" &>/dev/null; then
            log "Installing $package from AUR..."
            yay -S --noconfirm "$package" || warn "Failed to install $package"
        else
            log "$package already installed"
        fi
    done
    
    success "AUR packages installed"
}

# Interactive optional apps installation
install_optional_apps() {
    echo
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Optional Applications Installation     ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo
    
    read -p "Install Firefox browser? [Y/n]: " install_firefox
    if [[ ! "$install_firefox" =~ ^[Nn]$ ]]; then
        sudo pacman -S --noconfirm firefox
        log "Firefox installed"
    fi
    
    read -p "Install Spotify? [Y/n]: " install_spotify
    if [[ ! "$install_spotify" =~ ^[Nn]$ ]]; then
        yay -S --noconfirm spotify
        log "Spotify installed"
    fi
    
    read -p "Install Discord? [Y/n]: " install_discord
    if [[ ! "$install_discord" =~ ^[Nn]$ ]]; then
        sudo pacman -S --noconfirm discord
        log "Discord installed"
    fi
    
    read -p "Install Visual Studio Code? [Y/n]: " install_vscode
    if [[ ! "$install_vscode" =~ ^[Nn]$ ]]; then
        yay -S --noconfirm visual-studio-code-bin
        log "VS Code installed"
    fi
    
    read -p "Install Zen Browser? [y/N]: " install_zen
    if [[ "$install_zen" =~ ^[Yy]$ ]]; then
        yay -S --noconfirm zen-browser-bin
        log "Zen Browser installed"
    fi
    
    success "Optional apps installation completed"
}

# Ask for backup
ask_backup() {
    echo
    echo -e "${YELLOW}Backup existing configuration?${NC}"
    echo "Your current config will be saved before replacement."
    echo
    read -p "Create backup? [Y/n]: " do_backup
    
    if [[ "$do_backup" =~ ^[Nn]$ ]]; then
        warn "Backup disabled - existing configs will be deleted!"
        read -p "Are you sure? This cannot be undone! [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log "Enabling backup for safety"
            BACKUP_ENABLED=true
        else
            BACKUP_ENABLED=false
        fi
    else
        BACKUP_ENABLED=true
    fi
}

# Backup existing configs
backup_existing_configs() {
    if [[ "$BACKUP_ENABLED" != true ]]; then
        warn "Skipping backup (user choice)"
        return
    fi
    
    log "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    local dirs=(
        "colors" "hypr" "waybar" "eww" "scripts"
        "wofi" "wlogout" "mako" "swaylock" "swayidle"
        "alacritty" "kitty" "foot" "fish"
        "btop" "cava" "fastfetch"
    )
    
    local has_backup=false
    
    for dir in "${dirs[@]}"; do
        if [[ -e "$CONFIG_DIR/$dir" ]]; then
            cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/" 2>/dev/null || true
            has_backup=true
        fi
    done
    
    if [[ -f "$CONFIG_DIR/starship.toml" ]]; then
        cp "$CONFIG_DIR/starship.toml" "$BACKUP_DIR/"
        has_backup=true
    fi
    
    if [[ "$has_backup" == true ]]; then
        success "Backup saved to $BACKUP_DIR"
    else
        log "No existing config found to backup"
    fi
}

# Remove old configs
remove_old_configs() {
    log "Removing old configuration directories..."
    
    local dirs=(
        "colors" "hypr" "waybar" "eww" "scripts"
        "wofi" "wlogout" "mako" "swaylock" "swayidle"
        "alacritty" "kitty" "foot" "fish"
        "btop" "cava" "fastfetch"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -e "$CONFIG_DIR/$dir" ]]; then
            rm -rf "$CONFIG_DIR/$dir"
            log "Removed: $dir"
        fi
    done
    
    if [[ -f "$CONFIG_DIR/starship.toml" ]]; then
        rm -f "$CONFIG_DIR/starship.toml"
        log "Removed: starship.toml"
    fi
    
    success "Old configs removed"
}

# Clone dotfiles repository
clone_dotfiles() {
    log "Cloning versionzero dotfiles..."
    
    rm -rf "$REPO_DIR"
    
    if ! git clone "$REPO_URL" "$REPO_DIR"; then
        error "Failed to clone repository. Check your internet connection."
    fi
    
    success "Dotfiles cloned to $REPO_DIR"
}

# Deploy dotfiles
deploy_dotfiles() {
    log "Deploying dotfiles..."
    
    mkdir -p "$CONFIG_DIR"
    
    if [[ -d "$REPO_DIR/config" ]]; then
        log "Copying config files to $CONFIG_DIR..."
        cp -r "$REPO_DIR/config/"* "$CONFIG_DIR/"
        success "Config files deployed"
    else
        error "Config directory not found in repository"
    fi
    
    if [[ -d "$REPO_DIR/home" ]]; then
        log "Copying home files..."
        cp -r "$REPO_DIR/home/".* "$HOME/" 2>/dev/null || true
    fi
    
    # Deploy assets
    log "Deploying assets..."
    
    # Copy wallpapers
    if [[ -d "$REPO_DIR/assets/wallpapers" ]]; then
        mkdir -p "$HOME/Pictures/Wallpapers"
        cp -r "$REPO_DIR/assets/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
        log "Sample wallpapers copied to ~/Pictures/Wallpapers"
    else
        warn "No wallpapers found in repo - solid color fallback will be used"
    fi
    
    # Copy wlogout icons
    if [[ -d "$REPO_DIR/assets/wlogout" ]]; then
        # Copy to system location (requires sudo) for compatibility
        log "Installing wlogout icons to system location..."
        sudo mkdir -p /usr/local/share/wlogout/icons
        sudo cp -r "$REPO_DIR/assets/wlogout/"* /usr/local/share/wlogout/icons/ 2>/dev/null || true
        log "Wlogout icons installed to /usr/local/share/wlogout/icons"
    else
        warn "No wlogout icons found - power menu will use fallback icons"
    fi
    
    mkdir -p "$HOME/Pictures/Screenshots"
    
    success "Dotfiles deployed"
}

# Make all scripts executable
make_scripts_executable() {
    log "Making scripts executable..."
    
    find "$CONFIG_DIR" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    success "All scripts are executable"
}

# Initialize theme system
initialize_theme() {
    log "Initializing theme system..."
    
    # Ensure directories exist
    mkdir -p "$CONFIG_DIR/colors"
    mkdir -p "$CONFIG_DIR/waybar"
    mkdir -p "$CONFIG_DIR/eww"
    mkdir -p "$CONFIG_DIR/mako"
    mkdir -p "$CONFIG_DIR/alacritty"
    
    # Create symlink for current theme
    if [[ -f "$CONFIG_DIR/colors/theme1.conf" ]]; then
        ln -sf "$CONFIG_DIR/colors/theme1.conf" "$CONFIG_DIR/colors/current-theme.conf"
        success "Theme symlink created"
    else
        error "Theme files not found. Deployment may have failed."
    fi
    
    # Run theme switcher to generate CSS files (suppress errors for fresh install)
    if [[ -f "$CONFIG_DIR/scripts/theme-switcher.sh" ]]; then
        log "Generating theme CSS files..."
        bash "$CONFIG_DIR/scripts/theme-switcher.sh" theme1 2>&1 | grep -v "Failed to" || true
        success "Default theme applied (Midnight Elegance)"
    else
        warn "Theme switcher not found - CSS files will be generated on first Hyprland start"
    fi
    
    # Create default alacritty colors if theme-switcher didn't run
    if [[ ! -f "$CONFIG_DIR/alacritty/colors.toml" ]]; then
        log "Creating default Alacritty colors..."
        cat > "$CONFIG_DIR/alacritty/colors.toml" << 'EOF'
# Default colors - Midnight Elegance
[colors.primary]
background = "#1F1C2C"
foreground = "#FFFFFF"

[colors.normal]
black = "#1F1C2C"
red = "#F44336"
green = "#4CAF50"
yellow = "#FFC107"
blue = "#928DAB"
magenta = "#D76D77"
cyan = "#4CA1AF"
white = "#FFFFFF"

[colors.bright]
black = "#928DAB"
red = "#FF5252"
green = "#69F0AE"
yellow = "#FFD740"
blue = "#B4AFCF"
magenta = "#FF8A9B"
cyan = "#84D6DF"
white = "#FFFFFF"
EOF
    fi
}

# Setup SDDM
setup_sddm() {
    log "Setting up SDDM display manager..."
    
    sudo systemctl enable sddm
    
    if [[ -d "/usr/share/sddm/themes/sugar-candy" ]]; then
        log "Configuring Sugar Candy theme..."
        sudo tee /etc/sddm.conf > /dev/null << EOF
[Theme]
Current=sugar-candy

[General]
InputMethod=
EOF
    fi
    
    success "SDDM configured"
}

# Enable services
enable_services() {
    log "Enabling system services..."
    
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    sudo systemctl enable cpupower
    
    # Create sudoers file for passwordless cpupower
    log "Configuring passwordless sudo for performance mode..."
    sudo tee /etc/sudoers.d/10-versionzero > /dev/null << 'EOF'
# VersionZero - Passwordless sudo for performance mode
%wheel ALL=(ALL) NOPASSWD: /usr/bin/cpupower
%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
EOF
    sudo chmod 0440 /etc/sudoers.d/10-versionzero
    
    success "Services enabled"
}

# Setup default shell
setup_shell() {
    echo
    read -p "Set Fish as default shell? [Y/n]: " use_fish
    
    if [[ ! "$use_fish" =~ ^[Nn]$ ]]; then
        log "Setting Fish as default shell..."
        chsh -s /usr/bin/fish
        success "Fish shell set as default"
    fi
}

# Reload services (for update mode)
reload_services() {
    log "Reloading services..."
    
    # Reload Hyprland config
    if pidof -x Hyprland > /dev/null; then
        hyprctl reload || warn "Failed to reload Hyprland"
    fi
    
    # Restart Waybar
    if pidof -x waybar > /dev/null; then
        pkill waybar
        waybar &
        disown
    fi
    
    # Reload EWW
    if pidof -x eww > /dev/null; then
        eww reload || warn "Failed to reload EWW"
    fi
    
    # Restart Mako
    if pidof -x mako > /dev/null; then
        makoctl reload || warn "Failed to reload Mako"
    fi
    
    success "Services reloaded"
}

# Final message
show_completion() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                  ║${NC}"
    echo -e "${GREEN}║        INSTALLATION COMPLETED SUCCESSFULLY!      ║${NC}"
    echo -e "${GREEN}║                                                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo
    success "versionzero rice has been installed!"
    echo
    
    if [[ "$BACKUP_ENABLED" == true ]] && [[ -d "$BACKUP_DIR" ]]; then
        log "Backup location: $BACKUP_DIR"
    fi
    
    echo
    log "Important Keybindings:"
    echo "  Super + Q          → Terminal"
    echo "  Super + C          → Close window"
    echo "  Super + R          → Launcher"
    echo "  Super + L          → Lock screen"
    echo "  Super + Shift + E  → Power menu"
    echo "  Super + E          → File manager"
    echo "  Super + A          → Toggle dock (left sidebar)"
    echo "  Super + D          → Toggle dashboard (right sidebar)"
    echo "  Super + T          → Cycle themes"
    echo "  Super + W          → Wallpaper selector"
    echo "  Super + N          → Toggle night light"
    echo "  Super + G          → Cycle performance modes"
    echo "  Print              → Screenshot (area)"
    echo
    log "Available themes:"
    echo "  • Midnight Elegance (default) - Deep purple-gray"
    echo "  • Ocean Breeze - Fresh blue-cyan"
    echo "  • Cyberpunk Dreams - Bold purple-pink"
    echo
    log "Theme switching:"
    echo "  Terminal: theme [1|2|3|next|midnight|ocean|cyberpunk]"
    echo "  GUI: Press Super+T or click Theme Switch in dashboard"
    echo
    
    if [[ "$MODE" == "full" ]]; then
        warn "Please reboot to complete installation!"
        echo
        read -p "Reboot now? [Y/n]: " do_reboot
        
        if [[ ! "$do_reboot" =~ ^[Nn]$ ]]; then
            log "Rebooting..."
            sleep 2
            reboot
        fi
    else
        success "Configuration updated! Changes applied to running session."
        log "No reboot needed - services have been reloaded."
    fi
}

# Main installation flow
main() {
    show_banner
    
    check_root
    detect_mode "$@"
    
    echo
    echo -e "${YELLOW}Installation Summary:${NC}"
    if [[ "$MODE" == "full" ]]; then
        echo "  Mode: Full installation"
        echo "  • Update system packages"
        echo "  • Install Hyprland and dependencies"
        echo "  • Install EWW, Waybar, and UI tools"
        echo "  • Deploy configuration files"
        echo "  • Setup SDDM display manager"
        echo "  • Enable system services"
    else
        echo "  Mode: Update configuration only"
        echo "  • Backup existing config (optional)"
        echo "  • Remove old config directories"
        echo "  • Deploy new configuration files"
        echo "  • Reload running services"
        echo "  • No package installation"
        echo "  • No reboot required"
    fi
    echo
    
    read -p "Continue? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        log "Installation cancelled"
        exit 0
    fi
    
    echo
    log "Starting installation..."
    sleep 2
    
    if [[ "$MODE" == "full" ]]; then
        check_internet
        update_system
        install_core_packages
        install_aur_helper
        install_aur_packages
        install_optional_apps
    fi
    
    ask_backup
    backup_existing_configs
    remove_old_configs
    clone_dotfiles
    deploy_dotfiles
    make_scripts_executable
    initialize_theme
    
    if [[ "$MODE" == "full" ]]; then
        setup_sddm
        enable_services
        setup_shell
    else
        reload_services
    fi
    
    show_completion
}

# Trap errors
trap 'error "Installation failed at line $LINENO"' ERR

# Run main function
main "$@"