# Memory Forensics — Volatility Reference

Reference for analyzing Windows memory images (RAM captures, hibernation files, page files, crash dumps) with Volatility 2/3. For disk-side artifacts that complement these findings (registry hives, MFT, event logs) see [Disk-Forensic.md](Disk-Forensic.md).

## Tools

| Tool | Platform | Link |
|---|---|---|
| Volatility 2 | Windows / Linux / macOS | [GitHub](https://github.com/volatilityfoundation/volatility) |
| Volatility 3 | Windows / Linux / macOS | [GitHub](https://github.com/volatilityfoundation/volatility3) |
| MemProcFS | Windows / Linux | [GitHub](https://github.com/ufrisk/MemProcFS) |

---

## Memory Image Sources

| Source | Path | Notes |
|---|---|---|
| Hibernation file | `C:\hiberfil.sys` | Compressed RAM snapshot taken at hibernation; convert first with `vol.py -f hiberfil.sys imagecopy` (Vol2) |
| Page file | `C:\pagefile.sys` | Data swapped out of RAM — supplements a live RAM capture, doesn't replace it |
| Crash dump | `C:\Windows\MEMORY.DMP` | Full or kernel memory dump written after a BSOD |
| Live RAM capture | `memory.dmp` / `.raw` / `.vmem` | Acquired with FTK Imager, DumpIt, `winpmem`, or a hypervisor snapshot |

## Volatility Command Syntax

Volatility 2 requires an explicit `--profile`:

```bash copy
vol.py -f memory.dmp --profile=<profile> <plugin> [plugin options]
```

Volatility 3 auto-detects the operating system and does not need a profile:

```bash copy
vol3 -f memory.dmp <plugin> [plugin options]
```

| Vol 2 plugin | Vol 3 plugin | Purpose |
|---|---|---|
| `imageinfo` | `windows.info` | Identify OS profile/version |
| `pslist` | `windows.pslist` | List running processes (linked-list walk) |
| `pstree` | `windows.pstree` | Process tree (parent/child) |
| `psscan` | `windows.psscan` | Pool-scan for processes (finds hidden/terminated) |
| `psxview` | — (combine `pslist`/`psscan`) | Cross-reference process-listing methods |
| `netscan` | `windows.netscan` | Network connections and listeners |
| `printkey` | `windows.registry.printkey` | Dump a registry key |
| `svcscan` | `windows.svcscan` | List Windows services |
| `mftparser` | `windows.mftscan.MFTScan` | Scan memory for `$MFT` entries |
| `procdump` | `windows.dumpfiles` / `windows.pslist --dump` | Dump a process's executable image |

---

## OS Info

### Imageinfo Plugin (Volatility 2)

```bash copy
vol.py -f memory.dmp imageinfo
```

Suggests the `--profile` value (OS version, build, and architecture) needed for every other Volatility 2 plugin. Volatility 3 doesn't need this step — `windows.info` auto-detects the profile.

### kdbgscan Plugin (Volatility 2)

```bash copy
vol.py -f memory.dmp kdbgscan
```

Locates the Kernel Debugger Block (`KDBG`) directly rather than guessing. Use this when `imageinfo` returns multiple candidate profiles, or when the suggested profile produces empty output from `pslist`/`pstree`.

---

## Windows Processes

### PSLIST

```bash copy
vol.py -f memory.dmp --profile=<profile> pslist
```

- Walks the kernel's `PsActiveProcessHead` doubly-linked list of `_EPROCESS` structures.
- Reports PID, PPID, thread/handle counts, and process create/exit times.
- **Limitation**: a process unlinked from this list (DKOM-style hiding) is invisible to `pslist` — cross-check with `psscan` and `psxview`.

### PSTREE

```bash copy
vol.py -f memory.dmp --profile=<profile> pstree
```

- Same underlying data as `pslist`, rendered as a parent/child tree.
- Useful for spotting a suspicious child process under an unexpected parent — e.g. `winword.exe` spawning `powershell.exe` or `cmd.exe`.

### PSXVIEW

```bash copy
vol.py -f memory.dmp --profile=<profile> psxview
```

- Cross-references multiple process-enumeration methods (`pslist`, `psscan`, thread scanning, session enumeration, etc.) in a single table.
- A process present in `psscan` but **absent from `pslist`** is a strong indicator of process hiding via DKOM or a similar technique.

### PSINFO

```bash copy
vol.py -f memory.dmp --profile=<profile> psinfo
```

- Provides detailed metadata for a single process: full command line, parent PID, session ID, and associated security identifiers.

### Process Privileges — GETSIDS Plugin

```bash copy
vol.py -f memory.dmp --profile=<profile> getsids -p <PID>
```

- Lists the SIDs (user, group, and privilege SIDs) attached to a process's access token.
- A normal user-context process holding `S-1-5-18` (SYSTEM) or `S-1-5-32-544` (Administrators) is a red flag for privilege escalation or token theft/impersonation.

---

## Network Connections

### Connections — NETSCAN Plugin

```bash copy
vol.py -f memory.dmp --profile=<profile> netscan
```

Pool-scans for `_TCP_ENDPOINT` / `_UDP_ENDPOINT` structures, so it finds connections even after they've closed — unlike the older `connections`/`connscan` plugins, which only walk live lists.

| Field | Meaning |
|---|---|
| `Offset(P)` | Physical memory offset of the structure — useful for manual carving/verification |
| `Proto` | Protocol and address family (TCPv4, UDPv6, etc.) |
| `Local Address` | Local IP:port |
| `Foreign Address` | Remote IP:port |
| `State` | TCP state (`ESTABLISHED`, `LISTENING`, `CLOSED`, `TIME_WAIT`, …) |
| `PID` / `Owner` | Owning process ID and image name |
| `Created` | Timestamp the socket was opened, if recoverable |

**Tip:** Cross-reference `PID`/`Owner` against `pstree`. A `LISTENING` socket owned by an unexpected process (e.g. `notepad.exe`) is a strong indicator of a backdoor or injected listener.

---

## Persistence

### Volatility printkey Plugin

```bash copy
vol.py -f memory.dmp --profile=<profile> printkey -K "<registry key path>"
```

Dumps the live in-memory values of a registry key. Because it reflects the registry's **current** in-memory state, it can show changes made since boot that haven't yet been flushed to the on-disk hive.

### Common Persistence-Related Keys

**SOFTWARE hive (machine-wide):**

| Key | Notes |
|---|---|
| `Microsoft\Windows\CurrentVersion\Run` / `RunOnce` | Autostart entries applied to all users |
| `Microsoft\Windows NT\CurrentVersion\Winlogon` (`Shell`, `Userinit`) | Shell or logon-script hijacking |
| `Microsoft\Windows NT\CurrentVersion\Windows` (`AppInit_DLLs`) | DLLs injected into every process that loads `user32.dll` |

**NTUSER.DAT hive (per user):**

| Key | Notes |
|---|---|
| `Software\Microsoft\Windows\CurrentVersion\Run` / `RunOnce` | Autostart entries for this user only |
| `Software\Microsoft\Windows NT\CurrentVersion\Windows` (`Load`, `Run`) | Legacy per-user autostart values |

For Scheduled Tasks and Windows Services as persistence vectors, see [Execution-Evidence.md](Execution-Evidence.md#scheduled-tasks) and the `svcscan` plugin below.

### Volatility svcscan Plugin

```bash copy
vol.py -f memory.dmp --profile=<profile> svcscan
```

Lists Windows services known to the Service Control Manager at capture time — service name, display name, state, and binary path. Useful for spotting a malicious service that has since been stopped or deleted from disk but is still resident in memory structures.

---

## Files

### Master File Table (MFT)

Fragments of the on-disk `$MFT` are frequently cached in memory and can be recovered even when the disk image is unavailable or has been wiped.

### MFT Parser Plugin

```bash copy
vol.py -f memory.dmp --profile=<profile> mftparser
```

Scans memory for `$MFT` record signatures and extracts:

| Attribute | Meaning |
|---|---|
| `$STANDARD_INFORMATION` | Created/Modified/Accessed/MFT-Modified timestamps (the "SI" set — easily timestomped) |
| `$FILE_NAME` | A second, independent timestamp set plus the file's name (the "FN" set) |
| `$DATA` | The file's content, if resident (small files only) |

### Investigation of MFT

When triaging recovered MFT entries, prioritize paths commonly used by malware for staging and persistence:

```
C:\Windows\Temp
C:\Users\<user>\Downloads
C:\Program Files\<unexpected vendor folder>
C:\Windows\System32 / SysWOW64
C:\Users\<user>\AppData\
C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
C:\Users\<user>\Documents
```

---

## Process Memory Dump

```bash copy
vol.py -f memory.dmp --profile=<profile> procdump -p <PID> -D C:\cases\out\
```

Extracts the executable image of a specific process from memory — use this to recover a packed or injected payload that exists only in RAM, then hand it off to [../Malware-Analysis/Static-Analysis.md](../Malware-Analysis/Static-Analysis.md).

---

## Quick Triage Workflow

```bash copy
# 1. Identify the OS profile
vol.py -f memory.dmp imageinfo
vol.py -f memory.dmp kdbgscan          # if imageinfo is ambiguous

# 2. Enumerate processes
vol.py -f memory.dmp --profile=<profile> pslist
vol.py -f memory.dmp --profile=<profile> pstree
vol.py -f memory.dmp --profile=<profile> psxview   # cross-check for hidden processes

# 3. Check network state
vol.py -f memory.dmp --profile=<profile> netscan

# 4. Check persistence
vol.py -f memory.dmp --profile=<profile> svcscan
vol.py -f memory.dmp --profile=<profile> printkey -K "Microsoft\Windows\CurrentVersion\Run"

# 5. Extract Windows Event Logs from memory
vol.py -f memory.dmp --profile=<profile> evtlogs --save-evt
```

**Tip:** Event log records carved out of memory with `evtlogs --save-evt` can be opened directly in Event Viewer or parsed with [EvtxECmd](https://github.com/EricZimmerman/evtx) — useful when the on-disk `.evtx` files were cleared before the in-memory records were flushed. See [../Threat-Hunting/Sysmon.md](../Threat-Hunting/Sysmon.md) and [../Threat-Hunting/KQL-Threat-Hunting.md](../Threat-Hunting/KQL-Threat-Hunting.md) for what to hunt for once those logs are recovered.
