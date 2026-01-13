# Volatility Brief

## Memory files source
1. Hibernation file (hiberfil.sys)
2. Paging file (pagefile.sys)
3. CrashDumps „C:\Windows\MEMORY.DMP”

## Volatility Commands
`vol -f /home/analyst/memdump.mem imageinfo`
- `vol` Volatility app
- `-f` File argument
- `memdump.mem` Memory dump path
- `imageinfo` Memory dump info module

Volatility modules

Module name | About
---|---
Windows.cmdline|Lists process command line arguments
windows.drivermodule|Determines if any loaded drivers were hidden by a rootkit
Windows.filescan|Scans for file objects present in a particular Windows memory image
Windows.getsids|Print the SIDs owning each process
Windows.handles|Lists process open handles
Windows.info|Show OS & kernel details of the memory sample being analyzed
Windows.netscan|Scans for network objects present in a particular Windows memory image
Widnows.netstat|Traverses network tracking structures present in a particular Windows memory image.
Windows.mftscan|Scans for Alternate Data Stream
Windows.pslist|Lists the processes present in a particular Windows memory image
Windows.pstre|List processes in a tree based on their parent process ID

## File and MFT Analysis
```bash copy
vol -f memdump.mem windows.filescan > filescan_out
cat filescan_out | grep updater
```
- Dumps file objects to file, filters for "updater"

```bash copy
vol -f memdump.mem windows.mftscan.MFTScan > mftscan_out
cat mftscan_out | grep updater
```
- Dumps MFT scan to file, filters for "updater"

## Process Memory Dump
```bash copy
vol -f memdump.mem -o . windows.memmap --dump --pid 1612
```
- Dumps memory map for PID 1612 to current directory

```bash copy
strings pid.1612.dmp | less
```
- Extracts strings from PID 1612 dump, views in pager

```bash copy
strings pid.1612.dmp | grep -B 10 -A 10 "http://key.critical-update.com/encKEY.txt"
```
- Extracts strings, shows 10 lines before/after URL match


## speed-up

vol -f .\memory.dmp imageinfo
vol -f .\memory.dmp --profile=Win10x64_17763 kdbgscan
vol -f .\memory.dmp --profile=Win10x64_17763 -g 0xf80132d32de8 pslist

$ python vol.py -f cve2011_0611.dmp --profile=WinXPSP3x86 evtlogs -v --save-evt -D output/
 python.exe .\evtxdumper.py --image .\Server.raw --profile Win10x64_17763 --kdbg 0xf80132d32de8 --outdir OUTDIR