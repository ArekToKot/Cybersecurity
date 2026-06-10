# Directory Enumeration
## install apps
``` bash copy
sudo apt install gobuster seclists -y
```
## gobuster
``` bash copy
gobuster dir -u http://10.129.42.190/nibbleblog/ --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
```