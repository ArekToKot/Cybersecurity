# Sysmon events id table
ID | Tag | Event
---|---|---
1|ProcessCreate|Process Create
2|FileCreateTime|File creation time
3|NetworkConnect|Network connection detected
4|n/a|Sysmon service state change (cannot be filtered)
5|ProcessTerminate|Process terminated
6|DriverLoad|Driver Loaded
7|ImageLoad|Image loaded
8|CreateRemoteThread|CreateRemoteThread detected
9|RawAccessRead|RawAccessRead detected
10|ProcessAccess|Process accessed
11|FileCreate|File created
12|RegistryEvent|Registry object added or deleted
13|RegistryEvent|Registry value set
14|RegistryEvent|Registry object renamed
15|FileCreateStreamHash|File stream created
16|n/a|Sysmon configuration change (cannot be filtered)
17|PipeEvent|Named pipe created
18|PipeEvent|Named pipe connected
19|WmiEvent|WMI filter
20|WmiEvent|WMI consumer
21|WmiEvent|WMI consumer filter
22|DNSQuery|DNS query
23|FileDelete|File Delete archived
24|ClipboardChange|New content in the clipboard
25|ProcessTampering|Process image change
26|FileDeleteDetected|File Delete logged
27|FileBlockExecutable|File Block Executable
28|FileBlockShredding|File Block Shredding
29|FileExecutableDetected|File Executable Detected
255|Error|Error