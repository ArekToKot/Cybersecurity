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


# OS Info

## Imageinfo Plugin
    OS version and build number
    OS architecture (32-bit or 64-bit)
    OS service pack level


vol -f /home/analyst/memdump.mem imageinfo

1. Suggested Profiles
2. Image date and time
## kdbgscan Plugin

vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 kdbgscan
1. Pick one of the suggested Windows 10 profiles and use it with the kdbgscan plugin.
2. Note down the address/offset of 'KdCopyDataBlock'

vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 pslist

# Windows Processes
## Processes list: PSLIST
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 pslist

    Offset (V): the process address in memory.
    Name: the name of the process.
    PID: process ID.
    PPID: parent process ID.
    Thds: number of threads this process started.
    Hnds: Processes use handles to interact with objects such as files, registry keys, and other processes. By analyzing the number and type of handles open by a process, a forensic investigator can gain insight into the resources that a process accessed.
    Sess: when a user logs onto a Windows system, a new session is created for that user. 
    Wow64: indicates whether a process is running as a 32-bit process on a 64-bit operating system.
    Start: process start time used to determine the timeline of events and help reconstruct activities performed on the system.
    Exit: process termination time.

## Parent-child relationship: PSTREE
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 pstree
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 pstree -v
The verbose mode of PSTREE (-v) lists detailed information about the running process, such as:
    Audit: shows the full path to the application on disk. An application running from an unusual location should be considered suspicious. 
    Cmd: shows the command line used to start the process. Look for processes with suspicious command lines.
    Path: like the audit field, it shows the full path to the application on disk.

## Hidden Processes - PSXVIEW
PSXVIEW utilizes list walking and brute-forcing techniques to list discovered processes across seven different views: pslist, psscan, thrdproc, pspcid, csrss, session, and deskthrd. 
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 psxview
Let's have a look at how to use PSXVIEW in a typical investigation:
    The first step is to check the entries in the pslist column. All PSLIST hidden processes (i.e., FALSE) are good candidates for further investigation. However, not every PSLIST hidden process should be assumed malicious. Some legit situations may result in a process not being detected using some methods (e.g., terminated processes). 
    Looking at the rest of the methods, you can see that the 'CCDrootkit.exe' process is hidden in all views except csrss and session.
    The next step is to record the address of the suspicious process (CCDrootkit.exe) identified in previous steps (0x0000000030584080). This is for further examination using PSINFO, which we will discuss later.

## PSINFO Plugin
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 psinfo -o 0x0000000030584080

    The first step is to run PSINFO against the 'CCDrootkit' process offset/address you have from PSXVIEW.
    Process Information: as you can see, we have many helpful process details in one place, such as PID, parent process, creation time, and Command-Line.
    VAD and PEB comparison: This part retrieves process details from two locations, VAD (Virtual Address Descriptor) and PEB (Process Environment Block), to check for anomalies.
    VAD (Virtual Address Descriptor) and PEB (Process Environment Block) are data structures used in the memory management of Windows operating systems. VADs track the memory allocated to a process, while PEBs contain information about the process, such as its loaded modules, command line arguments, environment variables, and more. While VADs and PEBs are related, they serve different purposes in memory management and contain different types of information.
    Similar Processes: other discovered processes with the same name.
    Suspicious Memory Regions: This part lists memory regions that contain malicious code.

## Process privileges - GETSIDS plugin
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 getsids -o 0x0000000030584080
The GETSIDS Volatility plugin extracts and display the security identifiers (SIDs) of all user accounts that have started a process.

# Network connections
## Connections - netscan plugin
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 netscan


    Offset(P): contains the physical memory address where the network connection structure is stored in the memory dump.
    Proto: indicates the protocol type and IP version being used.
    Local address: the IP address and port number of the local system (the machine you're analyzing). You may encounter these formats:
        IP Address:Port (e.g., 192.168.1.100:8080) - The service is bound to a specific network interface with its IP address and listening on the specified port.
        0.0.0.0:Port - The service is listening on all available IPv4 interfaces.
        :::Port - The service is listening on all available IPv6 interfaces.
        ::1:Port - The service is using the IPv6 loopback address.

From a forensic perspective, services listening on 0.0.0.0 or :: represent potential attack surfaces since they're accessible from the network, while loopback addresses indicate local-only services.

    Foreign address: the remote IP address and port number of the connection endpoint (the system on the other end of the connection). For established connections, you'll see the actual remote IP and port. For UDP connections, this column typically shows *:* because UDP is connectionless.

    State: shows the current state of TCP connections:
        LISTENING - The service is waiting for incoming connection requests
        ESTABLISHED - An active connection is currently open and data can be transmitted
        CLOSE_WAIT - The remote side has closed the connection, waiting for the local application to close
        TIME_WAIT - Connection is closed but waiting to ensure all packets are received

    PID and Owner: the Process ID (PID) and the executable name of the process that owns this network connection.
    Created: the timestamp when the network connection was established


# Persistance
## Volatility printkey plugin
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 printkey -K software\microsoft\windows\currentversion\run


    1. Hive path
    2. Key name and type: "(S)" means that the key is a stable registry key permanently stored on the hard drive. If the key is marked as "(V)," it is a temporary/volatile registry key that exists only in memory.
    3. Last updated: the date and time when the key was last modified.
    4. Subkeys: contain a list of subkeys that exist under the inspected (parent) key, if any, along with their type, stable (S) or volatile (V).
    The "Values" section displays key content/values. It's broken down into: 
        5. Value name: usually the application name.
        6. Value data: the key content. Usually, an executable or a command line.
        7. Value type: Stable or volatile, similar to registry keys.
        8. Value data type
##  common persistence-related keys
Run Keys:

    SOFTWARE hive
        Microsoft\Windows\CurrentVersion\Run
        Microsoft\Windows\CurrentVersion\RunServices
    NTUSER.dat hive
        SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices

        Programs that launch automatically each time the user logs in.
         

RunOnce Keys:

    SOFTWARE hive
        Microsoft\Windows\CurrentVersion\RunOnce
        Microsoft\Windows\CurrentVersion\RunOnceEx\0001
        Microsoft\Windows\CurrentVersion\RunOnceEx\0001\Depend
        Microsoft\Windows\CurrentVersion\RunServicesOnce
    NTUSER.dat hive
        SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
        Software\Microsoft\Windows\CurrentVersion\RunServicesOnce

Services Keys: 

    SYSTEM hive
        CurrentControlSet\Services

Scheduled Tasks Keys: 

    SOFTWARE hive
        Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks 
        Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree

AppInit_DLLs Key: 

    SOFTWARE hive
        Microsoft\Windows NT\CurrentVersion\Windows\AppInit_DLLs

Winlogon Keys:

    SOFTWARE hive
        Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit
        Microsoft\Windows NT\CurrentVersion\Winlogon\Shell

## Volatility winesap plugin

Winesap is a third-party plugin that can help you automate inspecting persistence-related registry keys.
volatility -f <memory_dump> --profile=<profile> -g 0xf803788a44d8 winesap

vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 winesap


# Files
## Master File Table (MFT)

Here is a quick list of what you can do using the information you extract from the MFT file:
    Recover malicious scripts: Malicious scripts are often small enough to have their content fit in the max size of the MFT record (1024 bytes). 
    Build a timeline:  Any attack is a bunch of file activities (i.e., creating new files, accessing or deleting). 
    Code execution: the MFT has records for all files, including OS files like Prefetch.

## MFT parser plugin
vol -f /home/analyst/memdump.mem --profile=Win10x64_17134 -g 0xf8031ce954d8 mftparser


    $FILE_NAME ($FN): stores the name of the file or directory, along with additional metadata like timestamps (creation, modification, and access times), allocated size, and parent directory reference. This attribute assists in reconstructing the directory structure and analyzing file activities during investigations.
     
    $STANDARD_INFORMATION ($SI): contains essential metadata about a file or directory, such as file ownership, permissions, and more detailed timestamps (creation, modification, and access times).
     
    $DATA: responsible for storing the actual content of a file or directory in an NTFS file system. It can either store the data directly within the MFT entry (for small files ~600 bytes) as resident data or point to the data's location on the disk as non-resident data. This is useful in incident response as you can inspect the actual content of tiny suspicious files or scripts that an attacker may have used.


## investigation of MFT 

Here are some top locations where malicious files may reside on Windows:

    C:\Windows\Temp: This is a temporary folder where applications and programs store temporary files. Malware may use this folder to store and execute its malicious code.
    Downloads: As the name suggests, this folder stores downloaded files. Malware can easily trick users into downloading and executing malicious files from this folder.
    Program Files and Program Files (x86): contain files and programs installed on your system. Malware may install itself in these folders to hide among legitimate files.
    System32 and SysWOW64: contain important system files for the operating system to run. Malware may infect these files to gain control over the system.
    AppData: This folder contains application data and settings for each user. Malware may store and execute malicious code in this folder to evade detection.
    Startup: Malware may add itself to the Startup folder to execute automatically when the system starts up.
    Documents: This is another common location where users store important files. Malware may infect these files to spread to other systems or hold them for ransom.
## speed-up

vol -f .\memory.dmp imageinfo
vol -f .\memory.dmp --profile=Win10x64_17763 kdbgscan
vol -f .\memory.dmp --profile=Win10x64_17763 -g 0xf80132d32de8 pslist

$ python vol.py -f cve2011_0611.dmp --profile=WinXPSP3x86 evtlogs -v --save-evt -D output/
 python.exe .\evtxdumper.py --image .\Server.raw --profile Win10x64_17763 --kdbg 0xf80132d32de8 --outdir OUTDIR