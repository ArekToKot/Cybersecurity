How to Capture Traffic from Switches and Routers
1. PCAPs (Packet Captures) from Switches using SPAN/Port Mirroring

Port mirroring (SPAN) duplicates traffic from specified ports or VLANs to a monitoring port. Tools like Wireshark or tcpdump analyze this traffic.

Example SPAN Configuration for a Cisco Switch:
```
# To mirror traffic from a specific port (e.g., GigabitEthernet 0/1) to a monitoring port (e.g., GigabitEthernet 0/2):
monitor session 1 source interface GigabitEthernet0/1 both
monitor session 1 destination interface GigabitEthernet0/2

# To monitor a VLAN (e.g., VLAN 10) instead of a port:
monitor session 1 source vlan 10
monitor session 1 destination interface GigabitEthernet0/2
```
Configuration Steps:

1. Access the switch CLI (via console, SSH, or Telnet).

2. Enter Global Configuration Mode and define a SPAN session to monitor traffic from desired sources (as shown in the configuration above).

3. Exit configuration mode and save the configuration:
```
end 
write memory
```
4. Connect a device running packet capture software to the monitoring port.

Traffic Capture Command Using tcpdump:
```
sudo tcpdump -i eth0 -w capture_file.pcap

# To filter traffic, e.g., only HTTP traffic:
sudo tcpdump -i eth0 port 80 -w capture_file.pcap
```
5. PressCtrl+Cin the terminal to stop the capture when you have enough data.

6. Use tools like Wireshark to open and analyze the.pcapfile created by tcpdump.
2. NetFlow (or IPFIX) from Routers:

NetFlow collects metadata about data flows for detailed traffic pattern analysis.

Example Configuration for a Cisco Router:
```
# Define the NetFlow exporter:
ip flow-export destination 192.168.1.100 2055
ip flow-export version 9
ip flow-export source GigabitEthernet0/1

# Enable NetFlow on specific interfaces:
interface GigabitEthernet0/1
ip flow ingress
ip flow egress

# Set flow timeout settings (optional):
ip flow-cache timeout active 60
ip flow-cache timeout inactive 15
```
Setup a NetFlow Collector: Use tools like ntopng, Elastiflow, or SolarWinds to aggregate and analyze flows. Ensure the collector's NetFlow version matches the router's configuration (v5, v9, or IPFIX).