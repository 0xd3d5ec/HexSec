#!/bin/bash

# Install required packages
sudo paru -Syu snapper grub-btrfs snap-pac

# Configure snapper for the root file system
sudo snapper -c root create-config /

# Set up automatic snapshots
sudo snapper -c root set-config "TIMELINE_CREATE=yes"
sudo snapper -c root set-config "TIMELINE_CLEANUP=yes"
sudo snapper -c root set-config "TIMELINE_LIMIT_HOURLY=6"
sudo snapper -c root set-config "TIMELINE_LIMIT_DAILY=7"
sudo snapper -c root set-config "TIMELINE_LIMIT_WEEKLY=4"
sudo snapper -c root set-config "TIMELINE_LIMIT_MONTHLY=6"

# Configure GRUB to show snapshots in advanced menu
sudo sed -i 's/GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=n/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
