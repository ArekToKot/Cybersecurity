# Zui (Zed Query Language) — Suricata/Zeek Alert Hunting Cheat-Sheet

[Zui](https://www.brimdata.io/zui/) is a desktop log explorer for Zeek and Suricata EVE-JSON data, queried with Zed's pipe-based query language (`|`-chained `filter`/`count`/`sort`/`limit` operators). The fields used below (`event_type`, `alert.signature`, `alert.severity`, `computer_name`, `process.name`) come from Suricata EVE-JSON / Zeek logs — **not** CrowdStrike Falcon Query Language, despite the similar pipe syntax.

## Tools

| Tool | Platform | Link |
|---|---|---|
| Zui | Windows / Linux / macOS | [brimdata.io/zui](https://www.brimdata.io/zui/) |

## Queries

### Top Alert Signatures

```zui
event_type=="alert"
| count() by alert.signature
```

Ranks every alert by signature name — the best starting point for triage, immediately showing what's firing most often.

### Top 10 Alert Signatures, Sorted

```zui
event_type=="alert"
| count() by alert.signature
| sort by _count desc
| limit 10
```

Same as above, but sorted in descending order and limited to the top 10.

### Alerts from the Last Hour

```zui
event_type=="alert"
| filter _time > now() - 1h
| count() by alert.signature
| sort by _count desc
```

### Critical / High Severity Only

```zui
event_type=="alert"
| filter alert.severity in ["Critical", "High"]
| count() by alert.signature
| sort by _count desc
```

### Alerts for a Specific Host (e.g. DESKTOP-KOAA32A)

```zui
event_type=="alert"
| filter computer_name=="DESKTOP-KOAA32A"
| count() by alert.signature
| sort by _count desc
```

### Combined Process Execution + Alert View

```zui
(event_type=="alert" OR event_type=="process")
| filter process.name in ["powershell.exe", "ps.exe", "psexec.exe", "mimikatz.exe"]
| count() by process.name, alert.signature
```

Correlates alerts with process-execution events for known dual-use/credential-dumping tools, surfacing both the alert signature and the triggering process in one view. Cross-reference with [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md) for the same tools' endpoint-side detections.
