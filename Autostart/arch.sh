#!/bin/bash

set -euo pipefail

echo "[*] Backing up and replacing /etc/pacman.conf..."
sudo cp /etc/pacman.conf /etc/pacman.conf.bak

# Minimal pacman.conf with community disabled
sudo tee /etc/pacman.conf > /dev/null <<'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community]
#Include = /etc/pacman.d/mirrorlist
EOF

echo "[*] Initializing pacman keyring..."
sudo pacman-key --init
sudo pacman-key --populate archlinux

echo "[*] Updating pacman and resolving potential conflicts..."
sudo pacman -Syyu --noconfirm --overwrite "*" || true

echo "[*] Installing packages..."
sudo pacman -S --noconfirm --needed --overwrite "*" \
    nss toilet figlet firefox cool-retro-term micro nnn filemanager tmux

echo "[+] Setup complete!"
