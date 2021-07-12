#!/bin/bash

set -e

# Base packages
pacman -Sy alacritty htop openssh docker neovim firefox sway xorg-server-xwayland grub pacman noto-fonts-emoji pulseaudio pulseaudio-alsa paprefs pavucontrol brightnessctl playerctl

# Time Zone
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# Locales
nvim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
localectl set-keymap --no-convert br-abnt

# Hostname
read -p "Enter hostname: " hostname

echo "$hostname" > /etc/hostname
echo "127.0.0.1   	localhost
::1		localhost
127.0.1.1   	$hostname.localdomain $hostname" > /etc/hosts

# Boot Loader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
nvim /etc/default/grub

# Root Password
passwd

# Create Sudo User
read -p "Enter username: " username

useradd --create-home $username
passwd $username
usermod --append --groups wheel $username

visudo

# Install yay
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Enable services
systemctl enable NetworkManager.service
systemctl enable docker.service

# Setup Git and SSH
echo "Seting up Git and SSH"
read -p "Enter your email: " gitemail
read -p "Enter your name: " gitname
ssh-keygen -t ed25519 -C $gitemail
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

git config --global user.name $gitname
git config --global user.email $gitemail
git config --global core.editor nvim

