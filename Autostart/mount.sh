#!/bin/bash

# Get current user
USER=$(whoami)

echo "=== Mount and Expand Kali Live System ==="
echo ""
lsblk -f
echo ""
read -p "Enter the ext4 partition to mount (e.g., sda3): " PART

# Check if device exists
if [ ! -b /dev/$PART ]; then
    echo "Error: /dev/$PART does not exist."
    exit 1
fi

# Mount to /mnt/work
echo "[1/4] Mounting /dev/$PART to /mnt/work..."
sudo mkdir -p /mnt/work
sudo mount /dev/$PART /mnt/work

# Give current user ownership
echo "[2/4] Setting ownership for user: $USER"
sudo chown -R $USER:$USER /mnt/work

# Create target directories if they don’t exist
echo "[3/4] Preparing directories for system bind..."
for dir in var tmp home; do
    sudo mkdir -p /mnt/work/$dir
done

# Bind mounts to redirect live system
echo "[4/4] Binding /var, /tmp, /home to /mnt/work..."
sudo mount --bind /mnt/work/var /var
sudo mount --bind /mnt/work/tmp /tmp
sudo mount --bind /mnt/work/home /home

echo ""
echo "=== SUCCESS ==="
echo "Your system is now using the 90GB partition for /var, /tmp, and /home."
echo "You can now install packages, run pip, build kernels, etc., without space limits."
