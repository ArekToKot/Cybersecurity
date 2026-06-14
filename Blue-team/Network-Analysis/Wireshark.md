# Wireshark — Packet Analysis & Post-Processing Cheat-Sheet

Filter syntax and a cheat-sheet of the most useful display filters — including how to combine them — plus indicator-specific hunting filters and post-processing steps for extracting and cracking artifacts recovered from captured traffic. For high-level flow triage before diving into packets, see [NetFlow.md](NetFlow.md); for how to get a PCAP in the first place, see [Traffic-Capture.md](Traffic-Capture.md).

## Tools

| Tool | Platform | Link |
|---|---|---|
| Wireshark | Windows / Linux / macOS | [wireshark.org](https://www.wireshark.org/) |
| tshark | Windows / Linux / macOS | [wireshark.org](https://www.wireshark.org/docs/man-pages/tshark.html) |
| NetworkMiner | Windows / Linux | [netresec.com](https://www.netresec.com/?page=NetworkMiner) |
| binwalk | Linux / Windows (WSL) | [GitHub](https://github.com/ReFirmLabs/binwalk) |
| pypykatz | Windows / Linux / macOS | [GitHub](https://github.com/skelsec/pypykatz) |
| John the Ripper | Windows / Linux / macOS | [openwall.com](https://www.openwall.com/john/) |
| hashcat | Windows / Linux / macOS | [hashcat.net](https://hashcat.net/hashcat/) |

## Initial Triage

Before writing filters, get an overview of the capture:

- **Statistics → Protocol Hierarchy** — shows the proportion of traffic per protocol; an unexpected protocol (e.g. SMB in an internet-facing capture) stands out immediately.
- **Statistics → Conversations** — sorts conversations by bytes/packets, giving an instant "top talkers" view, the packet-level equivalent of [NetFlow.md](NetFlow.md)'s top-talkers task.

---

## Filter Basics

Wireshark's filter bar (top of the window, turns green when valid) uses **display filter** syntax — it hides/shows packets already captured, unlike tcpdump's *capture filter* (BPF) syntax used in [Traffic-Capture.md](Traffic-Capture.md), which decides what gets captured in the first place.

A filter is `<field> <operator> <value>`. Fields follow a `protocol.field` naming scheme — e.g. `ip.addr`, `tcp.port`, `http.host`. Right-click any field in the packet details pane and choose **Apply as Filter** to build one without memorizing the name.

### Comparison Operators

| Operator | Meaning | Example |
|---|---|---|
| `==` (`eq`) | Equal to | `ip.addr == 10.0.0.5` |
| `!=` (`ne`) | Not equal to | `tcp.port != 80` |
| `>` `<` `>=` `<=` | Numeric comparison | `frame.len > 1000` |
| `contains` | Field contains a substring | `http.host contains "evil"` |
| `matches` | Field matches a regular expression | `dns.qry.name matches "\\.ru$"` |

### Combining Filters

| Operator | Meaning | Example |
|---|---|---|
| `and` (`&&`) | Both sides must match | `ip.addr == 10.0.0.5 and tcp.port == 443` |
| `or` (`\|\|`) | Either side matches | `tcp.port == 80 or tcp.port == 443` |
| `not` (`!`) | Negates the expression | `not arp` |
| `( … )` | Groups expressions to control precedence | `ip.addr == 10.0.0.5 and (tcp.port == 80 or tcp.port == 443)` |

**Tip:** Build filters incrementally — start broad with a host filter, then `and not (...)` away the noise: `ip.addr == 10.0.0.5 and not (arp or dns or icmp)`.

---

## Most Useful Filters

A general-purpose cheat sheet — combine these with the operators above to narrow down any capture.

| Filter | Shows |
|---|---|
| `ip.addr == x.x.x.x` | All traffic to/from a host, in either direction |
| `ip.src == x.x.x.x` / `ip.dst == x.x.x.x` | Traffic in one direction only |
| `tcp.port == 443` / `udp.port == 53` | Traffic on a specific port, either direction |
| `http` | All HTTP requests and responses |
| `dns` | All DNS queries and responses |
| `tls.handshake.type == 1` | TLS Client Hello — reveals the SNI and offered cipher suites |
| `tcp.flags.syn == 1 and tcp.flags.ack == 0` | TCP connection attempts (SYN only) |
| `tcp.analysis.retransmission` | Retransmitted packets — packet loss or a struggling connection |
| `tcp.analysis.flags` | Any TCP anomaly Wireshark flagged (retransmissions, out-of-order, zero window, …) |
| `http.response.code >= 400` | HTTP error responses |
| `arp` | ARP traffic — useful for spotting ARP spoofing/poisoning |
| `frame contains "<string>"` | Raw string/byte search across the whole frame, any protocol |

---

## Hunting Filters

Each filter below targets a specific indicator seen during an investigation — paste it into the filter bar directly, or combine it with the host/port filters above (e.g. `ip.addr == 10.0.128.130 and <filter>`) to scope it to one conversation.

### PE Header in Traffic (Executable Transfer)

Matches the DOS stub string embedded in almost every Windows PE file (`.exe`/`.dll`), which appears in traffic whenever one is downloaded or transferred unencrypted.

```wireshark
frame contains "This program cannot be run in DOS mode"
```

### Suspicious POST to a PHP Endpoint (Web Shell / C2)

Flags HTTP POST requests to a specific path commonly used by PHP web shells or simple C2 check-in scripts. Adjust the URI to match the indicator found during investigation.

```wireshark
http.request.method == "POST" and http.request.uri contains "contact.php"
```

### File Transfers over HTTP or SMB

Finds HTTP responses or SMB traffic carrying a filename — candidates for **File → Export Objects** (HTTP or SMB) to extract the transferred file.

```wireshark
http contains "filename" or smb or smb2
```

### Traffic from a Single Host

Restricts the view to one host's traffic — replace the IP with the host under investigation. Combine with a protocol filter (here, SMB) to focus on a specific activity type.

```wireshark
ip.src == 10.0.128.130 and smb2
```

### Executable/DLL Transfer over SMB

SMB file transfers where the filename ends in `.exe` or `.dll` — a strong indicator of lateral movement (tool drop) or data staging/exfiltration over a file share.

```wireshark
smb2.filename contains ".exe" or smb2.filename contains ".dll"
```

### Cleartext Credentials (FTP / Telnet / HTTP Basic Auth)

Catches plaintext authentication — FTP `PASS` commands, Telnet sessions, and HTTP Basic Auth headers.

```wireshark
ftp.request.command == "PASS" or telnet or http.authorization
```

### Possible DNS Tunneling

Unusually long TXT queries are a common DNS-tunneling indicator (data encoded into subdomains or TXT responses).

```wireshark
dns.qry.type == 16 and dns.qry.name.len > 50
```

### TLS SNI for C2 Domain Spotting

Shows the Server Name Indication (the requested hostname) from every TLS handshake — useful for spotting connections to a known-bad or freshly-registered domain even when the session itself is encrypted.

```wireshark
tls.handshake.extensions_server_name
```

---

## Post-Processing

Once a file or credential dump has been identified in the capture:

### 1. Export the File

Use **File → Export Objects → HTTP** (or **SMB**) in Wireshark, select the file flagged by the filters above, and save it — e.g. as `evil.exe`.

### 2. Inspect the Extracted File

```bash copy
binwalk -e evil.exe
```

`-e` extracts embedded sections and any payloads bundled inside the file (e.g. an appended archive or secondary binary). Hand the result to [../Malware-Analysis/Static-Analysis.md](../Malware-Analysis/Static-Analysis.md) for further triage.

### 3. Extract Credentials from an LSASS Dump

If an `lsass.dmp` (or similar minidump) was recovered from the traffic:

```bash copy
pypykatz lsa minidump dump.dmp -d -o hash.txt -g
```

- `-d` — dump all available credential material
- `-o hash.txt` — write extracted hashes in John/Hashcat format
- `-g` — generate a potfile for cracking

### 4. Crack Recovered Hashes

```bash copy
john --wordlist=rockyou.txt hash.txt > pass.txt
```

Or with hashcat:

```bash copy
hashcat -m <hash-mode> hash.txt rockyou.txt
```
