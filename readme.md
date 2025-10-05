# versionzero [On Progress]

![versionzero](https://img.shields.io/badge/version-0.0.0-blue)
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-5865F2)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

* **Window Manager**: Hyprland with smooth animations
* **Status Bar**: Waybar with custom dropdown panel
* **Widgets**: EWW for system monitoring and media controls
* **Launcher**: Wofi with glassmorphism styling
* **Terminal**: Foot, Kitty, and Alacritty support
* **Shell**: Fish with Starship prompt
* **Notifications**: Mako with color-coded urgency
* **Display Manager**: SDDM with Sugar Candy theme
* **Theme System**: Easy color switching with 3 pre-configured themes
* **Liquid Animations**: Smooth cubic-bezier transitions throughout

## Requirements

* Arch Linux (or Arch-based distribution)
* Internet connection
* At least 4GB RAM recommended
* GPU with OpenGL support

## Installation

### Step 1: Prepare the Base System (Live USB)

These steps are performed from the **Arch Linux Live USB** to build the base system.

1. **Verify Internet Connection**

   ```bash
   ping archlinux.org
   ```

   Ensure you have connectivity before proceeding.

2. **Partition the Disk**
   Use `cfdisk` to create the following recommended scheme:

   * **Partition 1**: `512M` – Type: `EFI System`
   * **Partition 2**: (Size of RAM, e.g., `8G`) – Type: `Linux swap`
   * **Partition 3**: (Root – flexible size) – Type: `Linux filesystem`
   * **Partition 4**: (Home – remaining space) – Type: `Linux filesystem`

3. **Format and Mount Partitions**
   Replace `sda` with your disk name (e.g., `nvme0n1`):

   ```bash
   mkfs.fat -F 32 /dev/sda1
   mkswap /dev/sda2
   mkfs.ext4 /dev/sda3
   mkfs.ext4 /dev/sda4

   mount /dev/sda3 /mnt
   swapon /dev/sda2
   mount --mkdir /dev/sda1 /mnt/boot
   mkdir -p /mnt/home
   mount /dev/sda4 /mnt/home
   ```

4. **Install Base Packages (`pacstrap`)**

   ```bash
   pacstrap /mnt base linux linux-firmware networkmanager nano sudo git
   ```

5. **Generate Fstab & Chroot**

   ```bash
   genfstab -U /mnt >> /mnt/etc/fstab
   arch-chroot /mnt
   ```

   You are now operating inside the newly installed base system.

---

### Step 2: Run System Configurator

After entering chroot, run the interactive system configuration script to set up hostname, user, locale, timezone, shell, and optionally GRUB bootloader:

```bash
curl -O https://raw.githubusercontent.com/LortBree/versionzero/main/config.sh
chmod +x config.sh
./config.sh
```

Optional:
```bash
config.sh --dry-run
```
To test run the script without changing anything in your system.

This script will:

* Configure hostname and hosts
* Set locale and timezone
* Create user and set passwords
* Install and configure chosen shell (bash, fish, zsh)
* Configure sudo access
* Install essential packages (networkmanager, base-devel, etc.)
* Optionally install GRUB (BIOS/UEFI detection supported)
* Enable NetworkManager and multilib repository

After completion:

1. Exit chroot: `exit`
2. Unmount partitions: `umount -R /mnt`
3. Reboot: `reboot`

---

### Step 3: Connect to the Internet After Reboot

Once the system has rebooted, log in with the user account you created, then enable and connect using **NetworkManager**:

```bash
# Ensure NetworkManager is running
sudo systemctl enable --now NetworkManager

# Use nmtui (text user interface)
nmtui
```

Select your Wi-Fi or Ethernet connection and connect. Confirm with:

```bash
ping archlinux.org
```

---

### Step 4: Install versionzero (Recommended)

After ensuring you are connected to the internet:

```bash
curl -O https://raw.githubusercontent.com/LortBree/versionzero/main/install.sh
chmod +x install.sh
./install.sh
```

The installer will:

1. Update your system
2. Install all required packages
3. Install AUR helper (yay)
4. Clone this repository
5. Deploy dotfiles to `~/.config`
6. Setup SDDM with theme
7. Apply default color theme
8. Configure services

### Manual Installation

If you prefer manual installation:

```bash
git clone https://github.com/LortBree/versionzero.git
cd versionzero
sudo pacman -S hyprland waybar wofi mako swaylock foot fish starship sddm
./install_dotfiles.sh
```

## Post-Installation

After installation completes:

1. **Reboot your system**:

   ```bash
   reboot
   ```

2. **Login through SDDM**

   * Hyprland will start automatically

3. **First Launch**:

   * Press `Super + Q` to open terminal
   * Press `Super + R` to open launcher

---

(remaining sections: Keybindings, Theme Switching, Configuration, Troubleshooting, Package List, Updating, Uninstallation, Project Structure, Credits, Contributing, License, Support, Acknowledgments — unchanged, but NetworkManager connection after reboot is now documented)

---

Repository: [https://github.com/LortBree/versionzero](https://github.com/LortBree/versionzero)