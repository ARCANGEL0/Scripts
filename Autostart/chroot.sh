#!/bin/bash

set -e

echo "/// ::BOOTSTRAPPER ENGAGED"
sleep 1
echo "/// ::DISABLING SECURITY VALIDATIONS FOR MAXIMUM SPEED..."
echo ""
lsblk -f
echo ""

USER=$(whoami)
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

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
        echo "[!] Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

echo "[\]> SUDOING_USER: $USER"
read -p "[\]> Enter target partition (e.g., sda3): " PART
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

echo "[\]> BOOTSTRAPPING OS ($DISTRO:$CODENAME) WITHOUT VALIDATION..."
sudo apt update
sudo apt install -y debootstrap

# Main change here: --no-check-gpg and fast mirror use
sudo debootstrap --no-check-gpg --variant=minbase "$CODENAME" "$MOUNT_DIR" "$MIRROR" || {
    echo "[!] Bootstrap failed. Try checking internet or repo manually."
    exit 1
}

echo "[\]> LINKING SYSTEM CORE..."
for dir in dev proc sys; do
    sudo mount --bind /$dir $MOUNT_DIR/$dir
done
sudo cp /etc/resolv.conf $MOUNT_DIR/etc/resolv.conf

echo "[\]> INITIATING CHROOT ENVIRONMENT..."
sudo chroot $MOUNT_DIR /bin/bash -c "
echo '[\]> SYNCING PACKAGE DATA...'
apt update --allow-insecure-repositories || true
apt install -y sudo vim git wget curl locales --allow-unauthenticated || true

echo '[\]> CREATING USER: $USER'
adduser $USER
usermod -aG sudo $USER

echo '[\]> SETUP COMPLETE. TYPE \"exit\" TO LEAVE ENVIRONMENT.'
/bin/bash
"

echo "[\]> CLEANING TEMPORARY LINKS..."
for dir in dev proc sys; do
    sudo umount $MOUNT_DIR/$dir
done

echo "/// ::CHROOT READY AT: $MOUNT_DIR"
echo "[\]> RUN AGAIN WITH: sudo chroot $MOUNT_DIR /bin/bash"
