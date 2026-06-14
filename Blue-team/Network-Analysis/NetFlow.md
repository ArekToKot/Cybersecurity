# NetFlow Analysis with nfdump

NetFlow records — exported by routers/switches as v5, v9, or IPFIX — summarize *who talked to whom, when, and how much*, without capturing packet content. Use it for a fast, low-storage overview of activity across an entire network; switch to [Wireshark.md](Wireshark.md) for full packet inspection of any conversation flagged here.

## What Is a Flow?

A **flow** is a one-directional sequence of packets that share the same 5-tuple:

- Source IP address
- Destination IP address
- Source port
- Destination port
- Protocol (TCP, UDP, ICMP, …)

As packets cross a router or switch, the device tracks each flow and, once it ends (or on a timer), exports a single summary record — start/end time, packet count, byte count — to a collector. **No packet payload is ever exported.** A normal TCP conversation produces two records, one for each direction.

## Tools

| Tool | Platform | Link |
|---|---|---|
| nfdump | Linux / Windows (WSL) | [GitHub](https://github.com/phaag/nfdump) |
| SiLK | Linux | [CERT NetSA](https://tools.netsa.cert.org/silk/) |
| ntopng | Linux / Windows / macOS | [ntop.org](https://www.ntop.org/products/traffic-analysis/ntop/) |

## Collecting NetFlow Data

Before `nfdump` has anything to read, a router or switch must be configured to generate flow records and export them to a collector.

### Example: Cisco IOS

```
! Define the collector and NetFlow version
ip flow-export destination 192.168.1.100 2055
ip flow-export version 9
ip flow-export source GigabitEthernet0/1

! Enable flow accounting on an interface, in both directions
interface GigabitEthernet0/1
 ip flow ingress
 ip flow egress

! Optional: tune how quickly flows are exported
ip flow-cache timeout active 60
ip flow-cache timeout inactive 15
```

### Setting Up a Collector

The collector receives and stores exported records — [nfdump](https://github.com/phaag/nfdump) writes the `nfcapd.*` files used throughout this page, but [ntopng](https://www.ntop.org/products/traffic-analysis/ntop/), [ElastiFlow](https://www.elastiflow.com/), and commercial tools like SolarWinds work the same way. **The collector's configured version must match the exporter** (v5, v9, or IPFIX) — a mismatch silently drops every record.

## Basic Syntax

```bash copy
nfdump -r <file> [options]
```

## Output Fields

| Field | Meaning | Example |
|---|---|---|
| `Date flow start` | Date the flow was first observed | `2015-11-24` |
| `first seen` | Time the flow was first observed, to the millisecond | `18:18:59.504` |
| `Duration` | How long the flow lasted (HH:MM:SS.mmm) | `00:00:00.108` |
| `Proto` | Transport protocol (TCP, UDP, ICMP, …) | `UDP` |
| `Src IP Addr:Port` | Source IP address and port | `10.1.25.119:50575` |
| `Dst IP Addr:Port` | Destination IP address and port | `224.0.0.252:5355` |
| `Packets` | Total packets transmitted | `2` |
| `Bytes` | Total bytes transmitted | `104` |
| `Flows` | Number of individual flows aggregated into this record | `1` |

**Note:** Some columns (e.g. `Duration`) are hidden by default in certain `nfdump` builds. Add `-o extended` to display the full field set:

```bash copy
nfdump -r <file> -o extended
```

## Common Tasks

### Filtering Flows by Source IP

```bash copy
nfdump -r nfcapd.202401011200 -A srcip -n 10
```

Aggregates flows by source IP and shows the top 10 — a quick way to find the most active hosts.

### Identifying Top Talkers by Bytes

```bash copy
nfdump -r nfcapd.202401011200 -s record/bytes -n 10
```

Sorts flows by total bytes transferred and shows the top 10 — a large outbound byte count to an unfamiliar external IP can indicate data exfiltration.

### Analyzing Traffic Over Time

```bash copy
nfdump -r nfcapd.202401011200 -s record/bytes -t 10
```

Buckets traffic into 10-minute intervals — useful for spotting spikes or sustained transfers that line up with an incident window.

### Filtering by Protocol or Port

```bash copy
nfdump -r nfcapd.202401011200 'proto tcp and dst port 443'
```

Narrows results to a specific protocol/port — e.g. isolate all outbound HTTPS to check for connections to known-bad infrastructure.

**Hunting angle:** Look for **beaconing** — many short flows of near-identical size and duration, repeating at a regular interval, to the same destination. A high `Flows` count combined with a low `Bytes`/`Packets` count per flow is a classic C2 check-in pattern.
