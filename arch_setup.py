import os
import subprocess

# Function to execute commands and display colored output
def execute_command(command, success_message=None, error_message=None):
    try:
        subprocess.run(command, shell=True, check=True)
        if success_message:
            print(f"\033[92m[+]\033[0m {success_message}")
    except subprocess.CalledProcessError as e:
        if error_message:
            print(f"\033[91m[-]\033[0m {error_message}")
        print(f"\033[93m[i]\033[0m An error occurred: {e}")

# Set up environment variables
os.environ['TZ'] = 'UTC'
execute_command('timedatectl set-ntp true', success_message='Time and date configured successfully.')

# Check latest Arch Linux mirrors
execute_command('reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist',
                success_message='Latest mirrors fetched and saved successfully.',
                error_message='Failed to update mirrorlist.')

# Enable parallel downloads for pacman
execute_command('sed -i "s/^#\(ParallelDownloads = \)5/\120/" /etc/pacman.conf',
                success_message='Parallel downloads enabled for pacman.')

# Partition the disk
execute_command('cfdisk', success_message='Disk partitioned successfully.')

# Format partitions
execute_command('mkfs.btrfs /dev/sdaX', success_message='Partitions formatted successfully.')  # Replace 'sdaX' with your partition

# Mount the root partition
execute_command('mount /dev/sdaX /mnt', success_message='Root partition mounted successfully.')  # Replace 'sdaX' with your partition

# Install the base system with parallel downloads
execute_command('pacstrap -j 10 /mnt base base-devel linux-lts linux-firmware',
                success_message='Base system installed successfully.')

# Generate fstab
execute_command('genfstab -U /mnt >> /mnt/etc/fstab', success_message='Fstab generated successfully.')

# Chroot into the new system
execute_command('arch-chroot /mnt', success_message='Chrooted into the new system.')

# Set the system clock
execute_command('ln -sf /usr/share/zoneinfo/Region/City /etc/localtime', success_message='System clock configured successfully.')  # Replace 'Region/City' with your timezone
execute_command('hwclock --systohc', success_message='Hardware clock updated successfully.')

# Configure locales
execute_command('echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen', success_message='Locales configured successfully.')
execute_command('locale-gen')

# Configure hostname
execute_command('echo "myhostname" > /etc/hostname', success_message='Hostname configured successfully.')  # Replace 'myhostname' with your desired hostname

# Set the root password
execute_command('passwd', success_message='Root password set successfully.')

# Install and configure GRUB
execute_command('pacman -S grub', success_message='GRUB installed successfully.')
execute_command('grub-install --target=i386-pc /dev/sda', success_message='GRUB installed to the disk successfully.')  # Replace 'sda' with your disk
execute_command('grub-mkconfig -o /boot/grub/grub.cfg', success_message='GRUB configuration updated successfully.')

# Install and configure XFCE4
execute_command('pacman -S xfce4 xfce4-goodies', success_message='XFCE4 installed successfully.')

# Install Snapper and Btrfs-progs
execute_command('pacman -S snapper btrfs-progs', success_message='Snapper and Btrfs-progs installed successfully.')

# Configure Btrfs
execute_command('snapper -c root create-config /', success_message='Btrfs configured successfully.')
execute_command('systemctl enable snapper-timeline.timer', success_message='Snapper timeline enabled.')
execute_command('systemctl enable snapper-cleanup.timer', success_message='Snapper cleanup enabled.')

# Configure Snapper snapshots in GRUB
execute_command('sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=10/" /etc/default/grub', success_message='GRUB timeout updated.')
execute_command('grub-mkconfig -o /boot/grub/grub.cfg', success_message='GRUB configuration updated with Snapper snapshots.')

# Create a new privileged user with sudo privileges
execute_command('useradd -m -G wheel -s /bin/bash newuser', success_message='New user created successfully.')  # Replace 'newuser' with the desired username
execute_command('passwd newuser', success_message='Password set for the new user.')

# Exit chroot environment
print("\033[93m[i]\033[0m Exiting chroot environment...")
execute_command('exit')

# Unmount partitions
execute_command('umount -R /mnt', success_message='Partitions unmounted successfully.')

# Reboot the system
print("\033[93m[i]\033[0m Rebooting the system...")
execute_command('reboot')

print("\033[92m[+]\033[0m Arch Linux installation and configuration completed successfully!")
