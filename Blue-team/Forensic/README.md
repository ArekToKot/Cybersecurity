# Forensic

Post-incident artifact analysis across memory and disk — what to pull from a host, where it lives, and what it tells you about an intrusion.

## Files

| File | Description |
|---|---|
| [Disk-Forensic.md](Disk-Forensic.md) | Entry point: tooling, must-check artifact locations, and system profiling (OS version, computer name, time zone, network configuration) |
| [User-Activity.md](User-Activity.md) | Account activity/logons, file & folder history ($MFT/$UsnJrnl), user actions (MRU/Shellbags/LNK/JumpLists), and USB device forensics |
| [Execution-Evidence.md](Execution-Evidence.md) | Installed software and program-execution evidence: Prefetch, ShimCache, Amcache, BAM/DAM, SRUM, services, autoruns, scheduled tasks |
| [Memory-Forensic.md](Memory-Forensic.md) | Volatility 2/3 reference for analyzing RAM captures: processes, network connections, persistence, and recovering files/MFT records from memory |

## Suggested Workflow

1. **Acquire** — image the disk (FTK Imager/dd) and, if the host is still running, capture RAM first (order of volatility matters).
2. **Memory first** — [Memory-Forensic.md](Memory-Forensic.md): if a RAM capture is available, start here for live processes, network connections, and in-memory persistence before they're lost or overwritten.
3. **System profile** — [Disk-Forensic.md](Disk-Forensic.md): establish the host's identity, timeline anchors (time zone, boot/shutdown), and network history before digging into specific activity.
4. **User & file activity** — [User-Activity.md](User-Activity.md): build a timeline of account logons, file/folder access, and removable media usage.
5. **Program execution** — [Execution-Evidence.md](Execution-Evidence.md): determine what software ran and how it persisted.
6. **Correlate with logs** — cross-reference findings against [../Threat-Hunting/Sysmon.md](../Threat-Hunting/Sysmon.md) and [../Threat-Hunting/KQL-Threat-Hunting.md](../Threat-Hunting/KQL-Threat-Hunting.md) to confirm timelines and find related activity on other hosts.
7. **Analyze recovered binaries** — if a malicious executable or document is recovered, hand it to [../Malware-Analysis/README.md](../Malware-Analysis/README.md) for static/dynamic analysis.
