#!/bin/bash

echo "=== Mount and Expand Kali Live System to External ext4 Partition ==="
echo ""
lsblk -f
echo ""
read -p "Enter the partition to mount (e.g., sda3): " PART

# Check device
if [ ! -b /dev/$PART ]; then
    echo "Error: /dev/$PART does not exist."
    exit 1
fi

# Mount to /mnt/work
sudo mkdir -p /mnt/work
sudo mount /dev/$PART /mnt/work
sudo chown kali:kali /mnt/work
echo "Mounted /dev/$PART to /mnt/work"

# Create system-like dirs on the mounted drive if missing
for dir in var tmp home; do
    sudo mkdir -p /mnt/work/$dir
done

# Bind key folders to redirect system operations to larger partition
echo "Binding /var, /tmp, /home to /mnt/work equivalents..."
sudo mount --bind /mnt/work/var /var
sudo mount --bind /mnt/work/tmp /tmp
sudo mount --bind /mnt/work/home /home

echo ""
echo "=== DONE ==="
echo "You now have extended space for APT, pip, downloads, and builds using your 90GB partition."
echo "Mounted: /var, /tmp, /home from /mnt/work"
