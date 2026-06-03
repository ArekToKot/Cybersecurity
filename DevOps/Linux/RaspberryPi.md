# Raspberry pi zero 2 w
Install image using [rpi-imager](https://www.raspberrypi.com/software/)
- [P4wnP1_ALOA](https://github.com/Son-of-David/Raspberry-Pi-Zero-or-Zero-2-Image-with-OLED-or-LCD)
- [Bad_USB](https://github.com/PsycoStea/Pi-Zero-2W-Bad-USB) 

Check SD size:
``` bash copy
df -h
```

To extend SD card type:
``` bash copy
cd /
raspi-config --expand-rootfs
```

To create virtual USB drive:
```bash copy
/usr/local/P4wnP1/helper/genimg -i -s 32768 -o pendrive32gb.img -l pendrive
```