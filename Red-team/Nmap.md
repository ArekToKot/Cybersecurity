# Nmap Commands
Commands typically used in CTF environments, not applicable in production environments

## CTF Scanning
```bash copy
nmap -A --script vuln -p- -T4 10.10.10.10
```
- `-A`: All scans (OS, version, scripts, traceroute)
- `--script vuln`: Runs vulnerability detection scripts
- `-p-`: Scans all 65,535 ports
- `-T4`: Fast timing template (0-5, 4 is aggressive but reliable)

**Note**: Saves time in CTF, finds all attack vectors.

## Detailed Scan (faster than CTF Scanning)
```bash copy
nmap -O -sV -sC -T4 10.10.10.10
```
- `-O`: Detects OS and hardware
- `-sV`: Probes for service/version info
- `-sC`: Runs default Nmap scripts (equivalent to --script=default)
- `-T4`: Fast timing template (0-5, 4 is aggressive but reliable)

**Note**: Quick, detailed scan of target for CTF/recon.

## Targeted Port Scan
```bash copy
sudo nmap -Pn --script vuln -p 80,135,139,445,3389 10.10.10.10
```
- `-Pn`: Skips host discovery (assumes target is up)
- `--script vuln`: Runs vulnerability scripts
- `-p 80,135,139,445,3389`: Scans specific ports (HTTP, RPC, SMB, RDP)
- `sudo`: Required for some scripts/probes

**Note**: Focused scan for common vulnerable ports.

