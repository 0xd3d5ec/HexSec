#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# 1. Change pacman.conf to enable parallel downloads
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# 2. Update Arch Linux system
pacman -Syu --noconfirm

# 3. Install required packages
pacman -S --noconfirm kitty vmware-tools zsh zsh-autosuggestions zsh-syntax-highlighting ttf-dejavu

# 4. Change default shell to zsh
chsh -s /bin/zsh

# 5. Clone personal aliases and add them to .zshrc
git clone https://gitlab.com/Ded5ec/dotfiles
cat dotfiles/aliases >> ~/.zshrc
source ~/.zshrc

# 6. Install tmux config file
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~
cp ~/.tmux/.tmux.conf.local ~

# 7. Install paru aur-helper
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru

# 8. Install BlackArch repo
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
./strap.sh

# 9. Install Chaotic-AUR repository
curl -sSL https://github.com/chaotic-aur/package-mirror/releases/latest/download/chaotic-mirrorlist.pkg.tar.zst | sudo pacman -U --noconfirm -

echo "Arch Linux system configuration completed successfully!"
