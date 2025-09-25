#!/bin/bash
set -e

echo "==> Update & install base tools"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
	hyprland wayland xorg-xwayland xdg-desktop-portal-hyprland \
	waybar wofi mako \
	alacritty kitty foot fish zsh bash starship \
	swaylock swayidle swww fastfetch btop cava wl-clipboard playerctl brightnessctl \
	nwg-look adw-gtk-theme papirus-icon-theme ttf-jetbrains-mono-nerd \
	pipewire wireplumber pipewire-pulse pipewire-alsa pamixer git base-devel bluez bluez-utils

echo "==> Install AUR packages (eww, wlogout, swaylock-effects, cliphist)"
if ! command -v yay &>/dev/null; then
	echo "yay not found, installing yay..."
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	(cd /tmp/yay && makepkg -si --noconfirm)
fi

yay -S --needed --noconfirm \
	eww-git wlogout swaylock-effects-git cliphist

echo "==> Enable bluetooth service"
sudo systemctl enable --now bluetooth

echo "==> Install finished! Silakan login ke Hyprland dan nikmati setup-mu."
