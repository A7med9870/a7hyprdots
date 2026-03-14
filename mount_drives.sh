#!/bin/bash

# Create mount points
mkdir -p /run/media/ahmed/kabash
mkdir -p /run/media/ahmed/drivec
mkdir -p /run/media/ahmed/drived
# mkdir -p /run/media/ahmed/tbo

# Mount drives
mount -t ntfs-3g -o uid=1000,gid=1000,umask=022 UUID=0E7D841F7183877B /run/media/ahmed/kabash
mount -t exfat -o uid=1000,gid=1000,umask=022 UUID=FEFF-6427 /run/media/ahmed/drivec
mount -t btrfs -o user UUID=0f5c78d7-21b4-41fd-a619-13a0fc1c30ee /run/media/ahmed/drived
# mount -t ext4 -o user UUID=6b491a0f-76a4-441a-aa70-558c4f91c389 /run/media/ahmed/tbo

# mount -t ext4 UUID=6b491a0f-76a4-441a-aa70-558c4f91c389 /run/media/ahmed/tbo


# Fix Btrfs permissions (wait a moment for mount to complete)
sleep 2
chown -R ahmed:ahmed /run/media/ahmed/drived
# chown -R ahmed:ahmed /run/media/ahmed/tbo
