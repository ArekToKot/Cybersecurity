# John Commands
Commands for password cracking with John the Ripper

## Convert SSH Key to Hash
```bash copy
ssh2john id_rsa > hash.txt
```
- Converts an SSH private key to a crackable hash format.

## Convert RAR Archive to Hash
```bash copy
rar2john secure.rar > hash.txt
```
- Extracts a hash from a RAR archive for cracking.

## Convert ZIP Archive to Hash
```bash copy
zip2john secure.zip > hash.txt
```
- Extracts a hash from a ZIP archive for cracking.

## Crack Hash with Wordlist
```bash copy
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```
- Cracks a hash using a wordlist.
- `--wordlist=/usr/share/wordlists/rockyou.txt`: Specifies the wordlist.
- `hash.txt`: Specifies the hash file.

## Crack MD5 Hash in Single Mode
```bash copy
john --single --format=raw-md5 hash.txt
```
- Cracks an MD5 hash using single crack mode.
- `--single`: Uses single crack mode.
- `--format=raw-md5`: Specifies the hash format.

## Identify Hash Type
```bash copy
hash-identifier
```
- Identifies the type of a given hash.

## Crack SHA-512 Crypt Hash
```bash copy
john --format=sha512crypt --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```
- Cracks a SHA-512 crypt hash using a wordlist.
- `--format=sha512crypt`: Specifies the hash format.
- `--wordlist=/usr/share/wordlists/rockyou.txt`: Specifies the wordlist.

## Check /etc/shadow Permissions
```bash copy
ls -l /etc/shadow
```
- Lists permissions of the `/etc/shadow` file.
- `-l`: Detailed listing.

## Generate SHA-512 Password Hash
```bash copy
mkpasswd -m sha-512 newpasswordhere
```
- Creates a SHA-512 hash for a new password.
- `-m sha-512`: Specifies the hash method.

## Edit /etc/shadow
```bash copy
nano /etc/shadow
```
- Opens `/etc/shadow` for editing (e.g., to replace a password hash).

## Switch to Root User (Shadow)
```bash copy
su root
```
- Switches to the root user after modifying `/etc/shadow`.

## Check /etc/passwd Permissions
```bash copy
ls -l /etc/passwd
```
- Lists permissions of the `/etc/passwd` file.
- `-l`: Detailed listing.

## Generate Password Hash with OpenSSL
```bash copy
openssl passwd newpasswordhere
```
- Creates a password hash for a new password.

## Edit /etc/passwd
```bash copy
nano /etc/passwd
```
- Opens `/etc/passwd` for editing (e.g., to replace a password hash).

## Switch to Root User (Passwd)
```bash copy
su root
```
- Switches to the root user after modifying `/etc/passwd`.

## Combine /etc/passwd and /etc/shadow
```bash copy
unshadow passwd shadow > unshadowed
```
- Combines `/etc/passwd` and `/etc/shadow` into a crackable format.

## Crack Kerberos TGT with Hashcat
```bash copy
hashcat -m 13100 -a 0 hash.txt /usr/share/wordlists/rockyou.txt --force -O
```
- Cracks a Kerberos TGT hash using hashcat.
- `-m 13100`: Specifies Kerberos TGT hash format.
- `-a 0`: Uses wordlist attack mode.
- `hash.txt`: Specifies the hash file.
- `/usr/share/wordlists/rockyou.txt`: Specifies the wordlist.
- `--force`: Forces hashcat to run despite warnings.
- `-O`: Use hashcat optimized kernels.