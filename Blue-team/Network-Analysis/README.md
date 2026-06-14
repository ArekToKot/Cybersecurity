# Network Analysis

Capturing traffic and flow data, then analyzing it during or after an incident — from getting a PCAP, to a high-level flow overview, down to individual packets.

## Files

| File | Description |
|---|---|
| [Traffic-Capture.md](Traffic-Capture.md) | Getting a PCAP onto an analysis host: SPAN/port mirroring on switches and packet capture with tcpdump |
| [NetFlow.md](NetFlow.md) | High-level flow analysis with nfdump: what a flow is, exporting flows from a router, output fields, top talkers, traffic-over-time, and beaconing detection |
| [Wireshark.md](Wireshark.md) | Packet-level filter syntax, a cheat-sheet of useful filters and how to combine them, indicator-specific hunting filters, and post-processing: file extraction, LSASS dump cracking |

## Suggested Workflow

1. **Capture** — [Traffic-Capture.md](Traffic-Capture.md): if no capture exists yet, mirror a switch port (SPAN) or tap a router and record traffic with tcpdump.
2. **Overview** — [NetFlow.md](NetFlow.md): start with flow data to identify top talkers, unusual ports/protocols, and candidate time windows without the overhead of full packet capture.
3. **Deep-dive** — [Wireshark.md](Wireshark.md): once a conversation or host is flagged, inspect the full PCAP with display filters to confirm the activity and extract any transferred files or credential dumps.
4. **Analyze recovered binaries** — files extracted from traffic (e.g. dropped `.exe`/`.dll`) go to [../Malware-Analysis/README.md](../Malware-Analysis/README.md); network indicators observed during sandboxing in [../Malware-Analysis/Dynamic-Analysis.md](../Malware-Analysis/Dynamic-Analysis.md) can be fed back into the filters here.
5. **Cross-reference host artifacts** — correlate flagged connections and timestamps with [../Forensic/README.md](../Forensic/README.md) to confirm what the host itself was doing at the time.
