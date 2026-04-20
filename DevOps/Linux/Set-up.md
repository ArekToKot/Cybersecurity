# Kali linux Setup

## Why kali
- Because it has all the tools needed and has the largest knowledge base in forums etc.
[Kali linux](https://www.kali.org/get-kali/#kali-installer-images)

## Install Tools
``` bash copy
#!/bin/bash
# gpg key fix
#sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
sudo apt update

sudo apt install flatpak plasma-discover-backend-flatpak plasma-discover keepassxc libreoffice libreoffice-kf5 -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo -y
flatpak install flathub dev.vencord.Vesktop -y
flatpak install flathub com.vscodium.codium -y

wget https://betterdiscord.app/Download?id=144 > /home/arek/.var/app/dev.vencord.Vesktop/config/vesktop/themes/
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
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
# change timeout to 0
update-grub
```
