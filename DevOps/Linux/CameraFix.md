# Camera fix for lenovo thinkpad yoga x1 (7gen)

## Cam install commands
``` bash copy
sudo apt update
sudo apt install pipewire wireplumber pipewire-audio-client-libraries pipewire-pulse gstreamer1.0-tools gstreamer1.0-pipewire gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad v4l2loopback-dkms v4l2loopback-utils libcamera0.7 libcamera-ipa libcamera-v4l2 v4l-utils -y
systemctl --user restart pipewire wireplumber
# Start commands, every run
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback devices=1 video_nr=32 card_label="VirtualCam" exclusive_caps=1
gst-launch-1.0 pipewiresrc ! videoconvert ! video/x-raw,format=YUY2 ! v4l2sink device=/dev/video32
```

## ScreenShare install command
``` bash copy
sudo apt update
sudo apt install xdg-desktop-portal xdg-desktop-portal-kde pipewire wireplumber pipewire-pulse -y
systemctl --user restart pipewire wireplumber
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-kde
```