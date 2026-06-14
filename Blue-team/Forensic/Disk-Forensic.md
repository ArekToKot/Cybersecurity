# Disk Forensics — Windows Artifact Reference

Entry point for disk-based incident response: available tooling, a quick-reference index of must-check artifact locations, and system-level profiling (OS version, computer name, time zone, network configuration). For user account activity, file/folder history, and USB devices, see [User-Activity.md](User-Activity.md); for installed software and program-execution evidence, see [Execution-Evidence.md](Execution-Evidence.md). For volatile/RAM-based artifacts see [Memory-Forensic.md](Memory-Forensic.md); for event-log-driven hunting over these same artifacts see [../Threat-Hunting/Sysmon.md](../Threat-Hunting/Sysmon.md) and [../Threat-Hunting/KQL-Threat-Hunting.md](../Threat-Hunting/KQL-Threat-Hunting.md).

## Tools

| Tool | Platform | Link |
|---|---|---|
| KAPE | Windows | [Kroll](https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape) |
| MFTECmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/MFTECmd) |
| AmcacheParser | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/AmcacheParser) |
| AppCompatCacheParser | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/AppCompatCacheParser) |
| SrumECmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/Srum) |
| JLECmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/JLECmd) |
| LECmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/LECmd) |
| RegistryExplorer / RECmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/RECmd) |
| Timeline Explorer | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/Timeline-Explorer) |
| WxTCmd | Windows | [GitHub (EZ Tools)](https://github.com/EricZimmerman/WxTCmd) |
| INDXRipper | Windows / Linux | [GitHub](https://github.com/sk3pp3r/INDXRipper) |
| Autopsy | Windows / Linux / macOS | [autopsy.com](https://www.autopsy.com/) |
| FTK Imager | Windows | [Exterro](https://www.exterro.com/ftk-imager) |
| DB Browser for SQLite | Windows / Linux / macOS | [sqlitebrowser.org](https://sqlitebrowser.org/) |
| ESENTUTL | Windows | built-in |

---

## Quick Reference: Must-Check Locations

### 1. Windows Event Logs

```
C:\Windows\System32\winevt\Logs\Security.evtx
C:\Windows\System32\winevt\Logs\System.evtx
C:\Windows\System32\winevt\Logs\Application.evtx
C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx
C:\Windows\System32\winevt\Logs\Microsoft-Windows-PowerShell%4Operational.evtx
C:\Windows\System32\winevt\Logs\Microsoft-Windows-TaskScheduler%4Operational.evtx
C:\Windows\System32\winevt\Logs\Microsoft-Windows-Windows Defender%4Operational.evtx
C:\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-*%4Operational.evtx
```

### 2. Registry Hives

```
C:\Windows\System32\config\SAM
C:\Windows\System32\config\SYSTEM
C:\Windows\System32\config\SOFTWARE
C:\Windows\System32\config\SECURITY
C:\Windows\AppCompat\Programs\Amcache.hve
C:\Users\<user>\NTUSER.DAT
C:\Users\<user>\AppData\Local\Microsoft\Windows\UsrClass.dat
```

### 3. Application & Network Logs

```
C:\inetpub\logs\LogFiles\
C:\Windows\System32\LogFiles\Firewall\
C:\Windows\System32\drivers\etc\hosts
C:\Windows\System32\winevt\Logs\Microsoft-Windows-DNS-Client%4Operational.evtx
```

### 4. Memory Artifacts

```
C:\hiberfil.sys
C:\pagefile.sys
C:\swapfile.sys
C:\Windows\Minidump\
C:\Windows\MEMORY.DMP
```

See [Memory-Forensic.md](Memory-Forensic.md) for Volatility-based analysis of these files.

### 5. User Profiles

```
C:\Users\<user>\NTUSER.DAT
C:\Users\<user>\AppData\Roaming\
C:\Users\<user>\AppData\Local\
C:\Users\<user>\AppData\LocalLow\
```

### 6. Filesystem Artifacts

```
$MFT
$LogFile
$UsnJrnl ($J data stream)
$Boot
$I30 (per-directory index attribute)
```

### 7. Prefetch

```
C:\Windows\Prefetch\*.pf
```

### 8. Browser Data

```
C:\Users\<user>\AppData\Local\Google\Chrome\User Data\Default\
C:\Users\<user>\AppData\Local\Microsoft\Edge\User Data\Default\
C:\Users\<user>\AppData\Roaming\Mozilla\Firefox\Profiles\<profile>\
```

History, Cookies, Downloads, and Cache are stored as SQLite databases — open with [DB Browser for SQLite](https://sqlitebrowser.org/).

### 9. Recycle Bin

```
C:\$Recycle.Bin\<user SID>\
$I######.<ext>  -> metadata: original path, deletion time, file size
$R######.<ext>  -> recovered file content
```

---

## Profiling Windows

### Windows Version and Install Date

`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion` holds `ProductName`, `CurrentBuild`, `DisplayVersion`/`ReleaseId`, and `InstallDate` (Unix epoch — when the OS was installed/imaged).

### Computer Name

`HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName` — value `ComputerName`.

### Time Zone

`HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation` — `TimeZoneKeyName` and `ActiveTimeBias` (offset from UTC, in minutes). Always resolve this first: every other timestamp in this document is local time unless converted to UTC using this offset.

### Startup / Shutdown Time

Tracked in `System.evtx`:

| Event ID | Source | Meaning |
|---|---|---|
| 6005 | EventLog | Event Log service started — marks a system boot |
| 6006 | EventLog | Event Log service stopped — marks a clean shutdown |
| 6008 | EventLog | Previous shutdown was unexpected (crash, power loss, hard reset) |
| 1074 | User32 | Shutdown/restart was initiated, including the requesting process and user |
| 41 | Microsoft-Windows-Kernel-Power | System rebooted without a clean shutdown |

**Tip:** Plotting 6005/6006/1074/41 over time produces a reliable boot/shutdown timeline — useful for spotting reboots that coincide with malware installation, log clearing, or other anti-forensic activity.

---

## Network Connections

### Network Interfaces

- `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\<GUID>` — per-adapter configuration: assigned IP, DHCP lease times, configured DNS servers.
- `HKLM\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\<GUID>` — maps adapter GUIDs to friendly names.

### Connection History

`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\<GUID>` records every network the host has joined: `ProfileName`, `Description`, `DateCreated`, `DateLastConnected`.

`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged` / `Managed` link each profile to the gateway's MAC address (`DefaultGatewayMac`) and a `NameType`:

| NameType (hex) | Connection type |
|---|---|
| `0x47` | Wireless (Wi-Fi) |
| `0x06` | Wired (Ethernet) |
| `0x17` | VPN / broadband |

Wi-Fi connect/disconnect events are logged separately in `Microsoft-Windows-WLAN-AutoConfig/Operational`:

| Event ID | Meaning |
|---|---|
| 8001 | Successfully connected to a wireless network |
| 8003 | Disconnected from a wireless network |

### Network Shares

- `HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares` — SMB shares hosted by this machine.
- `HKCU\Network\<drive letter>` — drives the current user has mapped (remote UNC path, persistence across logons).

| Share Type code | Meaning |
|---|---|
| `0` | Disk drive |
| `1` | Print queue |
| `2` | Device |

| Permission code | Meaning |
|---|---|
| `0` | No access |
| `9` | Read |
| `63` | Full control |
