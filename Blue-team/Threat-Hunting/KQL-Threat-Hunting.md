# KQL Threat Hunting Notes

Hunting queries for Kibana/Elasticsearch using ECS-mapped fields from Winlogbeat and Sysmon. `event.code` maps to either a Sysmon event ID or a native Windows Event ID depending on `winlog.channel` (`Microsoft-Windows-Sysmon/Operational` vs. `Security`/`System`) — check the channel before assuming which ID table applies. For the full Sysmon event ID reference, see [Sysmon.md](Sysmon.md).

## Endpoint Threat Hunting

### Encoded PowerShell Commands

```kql
event.code: 4688
and process.command_line: (*-enc* OR *-EncodedCommand* OR *-nop* OR *download* OR *IEX* OR *Invoke-Expression* OR *Invoke-Command*)
```

Detects suspicious PowerShell flags in process-creation events (Event ID 4688):

- `event.code: 4688` — a new process has been created (Process Creation)
- `process.command_line:` — full command line of the executed process
- `*-enc* OR *-EncodedCommand*` — looks for Base64-encoded payloads
- `*-nop*` — no profile loading (common in attacks)
- `*download* OR *IEX* OR *Invoke-Expression*` — typical download-cradle keywords

```kql
event.code: 4104
AND message: (*downloadstring* OR *download* OR *Invoke-Expression* OR *IEX* OR *-exec* OR *-ExecutionPolicy* OR *-EncodedCommand* OR *-enc* OR *-nop*)
```

Catches the actual decoded PowerShell script blocks (via Script Block Logging):

- `event.code: 4104` — Script Block Logging, records the content of executed PowerShell blocks
- `message:` — contains the actual (deobfuscated) script content
- All keywords above are direct indicators of malicious download/execution behavior

#### Relevant Windows Event IDs

| Event ID | Name | Why it matters for threat hunting |
|---|---|---|
| 4688 | Process Creation | Shows the full command line of the executed process |
| 4689 | Process Termination | Helps with correlation (who ended, and when) |
| 4104 | Script Block Logging | Most valuable — shows the content of executed PS blocks |

#### Common PowerShell Flags and Abbreviations Used in Attacks

| Flag / Abbreviation | Full Name | Description in an attack |
|---|---|---|
| `-EncodedCommand`, `-e`, `-enc` | `--EncodedCommand` | Executes Base64-encoded commands — classic obfuscation |
| `-WindowStyle Hidden`, `-w hidden` | `--WindowStyle Hidden` | Runs PowerShell in a hidden window |
| `-ExecutionPolicy Bypass`, `-exec bypass` | `--ExecutionPolicy Bypass` | Bypasses the script execution policy |
| `-NoProfile`, `-nop` | `--NoProfile` | Skips loading the user profile (faster, fewer traces) |
| `-NonInteractive`, `-noni` | `--NonInteractive` | Runs without user interaction |
| `Invoke-Expression`, `iex`, `IEX` | `Invoke-Expression` | Executes code in memory — most common in download cradles |

#### Key PowerShell Keywords for Detecting Malicious Activity

| Keyword | Description in an attack |
|---|---|
| `download` / `DownloadString` / `DownloadFile` | Downloading a payload from the internet |
| `Start-Process` | Launching additional processes (often a second stage) |
| `IEX` / `Invoke-Expression` | Executing downloaded or dynamically generated code |
| `WebClient` | Creating an object used to download files |
| `bitstransfer` | Using BITS for stealthy downloads |
| `Invoke-Command` | Remote execution — often lateral movement |
| `rundll32` | Running DLLs without a direct executable |
| `HTTP` / `HTTPS` | Indicates outbound communication (C2, download cradle, exfiltration) |

---

### Persistence via Scheduled Tasks

#### Detecting schtasks.exe Abuse (Sysmon Event ID 1 + Windows Event 4688)

```kql
event.code: 1
AND process.name: "schtasks.exe"
```

Hunts every execution of `schtasks.exe` via Sysmon Process Creation (`event.code: 1` = Sysmon Event ID 1; `process.name` is case-insensitive in older Kibana versions).

```kql
event.code: 4688
AND process.name: "schtasks.exe"
```

Same hunt, from native Windows Process Creation logs (`event.code: 4688` = a new process was created, Security log).

```kql
event.code: 106
```

Direct detection of task creation in the Task Scheduler Operational log (`event.code: 106` = scheduled task created, `Microsoft-Windows-TaskScheduler/Operational`).

```kql
event.code: 4698
```

Security-log version of task creation — requires Object Access auditing to be enabled (`event.code: 4698` = a scheduled task was created).

#### Hunting for Known Malicious Scheduled Task Patterns

```kql
event.code: 1
AND process.name: schtasks.exe
AND process.command_line: (*/create* OR */delete* OR rundll32 OR regsvr32 OR powershell OR cmd)
```

Catches the most common malicious `schtasks` patterns in one query:

- `*/create*` / `*/delete*` — task creation/deletion switches
- `rundll32 OR regsvr32 OR powershell OR cmd` — suspicious binaries passed in the `/TR` parameter

#### Relevant Event IDs — Scheduled Tasks

| Event ID | Log Source | Why it matters for threat hunting |
|---|---|---|
| 106 | Microsoft-Windows-TaskScheduler/Operational | Scheduled task created (most reliable) |
| 140 | TaskScheduler Operational | Scheduled task updated |
| 141 | TaskScheduler Operational | Scheduled task deleted |
| 200 | TaskScheduler Operational | Scheduled task executed |
| 201 | TaskScheduler Operational | Scheduled task completed |
| 4698 | Security | Scheduled task created (requires Object Access auditing) |
| 4699 | Security | Scheduled task deleted |
| 4700 | Security | Scheduled task enabled |
| 4701 | Security | Scheduled task disabled |
| 4702 | Security | Scheduled task updated |
| 1 / 4688 | Sysmon / Windows Security | Full command line showing `schtasks.exe` usage |

#### Classic Malicious Scheduled Task Examples (for Context)

**PowerShell persistence (daily):**

```bash copy
schtasks.exe /create /sc daily /tn "MaliciousTask" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\payload.ps1" /st 06:00
```

**rundll32 persistence (on startup, as SYSTEM):**

```bash copy
schtasks.exe /create /sc onstart /tn "MaliciousTask" /tr "rundll32.exe C:\Windows\Temp\Evil.dll,Evil" /ru SYSTEM
```

---

### Credential Dumping

#### Detect Suspicious Processes (mimikatz / procdump / reg save)

```kql
event.code: 4688
AND process.command_line: (*mimikatz* OR *procdump* OR *reg.exe*)
```

Catches classic credential-dumping tools via Windows Process Creation (`event.code: 4688`, Security log).

```kql
event.code: 1
AND process.command_line: (*mimikatz* OR *procdump* OR *reg.exe*)
```

Same hunt via Sysmon (`event.code: 1`) — usually has better command-line fidelity.

#### Track Processes Accessing LSASS Memory (Sysmon Event ID 10)

```kql
event.code: 10
AND winlog.event_data.TargetImage: *lsass.exe
AND winlog.event_data.GrantedAccess: (0x1010 OR 0x1410 OR 0x1438 OR 0x143A OR 0x1418)
```

Catches LSASS memory access **before** the dump even happens:

- `event.code: 10` — Sysmon Process Access
- `TargetImage: *lsass.exe*` — only processes touching LSASS
- `GrantedAccess` values — typical rights requested by mimikatz/procdump (read VM + query info)

#### Monitor File Creation for Memory Dumps (Sysmon Event ID 11)

```kql
event.code: 11
AND process.name:(*procdump.exe* OR *rundll32.exe* OR *taskmgr.exe* OR *powershell.exe* OR *wmic.exe* OR *schtasks.exe* OR *cmd.exe* OR *comsvcs.dll*)
AND file.name: (lsass.* OR *.dmp OR *.zip OR *.rar)
```

Detects the moment a dump file hits disk (`event.code: 11` = Sysmon File Create), combining suspicious parent processes with classic dump-file extensions.

#### Trace Credential Dumping Scripts in PowerShell Script Block Logging (Event ID 4104)

```kql
event.code: 4104
AND winlog.event_data.ScriptBlockText: (*Invoke-Mimikatz* OR *procdump.exe -ma lsass* OR *rundll32.exe comsvcs.dll MiniDump* OR *taskmgr.exe /dump*)
```

Catches reflective/in-memory mimikatz and native dump techniques by looking directly inside executed PowerShell code for the most common one-liners (`event.code: 4104` = PowerShell Script Block Logging).

---

### Tracking Account Usage & Logon Sessions

#### Common Logon-Related Event IDs

| Event ID | Description | Why it matters for hunting |
|---|---|---|
| 4624 | Successful Logon | Who logged on, and how |
| 4625 | Failed Logon | Brute-force / password-spray attempts |
| 4672 | Privileged Logon (`SeAssignPrimaryToken`) | Who was granted SERVICE/ADMIN-level rights |
| 4720 | User Account Created | New account — often a backdoor |
| 4726 | User Account Deleted | Covering tracks |
| 4634 | Logoff / Session Ended | End of session — pairs well with 4624 for correlation |

#### Logon Types (`winlog.event_data.LogonType`)

| Logon Type | Name | Description in threat hunting |
|---|---|---|
| 0 | System | SYSTEM account only (e.g. at boot) |
| 2 | Interactive | Physical logon at the keyboard (most common on workstations) |
| 3 | Network | Network logon (SMB, WinRM, PsExec) — classic lateral movement |
| 4 | Batch | Scheduled tasks / batch jobs |
| 5 | Service | Service start |
| 7 | Unlock | Screen unlock |
| 8 | NetworkCleartext | Cleartext password (rare, but a major red flag) |
| 9 | NewCredentials | Token cloned with new credentials (pass-the-hash variant) |
| 10 | RemoteInteractive | RDP / Terminal Services — most commonly attacked |
| 11 | CachedInteractive | Cached logon (no DC contact) — useful when there's no connectivity |
| 12 | CachedRemoteInteractive | Like 10, but cached |
| 13 | CachedUnlock | Cached unlock |

#### Track a Full Logon Session (Example: a Specific Session on Host `sql`)

```kql
event.code: ("4624" OR "4634")
AND host.name: sql
AND winlog.event_data.LogonType: 3
AND winlog.event_data.TargetLogonId: 0x76b6e92
```

Shows the start and end of one specific logon session:

- `4624` — session start
- `4634` — session end (logoff)
- `LogonType: 3` — network logons only (the most interesting for lateral movement)
- `TargetLogonId` — the unique session identifier; extract it from a 4624 event and pivot on it

---

### Lateral Movement (PsExec)

#### PsExec EULA Registry Key (First Sign of Installation)

```kql
event.code: 13
AND registry.key: *\\PsExec\\EulaAccepted*
```

- `event.code: 13` — Sysmon Registry Event (value set)
- `*\\PsExec\\EulaAccepted*` — PsExec always creates this key on first run

#### Service Creation — PSEXESVC (the Classic)

```kql
event.code: 7045
AND winlog.event_data.ServiceName: PSEXESVC
```

```kql
event.code: 13
AND registry.key: *\\PSEXESVC
```

- `7045` (System log) — a new service was installed
- `PSEXESVC` in the registry — an additional trace of the service

#### Type 3 Network Logon + Immediate PSEXESVC Creation (Major Red Flag)

```kql
event.code: (4624 OR 7045)
AND winlog.event_data.LogonType: 3
AND winlog.event_data.ServiceName: PSEXESVC
```

Correlates in time: a network logon (LogonType 3) immediately followed by the PSEXESVC service — nearly always PsExec.

#### Process Execution — PsExec.exe & PSEXESVC.exe

```kql
event.code: 1
AND process.name: PsExec*
```

```kql
event.code: 4688
AND process.name: PsExec*
```

```kql
process.name: PSEXESVC.exe
```

Direct execution of `PsExec.exe` or the `PSEXESVC.exe` service binary.

#### Named Pipes Created by PsExec (Sysmon Event ID 18)

```kql
event.code: 18
AND file.name: \\PSEXESVC*
```

`event.code: 18` = Sysmon Named Pipe Created. Example pipe names:

```
\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stdin
\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stdout
\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stderr
```

---

## Walkthrough — Lab 1: Detection Commands

Ready-to-paste detection queries.

### 1. Scheduled Tasks Abuse (schtasks.exe Execution)

```kql
process.name: "schtasks.exe"
```

Catches every execution of `schtasks.exe` (Sysmon Event ID 1 or Windows 4688).

### 2. PsExec Execution (64-bit + 32-bit)

```kql
process.name: PsExec64.exe OR process.name: PsExec.exe
```

Direct detection of the PsExec binary (most often manually dropped by the attacker).

### 3. LSASS Memory Access (Sysmon Event ID 10 — Classic Credential Dumping)

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"
AND event.code: "10"
AND winlog.event_data.TargetImage: *lsass.exe*
```

The best early indicator of mimikatz/procdump activity:

- `event.code: 10` — one process accessed another
- `TargetImage: *lsass.exe*` — only access to LSASS (filter further on `GrantedAccess` if needed)

---

## Walkthrough — Lab 2: Additional Hunting Queries

### 1. Processes Launched from the Downloads Folder

```kql
@timestamp >= "2022-11-08T00:00:00Z" AND @timestamp <= "2022-11-08T23:59:59Z" AND winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.executable: *Downloads*
```

Catches everything executed directly from the Downloads folder over the full day of 2022-11-08 — classic user behavior after opening a malicious file.

### 2. Creation of moviedownloader.exe (Dropper/Malware)

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 11 AND file.path: *moviedownloader.exe*
```

Sysmon Event ID 11 (File Create) — a file named `moviedownloader.exe` was just dropped to disk (a highly suspicious name).

### 3. Run/RunOnce Key Modification by User `cmurfy` (Persistence)

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 13 AND registry.key: *Run* AND related.user: "cmurfy"
```

Sysmon Event ID 13 (Registry value set) — user `cmurfy` just added something to autostart, a classic persistence technique.

### 4. Execution of Any .bat File

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.command_line: *.bat*
```

Catches any process whose command line contains `.bat` — very common in LOLBin/living-off-the-land attacks.

### 5. Process with a Specific PID (7932)

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.pid: 7932
```

Looks for the exact process with PID 7932 — useful once a specific PID is known to be malicious.

### 6. PowerShell Started with PID 6024

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.pid: 6024 AND process.executable: *powershell.exe
```

Pinpoints a specific PowerShell instance (PID 6024) — ideal for pivoting from a known-bad PID.

### 7. New Service Installed on Host DC-01

```kql
winlog.event_id: 7045 AND agent.name: "DC-01"
```

Windows Event ID 7045 (new service installed) on host DC-01 — often used by attackers for persistence.

### 8. PsExec Execution (Alternate Syntax)

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.executable: (*PsExec.exe OR *PsExec64.exe)
```

Catches execution of PsExec/PsExec64 — a lateral-movement classic.

---

## Network Threat Hunting

### Lab 1

```kql
agent.type: "packetbeat" AND type: dns AND NOT dns.response_code: "NOERROR"
```

Looks for DNS queries that returned a response code other than `NOERROR` (e.g. `REFUSED`, `SERVFAIL`).

```kql
agent.type: "packetbeat" AND type: dns AND dns.response_code: "NXDOMAIN"
```

Looks for DNS queries that returned `NXDOMAIN` (the domain does not exist).

### Lab 2

```kql
agent.type: "packetbeat" and type: "dns"
```

Basic filter for all DNS queries from Packetbeat (no additional conditions).

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND dns.question.registered_domain: "downloadmoviesonline.shop" AND event.code: "22"
```

Sysmon Event 22 (DNS query) containing the registered domain `downloadmoviesonline.shop`.

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND dns.question.name: "downloadmoviesonline.shop" AND event.code: "22"
```

Sysmon Event 22 for the exact query `downloadmoviesonline.shop`.

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: "3" and destination.ip: "3.210.135.57"
```

Sysmon Event 3 (Network connection) to the specific IP `3.210.135.57`.

```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: "1" and process.name: powershell.exe
```

Sysmon Event 1 (Process creation) where the process is `powershell.exe`.

```kql
event.category: "network" AND event.module: "endpoint" AND destination.port: 8000 AND network.protocol: ("http" OR "https")
```

Network connections on port 8000 over HTTP or HTTPS, from the endpoint module.

```kql
@timestamp >= "2022-11-13T12:45:40Z" AND @timestamp <= "2022-11-13T23:59:59Z" AND winlog.event_id: 7045 AND agent.name: "DC-01"
```

New services (Event 7045) created on host DC-01 within a specific time window.

```kql
winlog.event_id: 4624 AND agent.name: "DC-01"
```

Logons (Event 4624) on server DC-01.
