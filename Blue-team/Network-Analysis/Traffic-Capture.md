# Traffic Capture — SPAN/Port Mirroring and tcpdump

Reference for getting a copy of network traffic onto an analysis host when there's no agent on the endpoint: mirror a switch port (SPAN) or tap a router interface, then capture with tcpdump. Once you have a PCAP, see [Wireshark.md](Wireshark.md) for packet-level analysis, or [NetFlow.md](NetFlow.md) for a lower-overhead, flow-based alternative when full packet capture isn't feasible.

## Tools

| Tool | Platform | Link |
|---|---|---|
| tcpdump | Linux / Windows (WSL) | [tcpdump.org](https://www.tcpdump.org/) |

---

## Port Mirroring (SPAN) on a Switch

Port mirroring (SPAN) duplicates traffic from one or more source ports/VLANs to a destination ("monitoring") port, where a capture host can see it without sitting inline on the link.

### Example: Cisco IOS

```
! Mirror both directions of GigabitEthernet0/1 to GigabitEthernet0/2
monitor session 1 source interface GigabitEthernet0/1 both
monitor session 1 destination interface GigabitEthernet0/2

! Mirror an entire VLAN instead of a single port
monitor session 1 source vlan 10
monitor session 1 destination interface GigabitEthernet0/2
```

### Configuration Steps

1. Access the switch CLI (console, SSH, or Telnet).
2. Enter global configuration mode and define the SPAN session as shown above.
3. Save the configuration:

```
end
write memory
```

4. Connect a capture host (running tcpdump or Wireshark) to the destination port.

---

## Capturing with tcpdump

```bash copy
# Capture everything on eth0 to a file
sudo tcpdump -i eth0 -w capture_file.pcap

# Capture only HTTP traffic (port 80)
sudo tcpdump -i eth0 port 80 -w capture_file.pcap
```

Press `Ctrl+C` to stop the capture once enough data has been collected, then open `capture_file.pcap` in [Wireshark.md](Wireshark.md) for analysis.
