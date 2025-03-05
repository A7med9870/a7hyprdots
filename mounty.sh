#!/bin/bash

# Ensure the script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# List all block devices excluding the main disk (usually /dev/sda or /dev/nvme0n1)
DISKS=$(lsblk -lnp -o NAME,TYPE | grep -E 'part$' | awk '{print $1}')

# Loop through each disk and mount it
for DISK in $DISKS; do
  # Check if the disk is already mounted
  if mount | grep -q "$DISK"; then
    echo "$DISK is already mounted. Skipping."
    continue
  fi

  # Create a mount point (directory) based on the disk name under /media
  MOUNT_POINT="/media/$(basename $DISK)"

  # Create the mount point directory if it doesn't exist
  mkdir -p "$MOUNT_POINT"

  # Get the filesystem type of the disk
  FSTYPE=$(blkid -o value -s TYPE "$DISK")

  # Check if the filesystem is exFAT
  if [ "$FSTYPE" == "exfat" ]; then
    echo "Detected exFAT filesystem on $DISK."

    # Attempt to mount the exFAT filesystem with explicit read-write options
    if mount -t exfat -o rw,uid=1000,gid=1000,umask=000 "$DISK" "$MOUNT_POINT" 2>/dev/null; then
      echo "Successfully mounted $DISK at $MOUNT_POINT in read-write mode."
    else
      echo "Failed to mount $DISK. It may not have a valid exFAT filesystem or is already in use."
      rmdir "$MOUNT_POINT"  # Clean up the unused mount point
    fi
  else
    # For non-exFAT filesystems, proceed with the default mount command
    echo "Checking filesystem on $DISK..."
    fsck -y "$DISK"  # Automatically repair filesystem errors
    if [ $? -ne 0 ]; then
      echo "Filesystem check failed for $DISK. It may be corrupted or unsupported."
      continue
    fi

    echo "Mounting $DISK at $MOUNT_POINT in read-write mode..."
    if mount -o rw "$DISK" "$MOUNT_POINT" 2>/dev/null; then
      echo "Successfully mounted $DISK at $MOUNT_POINT in read-write mode."
    else
      echo "Failed to mount $DISK. It may not have a valid filesystem or is already in use."
      rmdir "$MOUNT_POINT"  # Clean up the unused mount point
    fi
  fi
done
