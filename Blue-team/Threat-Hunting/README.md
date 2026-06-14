# Threat Hunting

Proactive hunting across endpoint and network logs, IDS/IDPS alerts, and phishing reports.

## Files

| File | Description |
|---|---|
| [Sysmon.md](Sysmon.md) | Sysmon event ID reference — what each event records and which IDs matter most for hunting |
| [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md) | Kibana/KQL hunting queries over Winlogbeat/Sysmon data: encoded PowerShell, persistence, credential dumping, lateral movement (PsExec), and network DNS/connection hunts |
| [Zui.md](Zui.md) | Zui (Zed Query Language) queries for hunting Suricata/Zeek alerts |
| [Commands.md](Commands.md) | `awk`/`grep` one-liners for triaging Apache/Nginx web access logs |
| [Phishing.md](Phishing.md) | Phishing email triage checklist: headers, links, and attachments |

## Suggested Workflow

1. **Know your event IDs** — [Sysmon.md](Sysmon.md): reference before writing any endpoint query, so you know which event code to filter on.
2. **Endpoint & network hunts** — [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md): run ELK/Kibana queries for PowerShell abuse, persistence, credential dumping, lateral movement, and DNS/network anomalies.
3. **Alert-driven hunting** — [Zui.md](Zui.md): pivot from Suricata/Zeek alerts to the processes and hosts involved.
4. **Web log triage** — [Commands.md](Commands.md): quick command-line triage when working directly against raw access logs instead of a SIEM.
5. **Phishing reports** — [Phishing.md](Phishing.md): dedicated checklist for user-reported phishing emails, feeding suspicious attachments into [../Malware-Analysis/README.md](../Malware-Analysis/README.md).

Findings from any of these hunts that point to a specific host should be followed up with [../Forensic/README.md](../Forensic/README.md) for disk/memory artifact analysis.
