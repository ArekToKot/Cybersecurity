# Blue Team

Notes for defensive security work: detecting, investigating, and analyzing intrusions across endpoints and the network.

## Sections

| Section | Description |
|---|---|
| [Threat-Hunting/](Threat-Hunting/README.md) | Proactive hunting queries (KQL, Zui) and reference tables (Sysmon, web logs, phishing) for detecting suspicious activity |
| [Forensic/](Forensic/README.md) | Disk and memory artifact analysis for investigating a host after suspicious activity is found |
| [Network-Analysis/](Network-Analysis/README.md) | Capturing traffic, plus NetFlow and packet-level (Wireshark) analysis of it |
| [Malware-Analysis/](Malware-Analysis/README.md) | Static and dynamic analysis of malicious files recovered during an investigation |

## Suggested Incident Workflow

1. **Detect** — [Threat-Hunting/](Threat-Hunting/README.md): proactive queries and alert triage surface a suspicious host, account, or process.
2. **Investigate** — [Forensic/](Forensic/README.md) and [Network-Analysis/](Network-Analysis/README.md): pull disk/memory artifacts from the affected host and inspect any captured traffic to build a timeline.
3. **Analyze** — [Malware-Analysis/](Malware-Analysis/README.md): any malicious binary or document recovered during investigation goes through static/dynamic analysis to extract IOCs.
4. **Feed back** — IOCs and TTPs from analysis loop back into [Threat-Hunting/](Threat-Hunting/README.md) to hunt for the same activity elsewhere in the environment.
