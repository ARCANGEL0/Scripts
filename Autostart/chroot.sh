#!/bin/bash

set -e

echo "/// ::FETCHING MODULES..."
sleep 1
echo "/// ::INITIALIZING SYSTEM... READY"
echo ""
lsblk -f
echo ""

# Get the current user dynamically
USER=$(whoami)
echo "[\]> SUDOING_USER: $USER"

# Ask for the partition
read -p "[\]> Enter target partition to deploy (e.g., sda3): " PART
TARGET="/dev/$PART"
MOUNT_DIR="/mnt/work"

# Check if the device exists
if [ ! -b "$TARGET" ]; then
    echo "[!] ERROR: Partition $TARGET does not exist. Exiting."
    exit 1
fi

# Mount the target partition
echo "[\]> MOUNTING TARGET: $TARGET to $MOUNT_DIR..."
sudo mkdir -p $MOUNT_DIR
sudo mount $TARGET $MOUNT_DIR
sudo chown -R $USER:$USER $MOUNT_DIR

# Install debootstrap if not present
echo "[\]> INITIATING BASE SYSTEM DEPLOYMENT..."
sudo apt update
sudo apt install -y debootstrap

# Bootstrap the base system into the partition
echo "[\]> BOOTSTRAPPING SYSTEM TO: $MOUNT_DIR..."
sudo debootstrap --variant=minbase $(lsb_release -c | awk '{print $2}') $MOUNT_DIR http://archive.ubuntu.com/ubuntu

# Bind system directories
echo "[\]> SYSTEM SYNCHRONIZATION IN PROGRESS..."
for dir in dev proc sys; do
    sudo mount --bind /$dir $MOUNT_DIR/$dir
done

# Copy DNS config for networking
sudo cp /etc/resolv.conf $MOUNT_DIR/etc/resolv.conf

# Enter chroot and install base packages
echo "[\]> LOADING CHROOT ENVIRONMENT..."
sudo chroot $MOUNT_DIR /bin/bash -c "
echo '[\]> SYSTEM UPDATE... SYNCHRONIZING DATASTREAM...'
apt update
apt install -y sudo vim git wget curl locales

echo '[\]> CONFIGURING USER ACCESS... SYSTEM HACKER INITIATED...'
adduser $USER
usermod -aG sudo $USER

echo '[\]> SYSTEM COMPLETE. TYPE \"exit\" TO TERMINATE AND REBOOT.'
/bin/bash
"

# Cleanup bind mounts
echo "[\]> SYSTEM DEACTIVATION IN PROGRESS..."
for dir in dev proc sys; do
    sudo umount $MOUNT_DIR/$dir
done

echo "/// ::SYSTEM INIT COMPLETE"
echo "[\]> YOUR FULL SYSTEM CHROOT IS READY AT: $MOUNT_DIR"
echo "[\]> USE 'sudo chroot $MOUNT_DIR /bin/bash' TO RE-ENTER."
