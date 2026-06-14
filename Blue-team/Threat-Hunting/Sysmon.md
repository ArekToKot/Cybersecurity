# Sysmon Event ID Reference

[Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) (System Monitor, part of Sysinternals) logs detailed process, network, file, and registry activity to `Microsoft-Windows-Sysmon/Operational`. A well-tuned configuration — e.g. [SwiftOnSecurity's sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config) or [Olaf Hartong's sysmon-modular](https://github.com/olafhartong/sysmon-modular) — is the foundation most of the queries in [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md) are built on.

## Most Useful Event IDs for Hunting

| Event ID | Event | Why it matters |
|---|---|---|
| 1 | Process Create | The core of endpoint hunting — command line, parent process, hashes |
| 3 | Network Connection | Outbound/inbound connections per process — C2 and lateral movement |
| 7 | Image Loaded | DLL loads — detects DLL sideloading/injection |
| 8 | CreateRemoteThread | Classic process-injection technique |
| 10 | Process Access | Access to sensitive processes (e.g. LSASS) — credential dumping |
| 11 | File Create | New files written to disk — drops, staging, ransomware |
| 12-14 | Registry Event | Registry key/value create, modify, rename — persistence |
| 17/18 | Pipe Created/Connected | Named pipes — common C2 and lateral-movement (PsExec) channel |
| 22 | DNS Query | Domains resolved per process — C2 domains, DNS tunneling |

## Full Event ID Table

| ID | Tag | Event |
|---|---|---|
| 1 | ProcessCreate | Process Create |
| 2 | FileCreateTime | File creation time changed |
| 3 | NetworkConnect | Network connection detected |
| 4 | n/a | Sysmon service state change (cannot be filtered) |
| 5 | ProcessTerminate | Process terminated |
| 6 | DriverLoad | Driver loaded |
| 7 | ImageLoad | Image loaded |
| 8 | CreateRemoteThread | CreateRemoteThread detected |
| 9 | RawAccessRead | RawAccessRead detected |
| 10 | ProcessAccess | Process accessed |
| 11 | FileCreate | File created |
| 12 | RegistryEvent | Registry object added or deleted |
| 13 | RegistryEvent | Registry value set |
| 14 | RegistryEvent | Registry object renamed |
| 15 | FileCreateStreamHash | File stream created |
| 16 | n/a | Sysmon configuration change (cannot be filtered) |
| 17 | PipeEvent | Named pipe created |
| 18 | PipeEvent | Named pipe connected |
| 19 | WmiEvent | WMI filter |
| 20 | WmiEvent | WMI consumer |
| 21 | WmiEvent | WMI consumer filter |
| 22 | DNSQuery | DNS query |
| 23 | FileDelete | File delete (archived) |
| 24 | ClipboardChange | New content in the clipboard |
| 25 | ProcessTampering | Process image change |
| 26 | FileDeleteDetected | File delete (logged) |
| 27 | FileBlockExecutable | File block executable |
| 28 | FileBlockShredding | File block shredding |
| 29 | FileExecutableDetected | File executable detected |
| 255 | Error | Error |

See [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md) for hunting queries built on these event codes.
