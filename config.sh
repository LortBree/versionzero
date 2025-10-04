#!/bin/bash

# versionzero - Interactive Arch Linux System Configuration
# Run this script inside arch-chroot /mnt after mounting partitions
# Usage: ./config.sh

set -e  # Exit on any error

# Color codes for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
DEFAULT_HOSTNAME="archlinux"
DEFAULT_USERNAME="user"
DEFAULT_LOCALE="en_US.UTF-8"
DEFAULT_TIMEZONE="Asia/Jakarta"

# Logging helpers
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

# Check if running in chroot
if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
    log "Running in chroot environment ✓"
else
    error "This script must be run inside arch-chroot /mnt"
fi

# Welcome banner
echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║        versionzero - Arch Linux Setup    ║${NC}"
echo -e "${PURPLE}║                Configuration             ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
echo

# ======== User Input Section ========

# Hostname
echo -e "${BLUE}1. System Hostname${NC}"
read -p "Enter hostname [${DEFAULT_HOSTNAME}]: " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}
echo

# Username
echo -e "${BLUE}2. User Account${NC}"
read -p "Enter username [${DEFAULT_USERNAME}]: " USERNAME
USERNAME=${USERNAME:-$DEFAULT_USERNAME}
echo

# Validate username
if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    warn "Username should be lowercase, start with letter/underscore, max 32 chars"
    read -p "Enter valid username: " USERNAME
fi

# Root password
echo -e "${BLUE}3. Root Password${NC}"
while true; do
    read -s -p "Enter root password: " ROOT_PASS
    echo
    read -s -p "Confirm root password: " ROOT_PASS2
    echo
    if [[ "$ROOT_PASS" == "$ROOT_PASS2" ]]; then
        if [[ ${#ROOT_PASS} -lt 6 ]]; then
            warn "Password too short (minimum 6 characters)"
            continue
        fi
        break
    else
        warn "Passwords do not match. Please try again."
    fi
done
echo

# User password
echo -e "${BLUE}4. User Password${NC}"
while true; do
    read -s -p "Enter password for user '$USERNAME': " USER_PASS
    echo
    read -s -p "Confirm user password: " USER_PASS2
    echo
    if [[ "$USER_PASS" == "$USER_PASS2" ]]; then
        if [[ ${#USER_PASS} -lt 6 ]]; then
            warn "Password too short (minimum 6 characters)"
            continue
        fi
        break
    else
        warn "Passwords do not match. Please try again."
    fi
done
echo

# Locale selection
echo -e "${BLUE}5. System Locale${NC}"
echo "Available locales:"
echo "  1) en_US.UTF-8 (English)"
echo "  2) id_ID.UTF-8 (Indonesian)"
echo "  3) Other (manual input)"
read -p "Choose locale [1]: " LOCALE_CHOICE
case "$LOCALE_CHOICE" in
    2) 
        LOCALE="id_ID.UTF-8"
        ;;
    3)
        read -p "Enter locale (e.g., de_DE.UTF-8): " LOCALE
        LOCALE=${LOCALE:-$DEFAULT_LOCALE}
        ;;
    *)
        LOCALE="en_US.UTF-8"
        ;;
esac
echo

# Timezone selection
echo -e "${BLUE}6. System Timezone${NC}"
echo "Common timezones:"
echo "  1) Asia/Jakarta"
echo "  2) UTC"
echo "  3) Asia/Singapore"
echo "  4) Europe/London"
echo "  5) America/New_York"
echo "  6) Other (manual input)"
read -p "Choose timezone [1]: " TZ_CHOICE
case "$TZ_CHOICE" in
    2) TIMEZONE="UTC" ;;
    3) TIMEZONE="Asia/Singapore" ;;
    4) TIMEZONE="Europe/London" ;;
    5) TIMEZONE="America/New_York" ;;
    6)
        echo "Available timezones (showing Asia region):"
        ls /usr/share/zoneinfo/Asia/ | head -20 | column -c 80
        echo "..."
        read -p "Enter timezone (e.g., Asia/Tokyo): " TIMEZONE
        TIMEZONE=${TIMEZONE:-$DEFAULT_TIMEZONE}
        ;;
    *)
        TIMEZONE="Asia/Jakarta"
        ;;
esac

# Validate timezone
if [[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    warn "Timezone '$TIMEZONE' not found, using default"
    TIMEZONE="$DEFAULT_TIMEZONE"
fi
echo

# Shell selection
echo -e "${BLUE}7. Default Shell${NC}"
echo "Available shells:"
echo "  1) bash (default)"
echo "  2) fish (modern shell with auto-suggestions)"
echo "  3) zsh (powerful shell with plugins)"
read -p "Choose shell [1]: " SHELL_CHOICE
case "$SHELL_CHOICE" in
    2) 
        USER_SHELL="fish"
        SHELL_PATH="/usr/bin/fish"
        ;;
    3) 
        USER_SHELL="zsh"
        SHELL_PATH="/usr/bin/zsh"
        ;;
    *)
        USER_SHELL="bash"
        SHELL_PATH="/bin/bash"
        ;;
esac
echo

# GRUB installation
echo -e "${BLUE}8. Bootloader (GRUB)${NC}"
read -p "Install GRUB bootloader? [Y/n]: " INSTALL_GRUB
INSTALL_GRUB=${INSTALL_GRUB,,}  # lowercase
if [[ "$INSTALL_GRUB" =~ ^n ]]; then
    INSTALL_GRUB="no"
else
    INSTALL_GRUB="yes"
fi
echo

# Configuration summary
echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║            Configuration Summary         ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
echo -e "Hostname:    ${CYAN}$HOSTNAME${NC}"
echo -e "Username:    ${CYAN}$USERNAME${NC}"
echo -e "Locale:      ${CYAN}$LOCALE${NC}"
echo -e "Timezone:    ${CYAN}$TIMEZONE${NC}"
echo -e "Shell:       ${CYAN}$USER_SHELL${NC}"
echo -e "Install GRUB: ${CYAN}$INSTALL_GRUB${NC}"
echo

read -p "Continue with this configuration? [Y/n]: " CONFIRM
if [[ "$CONFIRM" =~ ^[Nn] ]]; then
    error "Configuration cancelled by user"
fi

echo
log "Starting system configuration..."

# ======== Apply Configuration ========

# 1. Set hostname
log "Setting hostname to '$HOSTNAME'..."
echo "$HOSTNAME" > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
success "Hostname configured"

# 2. Set timezone
log "Setting timezone to '$TIMEZONE'..."
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
success "Timezone configured"

# 3. Configure locale
log "Setting up locale '$LOCALE'..."
sed -i "s/^#$LOCALE/$LOCALE/" /etc/locale.gen

# Also enable en_US.UTF-8 if different locale is chosen
if [[ "$LOCALE" != "en_US.UTF-8" ]]; then
    sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
fi

locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
success "Locale configured"

# 4. Set root password
log "Setting root password..."
echo "root:$ROOT_PASS" | chpasswd
success "Root password set"

# 5. Install shell if needed
shell_packages=()
case "$USER_SHELL" in
    fish)
        if ! pacman -Q fish &>/dev/null; then
            shell_packages+=("fish")
        fi
        ;;
    zsh)
        if ! pacman -Q zsh &>/dev/null; then
            shell_packages+=("zsh" "zsh-completions")
        fi
        ;;
esac

if [[ ${#shell_packages[@]} -gt 0 ]]; then
    log "Installing shell packages: ${shell_packages[*]}"
    pacman -S --noconfirm "${shell_packages[@]}"
fi

# Verify shell exists
if [[ ! -x "$SHELL_PATH" ]]; then
    warn "Shell $SHELL_PATH not found, falling back to bash"
    USER_SHELL="bash"
    SHELL_PATH="/bin/bash"
fi

# 6. Create user account
log "Creating user account '$USERNAME' with shell '$USER_SHELL'..."
useradd -m -G wheel,audio,video,optical,storage -s "$SHELL_PATH" "$USERNAME"
echo "$USERNAME:$USER_PASS" | chpasswd
success "User account created"

# 7. Configure sudo
log "Configuring sudo access..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
success "Sudo configured for wheel group"

# 8. Create user directories
log "Creating user directories..."
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME"/{Downloads,Documents,Pictures,Videos,Music}

# 9. Set up shell configuration
log "Setting up shell configuration..."
case "$USER_SHELL" in
    bash)
        sudo -u "$USERNAME" cp /etc/skel/.bashrc "/home/$USERNAME/"
        sudo -u "$USERNAME" cp /etc/skel/.bash_profile "/home/$USERNAME/" 2>/dev/null || true
        ;;
    fish)
        sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.config/fish"
        sudo -u "$USERNAME" tee "/home/$USERNAME/.config/fish/config.fish" > /dev/null << 'EOF'
# Fish shell configuration for versionzero
set fish_greeting "Welcome to Fish shell! 🐠"

# Common aliases
alias ll "ls -la"
alias la "ls -A"
alias l "ls -CF"
alias grep "grep --color=auto"
alias ..  "cd .."
alias ... "cd ../.."

# Add ~/bin to PATH if it exists
if test -d ~/bin
    set -gx PATH ~/bin $PATH
end

# Colorful prompt
set -g fish_color_command blue --bold
set -g fish_color_error red --bold
set -g fish_color_param cyan
EOF
        ;;
    zsh)
        sudo -u "$USERNAME" tee "/home/$USERNAME/.zshrc" > /dev/null << 'EOF'
# Zsh configuration for versionzero
autoload -Uz compinit
compinit

# History configuration  
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Basic aliases
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias .. "cd .."
alias ... "cd ../.."

# Enable colors and better prompt
autoload -U colors && colors
PS1="%{$fg[green]%}%n@%m:%{$fg[blue]%}%~%{$reset_color%}$ "

# Auto-completion enhancements
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
EOF
        ;;
esac
success "Shell configuration created"

# 10. Install essential packages
log "Installing essential packages..."
essential_packages=(
    "sudo"
    "nano"
    "vim"
    "wget"
    "curl"
    "git"
    "man-db"
    "man-pages"
    "bash-completion"
    "networkmanager"
    "base-devel"
)

for package in "${essential_packages[@]}"; do
    if ! pacman -Q "$package" &>/dev/null; then
        pacman -S --noconfirm "$package" || warn "Failed to install $package"
    fi
done
success "Essential packages installed"

# 11. GRUB Installation
if [[ "$INSTALL_GRUB" == "yes" ]]; then
    log "Installing GRUB bootloader..."
    
    # Install GRUB package if not present
    if ! pacman -Q grub &>/dev/null; then
        pacman -S --noconfirm grub
    fi
    
    if [[ -d /sys/firmware/efi ]]; then
        # UEFI system
        log "Detected UEFI system"
        
        # Install efibootmgr if not present
        if ! pacman -Q efibootmgr &>/dev/null; then
            pacman -S --noconfirm efibootmgr
        fi
        
        # Try to auto-detect EFI partition
        EFI_MOUNTED=false
        if mountpoint -q /boot/efi 2>/dev/null; then
            EFI_MOUNT="/boot/efi"
            EFI_MOUNTED=true
            log "EFI partition already mounted at /boot/efi"
        elif mountpoint -q /boot 2>/dev/null && [[ -d /boot/EFI ]]; then
            EFI_MOUNT="/boot"
            EFI_MOUNTED=true
            log "EFI partition mounted at /boot"
        else
            # Manual EFI setup
            read -p "Enter EFI mount point [/boot/efi]: " EFI_MOUNT
            EFI_MOUNT=${EFI_MOUNT:-/boot/efi}
            mkdir -p "$EFI_MOUNT"
            
            echo "Available FAT32 partitions:"
            lsblk -f | grep -i "fat32\|vfat" | head -5 || warn "No FAT32 partitions found"
            read -p "Enter EFI partition (e.g., /dev/sda1): " EFI_PART
            
            if [[ -b "$EFI_PART" ]]; then
                mount "$EFI_PART" "$EFI_MOUNT" && EFI_MOUNTED=true
                log "Mounted $EFI_PART to $EFI_MOUNT"
            else
                error "Invalid EFI partition: $EFI_PART"
            fi
        fi
        
        if [[ "$EFI_MOUNTED" == true ]]; then
            grub-install --target=x86_64-efi --efi-directory="$EFI_MOUNT" --bootloader-id=GRUB --removable
            success "GRUB UEFI installed"
        else
            error "Failed to mount EFI partition"
        fi
    else
        # BIOS system
        log "Detected BIOS system"
        echo "Available disks:"
        lsblk -d -o NAME,SIZE,MODEL | grep -v loop
        read -p "Enter disk for GRUB installation (e.g., /dev/sda): " GRUB_DISK
        
        if [[ -b "$GRUB_DISK" ]]; then
            grub-install --target=i386-pc "$GRUB_DISK"
            success "GRUB BIOS installed to $GRUB_DISK"
        else
            error "Invalid disk: $GRUB_DISK"
        fi
    fi
    
    # Generate GRUB config
    log "Generating GRUB configuration..."
    grub-mkconfig -o /boot/grub/grub.cfg
    success "GRUB configuration generated"
else
    warn "GRUB installation skipped"
fi

# 12. Enable NetworkManager
log "Enabling NetworkManager service..."
systemctl enable NetworkManager
success "NetworkManager enabled"

# 13. Enable multilib repository
log "Enabling multilib repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    pacman -Sy
    success "Multilib repository enabled"
else
    log "Multilib repository already enabled"
fi

# Final summary
echo
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        CONFIGURATION COMPLETED!          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo
success "System hostname: $HOSTNAME"
success "User account: $USERNAME (shell: $USER_SHELL)"
success "Locale: $LOCALE"
success "Timezone: $TIMEZONE"
success "GRUB bootloader: $INSTALL_GRUB"
echo
log "Next steps:"
log "1. Exit chroot: exit"
log "2. Unmount partitions: umount -R /mnt"
log "3. Reboot: reboot"
log "4. Login as '$USERNAME' and run install.sh"
echo
echo -e "${CYAN}🎉 System is ready for reboot!${NC}"

# Clean up sensitive variables
unset ROOT_PASS USER_PASS ROOT_PASS2 USER_PASS2