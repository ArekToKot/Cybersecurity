# Kali linux Setup

## Why kali
- Because it has all the tools needed and has the largest knowledge base in forums etc.
[Kali linux](https://www.kali.org/get-kali/#kali-installer-images)

## Install Tools
``` bash copy
#!/bin/bash
# gpg key fix
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

# install drivers
sudo apt update
sudo apt full-upgrade -y

# install programs
sudo apt install flatpak plasma-discover-backend-flatpak plasma-discover keepassxc virtualbox libreoffice libreoffice-kf5 hcxdumptool hcxtools virtualbox virtualbox-ext-pack -y
sudo apt install dkms build-essential linux-headers-`uname -r` -y

# flatpacks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub dev.vencord.Vesktop -y
flatpak install flathub com.vscodium.codium -y

# unpack rockyou and resert
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
reboot now
```

## Custom resolution
``` bash
xrandr --newmode 2560x1440_50.00  256.25  2560 2736 3008 3456  1440 1443 1448 1484 -hsync +vsync
xrandr --addmode HDMI-1 "2560x1440_50.00"
```

## Armitage commands
Armitage is a GUI version of Metasploit
``` bash
# first run vpn
sudo systemctl start postgresql && systemctl status postgresql && sudo msfdb reinit && sudo teamserver 10.14.84.79 1234
# next run armitage
armitage

```

## Remove GRUB timeout
``` bash
sudo nano /etc/default/grub
# GRUB_TIMEOUT=0
sudo update-grub
```


## Remove i801 error
``` bash
sudo nano /etc/modprobe.d/i2c-i801.conf
# add below
# options i2c-i801 disable_features=0x10
# blacklist i2c_i801
sudo update-initramfs -u
```