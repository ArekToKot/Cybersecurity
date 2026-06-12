# Camera fix for lenovo thinkpad yoga x1 (7gen), kali linux kde (wayland)


## Camera and ScreenShare install commands
``` bash copy
# Installing packages
sudo apt update
sudo apt install pipewire-pulse pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-kde irmware-intel-graphics v4l-utils libcamera-tools libcamera-ipa libcamera-v4l2 gstreamer1.0-libcamera libspa-0.2-libcamera gstreamer1.0-pipewire v4l2loopback-dkms -y

# Configuring v4l2loopback (virtual camera /dev/video42)
echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf
echo 'options v4l2loopback video_nr=42 card_label="IPU6 Webcam" exclusive_caps=1'
sudo tee /etc/modprobe.d/v4l2loopback.conf

# Systemd user service (autostart on login)
mkdir -p ~/.config/systemd/user/

cat > ~/.config/systemd/user/ipu6-camera.service << 'EOF'
[Unit]
Description=IPU6 Camera Relay (PipeWire -> v4l2loopback)
After=pipewire.service wireplumber.service
Wants=pipewire.service wireplumber.service

[Service]
ExecStartPre=/bin/sleep 8
ExecStart=/usr/bin/gst-launch-1.0 pipewiresrc ! \
    video/x-raw,width=1280,height=720 ! \
    queue ! videoconvert ! \
    video/x-raw,format=YUY2 ! \
    queue ! v4l2sink device=/dev/video42 sync=false
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable ipu6-camera.service

# Reboot
sudo reboot
```

## Verification after restart
Wait for about 15 seconds after logging in, then:
``` bash copy
# Is the camera visible via libcamera?
cam --list
# Expected result: ‘1: Internal front camera ...’

# Can PipeWire detect the camera?
pw-cli list-objects | grep "Video/Source"
# Expected result: media.class = ‘Video/Source’

# Is the Relay service working?
systemctl --user status ipu6-camera.service
# Expected result: Active: active (running)

# Is the virtual camera available?
ls /dev/video42
```

## After karnel update
``` bash copy
sudo apt install linux-headers-$(uname -r)
sudo dkms autoinstall
```