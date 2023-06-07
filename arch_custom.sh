#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# 1. Install xfce4 theme - Plata Blue Noir Compact
paru -S --noconfirm plata-theme

# 2. Apply xfce4 theme
xfconf-query -c xsettings -p /Net/ThemeName -s "Plata-Noir-Compact"
xfconf-query -c xfwm4 -p /general/theme -s "Plata-Noir-Compact"

# 3. Install Papirus icons
paru -S --noconfirm papirus-icon-theme

# 4. Change xfce4 icons to Papirus
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

# 5. Install blackarch-config-zsh from BlackArch repo
pacman -S --noconfirm blackarch-config-zsh

# 6. Copy zsh config file
cp /usr/share/blackarch-config-zsh/zshrc /etc/zsh/zshrc

# 7. Clone personal aliases and add them to .zshrc
git clone https://gitlab.com/Ded5ec/dotfiles
cat dotfiles/aliases >> ~/.zshrc
source ~/.zshrc

# 8. Change xfce4 panel or import panel profile
# Option 1: Change xfce4 panel
# xfconf-query -c xfce4-panel -p /panels/panel-1/style -s "vertical"
# xfconf-query -c xfce4-panel -p /panels/panel-1/size -s "32"
# xfconf-query -c xfce4-panel -p /panels/panel-1/position -s "p=8;x=0;y=0"
# xfconf-query -c xfce4-panel -p /panels/panel-1/length -s "100%"
# xfconf-query -c xfce4-panel -p /panels/panel-1/autohide-behavior -s "0"

# Option 2: Import panel profile (if available)
xfce4-panel-profiles -R ~/dotfiles/panel_profiles/panel_profile.tar.bz2

# 9. Install other important tools for VM optimization
pacman -S --noconfirm xfce4-power-manager tlp

echo "XFCE4 customization and VM optimization completed successfully!"
