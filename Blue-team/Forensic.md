
# Forensic.md – Must-Check Locations 


### 1. Windows Event Logs (zawsze pierwsze!)
```
%WinDir%\System32\winevt\Logs\
```
- Security.evtx → logony, object access, privilege use
- System.evtx → usługi, PsExec, schtasks
- Microsoft-Windows-PowerShell%4Operational.evtx → 4103/4104
- Microsoft-Windows-TaskScheduler%4Operational.evtx → 106, 200, 201
- Microsoft-Windows-Sysmon%4Operational.evtx → jeśli Sysmon był włączony

### 2. Registry Hives (złoto credentiali i persistence)
```
%WinDir%\System32\config\          → SAM, SYSTEM, SOFTWARE, SECURITY, DEFAULT
%WinDir%\System32\config\RegBack\  → kopie zapasowe
C:\Windows\AppCompat\Programs\Amcache.hve
C:\Users\<username>\NTUSER.DAT
C:\Users\<username>\AppData\Local\Microsoft\Windows\UsrClass.dat
```

### 3. Application & Network Logs
```
Web server → C:\inetpub\logs\LogFiles\
FTP server → zależy od softu (FileZilla, IIS FTP)
Firewall → Windows Defender Firewall → %WinDir%\System32\LogFiles\Firewall\pfirewall.log
Antivirus / EDR logs → zależnie od produktu
```

### 4. Memory Artifacts (jak masz RAM dump lub hibernację)
```
C:\pagefile.sys
C:\hiberfil.sys
C:\Windows\MEMORY.DMP
C:\Windows\Minidump\*.dmp
```

### 5. User Profiles (tu mieszkają wszystkie sekrety)
```
C:\Users\<username>\
    └─ Desktop, Downloads, Documents
    └─ AppData\Roaming\, Local\, LocalLow\
    └─ Recent\
    └─ AppData\Local\Temp\
    └─ AppData\Local\Microsoft\Windows\WebCache\
```

### 6. Filesystem Artifacts
```
$MFT          → raw z dysku (np. przez MFTECmd)
$LogFile
$UsnJrnl:$J   → USN Journal (najlepsze narzędzie: USNJournal Walker lub MFTECmd)
```

### 7. Prefetch (super do timeline i execution)
```
C:\Windows\Prefetch\*.pf
```

### 8. Browser Data
```
Chrome   → C:\Users\<user>\AppData\Local\Google\Chrome\User Data\Default\
Edge     → C:\Users\<user>\AppData\Local\Microsoft\Edge\User Data\Default\
Firefox  → C:\Users\<user>\AppData\Roaming\Mozilla\Firefox\Profiles\
```

### 9. Recycle Bin (często zapominany!)
```
C:\$Recycle.Bin\
C:\Users\<user>\AppData\Local\Microsoft\Windows\INetCache\  (IE/Edge cache)
```
