# FTP Commands
Commands for interacting with FTP services

## Download all files (passive mode)
```bash copy
wget -m ftp://anonymous:anonymous@10.10.10.10
```
- Downloads all files from FTP server using anonymous login.
- `-m`: Enables mirroring to download entire directory structure.

## Download all files (active mode)
```bash copy
wget -m --no-passive ftp://anonymous:anonymous@10.10.10.10
```
- Downloads all files from FTP server using active mode.
- `-m`: Enables mirroring.
- `--no-passive`: Forces active FTP mode.