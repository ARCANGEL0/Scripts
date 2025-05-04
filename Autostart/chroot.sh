#!/bin/bash

set -e

echo "/// ::FETCHING MODULES..."
sleep 1
echo "/// ::INITIALIZING SYSTEM... READY"
echo ""
lsblk -f
echo ""

# Detect current user and system
USER=$(whoami)
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Choose correct mirror based on distro
case "$DISTRO" in
    kali)
        MIRROR="https://http.kali.org/kali"
        ;;
    debian)
        MIRROR="http://deb.debian.org/debian"
        ;;
    ubuntu)
        MIRROR="http://archive.ubuntu.com/ubuntu"
        ;;
    *)
        echo "[!] Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "[\]> SUDOING_USER: $USER"
read -p "[\]> Enter target partition to deploy (e.g., sda3): " PART
TARGET="/dev/$PART"
MOUNT_DIR="/mnt/work"

if [ ! -b "$TARGET" ]; then
    echo "[!] ERROR: Partition $TARGET does not exist. Exiting."
    exit 1
fi

echo "[\]> MOUNTING TARGET: $TARGET to $MOUNT_DIR..."
sudo mkdir -p $MOUNT_DIR
sudo mount $TARGET $MOUNT_DIR
sudo chown -R $USER:$USER $MOUNT_DIR

echo "[\]> INITIATING BASE SYSTEM DEPLOYMENT ($DISTRO:$CODENAME)..."
sudo apt update
sudo apt install -y debootstrap

echo "[\]> BOOTSTRAPPING SYSTEM INTO: $MOUNT_DIR..."
sudo debootstrap --variant=minbase "$CODENAME" "$MOUNT_DIR" "$MIRROR"

echo "[\]> SYSTEM SYNCHRONIZATION IN PROGRESS..."
for dir in dev proc sys; do
    sudo mount --bind /$dir $MOUNT_DIR/$dir
done
sudo cp /etc/resolv.conf $MOUNT_DIR/etc/resolv.conf

echo "[\]> LOADING CHROOT ENVIRONMENT..."
sudo chroot $MOUNT_DIR /bin/bash -c "
echo '[\]> SYSTEM UPDATE... SYNCING DATASTREAM...'
apt update
apt install -y sudo vim git wget curl locales

echo '[\]> CONFIGURING USER: $USER'
adduser $USER
usermod -aG sudo $USER

echo '[\]> CHROOT READY. TYPE \"exit\" TO RETURN.'
/bin/bash
"

echo "[\]> CLEANING UP..."
for dir in dev proc sys; do
    sudo umount $MOUNT_DIR/$dir
done

echo "/// ::CHROOT SYSTEM INSTALLED SUCCESSFULLY"
echo "[\]> RE-ENTER ANYTIME WITH: sudo chroot $MOUNT_DIR /bin/bash"
