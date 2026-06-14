# Execution Evidence — Installed Software and Program Execution

Reference for determining what software was installed and what programs were executed on a Windows host, including persistence mechanisms (services, autoruns, scheduled tasks). See [Disk-Forensic.md](Disk-Forensic.md) for tooling, must-check locations, and system profiling, and [User-Activity.md](User-Activity.md) for account activity, file history, and USB devices.

## Installed Apps

### Extraction Targets

- Install date
- Version
- Installation source (Microsoft Store vs. traditional installer)
- Install location

### Microsoft Store Apps

`C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd` is a SQLite database. Query it with [DB Browser for SQLite](https://sqlitebrowser.org/):

```sql copy
SELECT Name, PackageFullName, Version, InstallDate, InstallLocation
FROM Application
ORDER BY InstallDate ASC;
```

| Column | Meaning |
|---|---|
| `Name` | Display name of the app |
| `PackageFullName` | Full package identity string (`name_version_arch_publisherhash`) |
| `Version` | Installed version |
| `InstallDate` | Install timestamp |
| `InstallLocation` | Path to the package's install directory under `Program Files\WindowsApps` |

### Registry — Classic (Win32) Applications

| Key | Notes |
|---|---|
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\<GUID or name>` | 64-bit applications |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\<GUID or name>` | 32-bit applications on a 64-bit OS |
| `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\<GUID or name>` | Per-user installs |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\<exe name>` | Maps an executable name to its install path, used by the shell to resolve `Run` commands |

### Most Important Values Under Uninstall

| Value | Meaning |
|---|---|
| `DisplayName` | The application's name as shown in "Add or Remove Programs" |
| `Publisher` | Vendor/publisher name |
| `InstallDate` | Install date, stored as `YYYYMMDD` |
| `DisplayVersion` | Version string shown to the user |
| `InstallLocation` | Root directory where the application was installed |
| `UninstallString` | Full command line used to launch the standard (interactive) uninstaller, e.g. `"C:\Program Files\Mozilla Firefox\uninstall\helper.exe"` |
| `QuietUninstallString` | Full command line, including silent-mode arguments (e.g. `/S`, `/quiet`), used to remove the application without any user interaction |

### Event Logs — Install / Uninstall Activity

| Event ID | Source | Meaning |
|---|---|---|
| 1033 | Microsoft-Windows-Application-Experience | An MSI installation or uninstallation completed |
| 11724 | MsiInstaller | Product was successfully uninstalled |
| 7035 | Service Control Manager | A service was sent a start/stop control |
| 7045 | Service Control Manager | A new service was installed on the system |

**Note:** Event 7045 is one of the highest-value events for detecting persistence — many installers (legitimate and malicious) register a service, so a 7045 around the time of an install/uninstall ties the package to the service it created.

---

## Execution Activities

### Extraction Targets

- Last run time of an executable
- Cumulative usage time
- Services installed
- Scheduled tasks created

### Windows Services

Registry: `HKLM\SYSTEM\CurrentControlSet\Services\<name>` — `ImagePath`, `Start` (boot/auto/manual/disabled), `ObjectName` (account the service runs as).

| Event ID | Log | Meaning |
|---|---|---|
| 4697 | Security.evtx | A service was installed on the system |
| 7034 | System.evtx | A service terminated unexpectedly |
| 7035 | System.evtx | A service was sent a start/stop control |
| 7036 | System.evtx | A service entered the running/stopped state |
| 7040 | System.evtx | The start type of a service was changed |
| 7045 | System.evtx | A new service was installed |

### Windows Timeline

Accessible via Win+Tab, Windows Timeline stores a history of documents opened, websites visited, and apps used in `ActivitiesCache.db` (SQLite), located per-user at:

```
C:\Users\<user>\AppData\Local\ConnectedDevicesPlatform\L.<username>\ActivitiesCache.db
```

Parse with [WxTCmd](https://github.com/EricZimmerman/WxTCmd) (Eric Zimmerman). Timeline records show the application used, the document/URL involved, and start/end timestamps — useful for a high-level activity timeline even when other artifacts have been cleared.

### Autorun Applications

**SOFTWARE hive (machine-wide, all users):**

| Key | Notes |
|---|---|
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` | Runs at every user logon |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce` | Runs once, then the value is removed |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run` / `RunOnce` | Same, for 32-bit applications on a 64-bit OS |

**NTUSER.DAT hive (per user):**

| Key | Notes |
|---|---|
| `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` | Runs at logon for this user only |
| `HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce` | Runs once at this user's next logon |

### UserAssist Registry Key

Located at `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{GUID}\Count`, where each GUID subkey corresponds to a category of executed item:

| GUID | Tracks |
|---|---|
| `{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}` | Executable files (`.exe`) launched via Explorer |
| `{F4E57C4B-2036-45F0-A9AB-443BCFE33D9F}` | Shortcuts (`.lnk`) launched via Explorer |

Values are **ROT13-encoded** — decoding `P:\Zvpebfbsg\Rvqvg.vqr` yields `C:\Microsoft\Edit.exe`. Each value also stores a run count and a last-executed timestamp. Decode and parse with the [UserAssist](https://blog.didierstevens.com/programs/userassist/) tool by Didier Stevens.

### ShimCache (AppCompatCache)

Located at `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache` (binary value, parse with [AppCompatCacheParser](https://github.com/EricZimmerman/AppCompatCacheParser)).

Entries are created when:

- An executable is run, **or**
- Explorer simply lists/displays the file (e.g. browsing to the folder it's in)

**Note:** A ShimCache entry alone does **not** confirm execution — only that the file's metadata was cached by the Application Compatibility subsystem. Corroborate with Prefetch, Amcache, or event logs before concluding a file was run.

### AmCache.hve Registry Hive

Located at `C:\Windows\AppCompat\Programs\Amcache.hve`. Contains SHA-1 hashes and first-run/first-seen timestamps for executables, independent of ShimCache. Parse with [AmcacheParser](https://github.com/EricZimmerman/AmcacheParser).

| Key | Contents |
|---|---|
| `Root\InventoryApplicationFile` | Per-file metadata: path, SHA-1, size, first-seen timestamp, linked product |
| `Root\Programs` / `Root\InventoryApplication` | Installed application inventory |
| `Root\InventoryDevicePnp` | Plug-and-play device inventory (see [USB Devices](User-Activity.md#usb-devices)) |
| `Root\File\{Volume GUID}\<entry>` | Per-volume file records, keyed by the Volume GUID the file was seen on |

### BAM & DAM Registry Keys

**BAM (Background Activity Moderator)** — `HKLM\SYSTEM\ControlSet001\Services\bam\State\UserSettings\<user SID>` — one subkey per user SID, each containing values named after executable paths, with FILETIME data showing the last time that executable was run by that user.

**DAM (Desktop Activity Moderator)** — same structure under `...\dam\State\UserSettings\<user SID>`, introduced in Windows 10 1809+ and used primarily for foreground-app throttling, but equally useful as a last-execution-time source.

**Note:** BAM/DAM are particularly valuable in DFIR because they record **per-user** last-execution times with high precision, even for executables that never created Prefetch entries (e.g. run from a network share).

### Prefetch & SuperFetch

`C:\Windows\Prefetch\*.pf` — one file per executable, named `<EXENAME>-<8-char hash>.pf` (e.g. `NOTEPAD.EXE-3A123F4B.pf`, where the hash is derived from the executable's path).

Each `.pf` file provides:

- First and last run timestamps
- Run count
- A list of files and directories referenced during the first ~10 seconds of execution (DLLs loaded, files opened)

Parse with [WinPrefetchView](https://www.nirsoft.net/utils/win_prefetch_view.html) (NirSoft) or PECmd (Eric Zimmerman).

**Note:** Prefetch is enabled by default on Windows 7+ workstations but is often **disabled on servers**. The cache holds a maximum of 128 entries (pre-Windows 10) or 1024 entries (Windows 10/11) — heavy activity can age out older entries.

### SRUM (System Resource Usage Monitor)

`C:\Windows\System32\sru\SRUDB.dat` (an ESE database) records, in roughly 60-minute intervals, per-application network usage, CPU/foreground usage, and energy usage — going back up to 30 days.

**Checklist:**

```powershell copy
# 1. Copy the SRU folder (the DB may be locked while Windows is running)
Copy-Item C:\Windows\System32\sru\ -Destination C:\cases\sru -Recurse

# 2. Check database integrity
esentutl /g C:\cases\sru\SRUDB.dat

# 3. Repair if needed
esentutl /r SRU /d C:\cases\sru\SRUDB.dat

# 4. Parse with SrumECmd
SrumECmd.exe -f C:\cases\sru\SRUDB.dat --csv C:\cases\out
```

### Microsoft Office Alerts

`Microsoft-Windows-Office Alerts%4Operational.evtx` records dialog-box prompts shown by Office applications — save/overwrite confirmations, Outlook attachment/deletion confirmations, and **macro security warnings**.

This log is valuable because it can show a user clicking through an "Enable Content"/macro warning shortly before malicious activity begins — a strong indicator of initial access via a malicious document. See [../Malware-Analysis/Maldocs-Analysis.md](../Malware-Analysis/Maldocs-Analysis.md) for analyzing the document itself.

**Tip:** Search this log for keywords like "macro", "enable", or the specific filename under investigation.

### Scheduled Tasks

| Location | Contents |
|---|---|
| `C:\Windows\Tasks` | Legacy `.job` files (pre-Vista format, still occasionally seen) |
| `C:\Windows\System32\Tasks` | XML task definitions, one file per task, organized in folders mirroring Task Scheduler's UI |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree` / `Tasks` / `Boot` / `Logon` | Registry-side cache of registered tasks and their trigger types |

**Artifacts to collect per task**: task name, author, command + arguments, triggers, last run time, next run time, last result code, and security descriptor (which account it runs as / who can modify it).

**Quick tips:**

- Malicious tasks often use **random-looking names** placed in subfolders that mimic legitimate vendor folders (e.g. `\Microsoft\Windows\<random>\`).
- Compare the task's **creation timestamp** (from the XML file's `$MFT` entry) against its `<Date>` registration field — a mismatch can indicate the task was copied or tampered with.
- Tools: [Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns), TaskSchedulerView (NirSoft), and `Get-ScheduledTask` / `Get-ScheduledTaskInfo` in PowerShell.

```powershell copy
Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Select-Object TaskName, TaskPath, State
```
