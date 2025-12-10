
# KQL Threat Hunting Notes – Old Kibana Edition

## Endpoint Threat Hunting

### Detecting Encoded PowerShell Commands (Process Creation + Script Block Logging)

```kql
event.code: 4688 
and process.command_line: (*-enc* OR *-EncodedCommand* OR *-nop* OR *download* OR *IEX* OR *Invoke-Expression* OR *Invoke-Command*)
```

- Detects suspicious PowerShell flags in process creation events (Event ID 4688).
- `event.code: 4688` → A new process has been created (Process Creation).
- `process.command_line:` → Full command line of the executed process.
- `*-enc* OR *-EncodedCommand*` → Looks for Base64-encoded payloads.
- `*-nop` → No profile loading (common in attacks).
- `*download* OR *IEX* OR *Invoke-Expression*` → Typical download cradle keywords.

```kql
event.code: 4104 
AND message: (*downloadstring* OR *download* OR *Invoke-Expression* OR *IEX* OR *-exec* OR *-ExecutionPolicy* OR *-EncodedCommand* OR *-enc* OR *-nop*)
```

- Catches actual decoded PowerShell script blocks (thanks to Script Block Logging).
- `event.code: 4104` → Script Block Logging – records content of executed PowerShell blocks.
- `message:` → Contains the actual script content (deobfuscated!).
- All keywords inside → Direct indicators of malicious download/execution.

#### Relevant Windows Event IDs
| Event ID | Nazwa                          | Co daje w threat huntingu                          |
|----------|--------------------------------|----------------------------------------------------|
| 4688     | Process Creation               | Pokazuje pełny command line uruchomionego procesu |
| 4689     | Process Termination           | Pomaga w korelacji (kto i kiedy się zakończył)     |
| 4104     | Script Block Logging           | Najcenniejsze – pokazuje treść wykonanych bloków PS |

#### Common PowerShell Flags and Abbreviations Used in Attacks
| Skrót / Flaga                  | Pełna nazwa                        | Opis w ataku                                                                 |
|--------------------------------|------------------------------------|-------------------------------------------------------------------------------|
| `-EncodedCommand`, `-e`, `-enc`| --EncodedCommand                  | Wykonuje komendy zakodowane w Base64 – klasyczna obfuskacja                   |
| `-WindowStyle Hidden`, `-w hidden` | --WindowStyle Hidden           | Uruchamia PowerShell w ukrytym oknie                                          |
| `-ExecutionPolicy Bypass`, `-exec bypass` | --ExecutionPolicy Bypass | Omija politykę wykonywania skryptów                                      |
| `-NoProfile`, `-nop`           | --NoProfile                        | Nie ładuje profilu użytkownika (przyspiesza + mniej śladów)                  |
| `-NonInteractive`, `-noni`     | --NonInteractive                  | Tryb bez interakcji z użytkownikiem                                           |
| `Invoke-Expression`, `iex`, `IEX` | Invoke-Expression               | Wykonuje kod w pamięci – najczęściej używane w download cradles              |

#### Key PowerShell Keywords for Detecting Malicious Activity
| Słowo kluczowe         | Opis w ataku                                                                 |
|-------------------------|-------------------------------------------------------------------------------|
| `download` / `DownloadString` / `DownloadFile` | Pobieranie payloadu z internetu                              |
| `Start-Process`         | Uruchamianie kolejnych procesów (często drugiego stage’u)                    |
| `IEX` / `Invoke-Expression` | Wykonywanie kodu pobranego/dynamicznie wygenerowanego              |
| `WebClient`             | Tworzenie obiektu do pobierania plików                                        |
| `bitstransfer`          | Użycie BITS do cichego pobierania                                             |
| `Invoke-Command`        | Wykonywanie zdalne – często lateral movement                                  |
| `rundll32`              | Uruchamianie DLLi bez bezpośredniego exe                                      |
| `HTTP` / `HTTPS`        | Wskazuje komunikację na zewnątrz (C2, download cradle, exfil)                |




## Endpoint Threat Hunting – Persistence via Scheduled Tasks

### Detecting schtasks.exe Abuse (Sysmon EID 1 + WinEvent 4688)

```kql
event.code: 1 
AND process.name: "schtasks.exe"
```
- Hunts every execution of schtasks.exe via Sysmon Process Creation.
- `event.code: 1` → Sysmon Event ID 1 (Process Creation).
- `process.name: "schtasks.exe"` → Exact binary name (case-insensitive in old Kibana).

```kql
event.code: 4688 
AND process.name: "schtasks.exe"
```
- Same as above but from native Windows Process Creation logs.
- `event.code: 4688` → A new process has been created (Windows Security log).

```kql
event.code: 106
```
- Direct detection of task creation in Task Scheduler Operational log.
- `event.code: 106` → Scheduled task created (Microsoft-Windows-TaskScheduler/Operational).

```kql
event.code: 4698
```
- Security log version of task creation (requires auditing enabled).
- `event.code: 4698` → A scheduled task was created.

### Hunting for Known Malicious Scheduled Task Patterns

```kql
event.code: 1 
AND process.name: schtasks.exe 
AND process.command_line: (*/create* OR */delete* OR rundll32 OR regsvr32 OR powershell OR cmd)
```
- Catches the most common malicious schtasks patterns in one shot ♡
- `*/create*` → Task creation switches.
- `rundll32 OR regsvr32 OR powershell OR cmd` → Suspicious binaries in /TR parameter.

#### Relevant Event IDs – Scheduled Tasks
| Event ID | Log Source                                    | Co daje w threat huntingu                              |
|----------|-----------------------------------------------|--------------------------------------------------------|
| 106      | Microsoft-Windows-TaskScheduler/Operational   | Scheduled task created (najpewniejsze!)                |
| 140      | TaskScheduler Operational                     | Scheduled task updated                                 |
| 141      | TaskScheduler Operational                     | Scheduled task deleted                                 |
| 200      | TaskScheduler Operational                     | Scheduled task executed                                |
| 201      | TaskScheduler Operational                     | Scheduled task completed                               |
| 4698     | Security                                      | Scheduled task created (requires Object Access audit) |
| 4699     | Security                                      | Scheduled task deleted                                 |
| 4700     | Security                                      | Scheduled task enabled                                 |
| 4701     | Security                                      | Scheduled task disabled                                |
| 4702     | Security                                      | Scheduled task updated                                 |
| 1 / 4688 | Sysmon / Windows Security                     | Full command line with schtasks.exe usage              |

#### Classic Malicious Scheduled Task Examples (dla kontekstu ♡)

**PowerShell persistence (daily)**
```bash
schtasks.exe /create /sc daily /tn "MaliciousTask" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\payload.ps1" /st 06:00
```

**rundll32 persistence (on startup as SYSTEM)**
```bash
schtasks.exe /create /sc onstart /tn "MaliciousTask" /tr "rundll32.exe C:\Windows\Temp\Evil.dll,Evil" /ru SYSTEM
```



## Endpoint Threat Hunting – Credential Dumping

### Detect Suspicious Processes (mimikatz / procdump / reg save)

```kql
event.code: 4688 
AND process.command_line: (*mimikatz* OR *procdump* OR *reg.exe*)
```
- Catches classic credential dump tools via Windows Process Creation.
- `event.code: 4688` → Process Creation (Security log).
- `*mimikatz* OR *procdump* OR *reg.exe*` → Direct indicators of dumping activity.

```kql
event.code: 1 
AND process.command_line: (*mimikatz* OR *procdump* OR *reg.exe*)
```
- Same thing but via Sysmon (usually has better command line fidelity).
- `event.code: 1` → Sysmon Process Creation.

### Track Processes Accessing LSASS Memory (Sysmon Event ID 10)

```kql
event.code: 10 
AND winlog.event_data.TargetImage: *lsass.exe 
AND winlog.event_data.GrantedAccess: (0x1010 OR 0x1410 OR 0x1438 OR 0x143A OR 0x1418)
```
- Pure gold – catches LSASS memory access before the dump even happens.
- `event.code: 10` → Sysmon Process Access.
- `TargetImage: *lsass.exe*` → Only processes touching LSASS.
- `GrantedAccess` values → Typical rights requested by mimikatz/procdump (read VM + query info).

### Monitor File Creation for Memory Dumps (Sysmon Event ID 11)

```kql
event.code: 11 
AND process.name:(*procdump.exe* OR *rundll32.exe* OR *taskmgr.exe* OR *powershell.exe* OR *wmic.exe* OR *schtasks.exe* OR *cmd.exe* OR *comsvcs.dll*) 
AND file.name: (lsass.* OR *.dmp OR *.zip OR *.rar)
```
- Detects the moment the dump file hits disk.
- `event.code: 11` → Sysmon File Creation.
- Suspicious parent processes + classic dump extensions.

### Trace Credential Dumping Scripts in PowerShell Script Block Logging (Event ID 4104)

```kql
event.code: 4104 
AND winlog.event_data.ScriptBlockText: (*Invoke-Mimikatz* OR *procdump.exe - ma lsass* OR *rundll32.exe comsvcs.dll MiniDump* OR *taskmgr.exe /dump*)
```
- Catches reflective/in-memory mimikatz and native dump techniques.
- `event.code: 4104` → PowerShell Script Block Logging.
- Looks directly inside executed PS code for the most common one-liners.


## Endpoint Threat Hunting – Tracking Account Usage & Logon Sessions

### Common Logon-Related Event IDs
| Event ID | Opis                                      | Dlaczego ważne w huntingu                          |
|----------|-------------------------------------------|----------------------------------------------------|
| 4624     | Successful Logon                          | Kto i jak się zalogował                            |
| 4625     | Failed Logon                              | Brute force / spray attempts                       |
| 4672     | Privileged Logon (SeAssignPrimaryToken)  | Kto dostał uprawnienia typu SERVICE / ADMIN       |
| 4720     | User Account Created                      | Nowe konto – często backdoor                       |
| 4726     | User Account Deleted                      | Usuwanie śladów                                    |
| 4634     | Logoff / Session Ended                    | Koniec sesji – super do korelacji z 4624           |

### Logon Types – winlog.event_data.LogonType
| Logon Type | Nazwa                  | Opis w threat huntingu                                                    |
|------------|------------------------|---------------------------------------------------------------------------|
| 0          | System                 | Tylko konto SYSTEM (np. przy starcie)                                     |
| 2          | Interactive            | Fizyczne logowanie przy klawiaturze (najczęstsze na workstationach)      |
| 3          | Network                | Logowanie sieciowe (SMB, WinRM, PsExec) – klasyka lateral movement       |
| 4          | Batch                  | Zadania zaplanowane / batch jobs                                          |
| 5          | Service                | Start usługi                                                              |
| 7          | Unlock                 | Odblokowanie ekranu                                                       |
| 8          | NetworkCleartext      | Hasło w cleartext (rzadkie, ale mega czerwona flaga)                      |
| 9          | NewCredentials         | Klonowanie tokena z nowymi credentialami (pass-the-hash variant)          |
| 10         | RemoteInteractive      | RDP / Terminal Services – najczęściej atakowane                          |
| 11         | CachedInteractive      | Logowanie z cachem (bez DC) – przydatne przy braku łączności             |
| 12         | CachedRemoteInteractive | Jak 10, ale z cachem                                                    |
| 13         | CachedUnlock           | Odblokowanie z cachem                                                     |

### Track Full Logon Session (przykład: śledzenie konkretnej sesji na hoście sql)

```kql
event.code: ("4624" OR "4634") 
AND host.name: sql 
AND winlog.event_data.LogonType: 3 
AND winlog.event_data.TargetLogonId: 0x76b6e92
```
- Pokazuje początek i koniec konkretnej sesji logowania.
- `4624` → Start sesji.
- `4634` → Koniec sesji (logoff).
- `LogonType: 3` → Tylko network logons (najciekawsze w lateral movement).
- `TargetLogonId` → Unikalny identyfikator sesji – możesz go wyciągnąć z 4624 i śledzić dalej.




## Endpoint Threat Hunting – Lateral Movement (PsExec Edition ♡)

### PsExec EULA Registry Key (pierwszy ślad instalacji)

```kql
event.code: 13 
AND registry.key: *\\PsExec\\EulaAccepted*
```
- `event.code: 13` → Sysmon Registry Event (value set).
- `*\\PsExec\\EulaAccepted*` → PsExec zawsze tworzy ten klucz przy pierwszym uruchomieniu.

### Service Creation – PSEXESVC (klasyka)

```kql
event.code: 7045 
AND winlog.event_data.ServiceName: PSEXESVC
```

```kql
event.code: 13 
AND registry.key: *\\PSEXESVC
```
- `7045` → System – nowa usługa zainstalowana.
- `PSEXESVC` w rejestrze → dodatkowy ślad usługi.

### Type 3 Network Logon + Immediate PSEXESVC Creation (mega czerwona flaga!)

```kql
event.code: (4624 OR 7045) 
AND winlog.event_data.LogonType: 3 
AND winlog.event_data.ServiceName: PSEXESVC
```
- Korelacja w czasie: najpierw network logon (LogonType 3), zaraz potem usługa PSEXESVC → prawie 100% PsExec.

### Process Execution – PsExec.exe & PSEXESVC.exe

```kql
event.code: 1 
AND process.name: PsExec*
```

```kql
event.code: 4688 
AND process.name: PsExec*
```

```kql
process.name: PSEXESVC.exe
```
- Bezpośrednie wykonanie PsExec.exe lub usługi PSEXESVC.exe.

### Named Pipes Created by PsExec (Sysmon Event ID 18)

```kql
event.code: 18 
AND file.name: \\PSEXESVC*
```
- `event.code: 18` → Sysmon Named Pipe Created.
- Przykładowe nazwy:  
  `\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stdin`  
  `\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stdout`  
  `\\192.168.1.100\pipe\PSEXESVC-DESKTOP-KOAA32A-6780-stderr`


## Walkthrough – Lab 1 Detection Commands (gotowce do kopiuj-wklej ♡)


### 1. Scheduled Tasks Abuse (schtasks.exe execution)
```kql
process.name: "schtasks.exe"
```
- Łapie każde uruchomienie schtasks.exe (Sysmon EID 1 lub Windows 4688).

### 2. PsExec Execution (64-bit + 32-bit)
```kql
process.name: PsExec64.exe OR process.name: PsExec.exe
```
- Bezpośrednie wykrycie pliku PsExec (najczęściej wrzucanego ręcznie przez atakującego).

### 3. LSASS Memory Access (Sysmon Event ID 10 – klasyczny credential dumping)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" 
AND event.code: "10" 
AND winlog.event_data.TargetImage: *lsass.exe*
```
- Najlepszy wczesny wskaźnik mimikatz/procdump.
- `event.code: 10` → Process accessed another process.
- `TargetImage: *lsass.exe*` → Tylko dostęp do LSASS (można później filtrować po GrantedAccess jeśli chcesz).


## Walkthrough – Lab 2 Moje cute querki z labu ʚ♡ɞ

### 1. Procesy uruchamiane z folderu Downloads (podejrzane pobieranie i exec)
```kql
@timestamp >= "2022-11-08T00:00:00Z" AND @timestamp <= "2022-11-08T23:59:59Z" AND winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 1 AND process.executable: *Downloads*
```
- Łapie wszystko co się odpala prosto z folderu Downloads w ciągu całego dnia 08.11.2022 (klasyczny user-behavior po kliknięciu w złośliwy plik).

### 2. Tworzenie pliku moviedownloader.exe (dropper/malware)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational" AND event.code: 11 AND file.path: *moviedownloader.exe*
```
- Sysmon EID 11 = FileCreate → ktoś właśnie upuścił na dysk plik o nazwie moviedownloader.exe (super podejrzana nazwa :3).

### 3. Modyfikacja kluczy Run/RunOnce przez użytkownika cmurfy (persistence)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"  AND event.code: 13 AND registry.key: *Run* AND related.user: "cmurfy"
```
- EID 13 = Registry value set → użytkownik cmurfy właśnie dodał coś do autostartu (klasyczna technika persistence).

### 4. Uruchomienie dowolnego pliku .bat (batch skrypt = często złośliwy)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"  AND event.code: 1 AND process.command_line : *.bat*
```
- Łapie każdy proces którego command line zawiera .bat → bardzo częste przy atakach lolbin/living-off-the-land.

### 5. Proces o konkretnym PID 7932 (śledzenie konkretnego procesu)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"  AND event.code: 1 AND process.pid: 7932 
```
- Szukamy dokładnie procesu o PID 7932 (przydatne kiedy już wiemy który proces jest zły).

### 6. PowerShell uruchomiony z PID 6024 (podejrzany PowerShell)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"  AND event.code: 1 AND process.pid: 6024 AND process.executable: *powershell.exe
```
- Konkretna instancja PowerShella o PID 6024 → idealnie do pivotowania po znanym złym PID.

### 7. Nowa usługa systemowa (Service Installed) na hoście DC-01
```kql
winlog.event_id : 7045 AND agent.name: "DC-01"
```
- Windows Event ID 7045 = nowa usługa została zainstalowana, a host to DC-01 (często wykorzystywane do persistence przez atakujących).

### 8. Wykonanie PsExec (ten sam co wcześniej, ale trochę inna składnia ♡)
```kql
winlog.channel: "Microsoft-Windows-Sysmon/Operational"  AND event.code: 1  AND process.executable: (*PsExec.exe OR *PsExec64.exe)
```
- Łapie uruchomienie PsExec/PsExec64 (lateral movement klasyk~).


## Network Threat Hunting

### Lab 1

```kql
agent.type: "packetbeat" AND type: dns AND NOT dns.response_code: "NOERROR"
```
> Szuka zapytań DNS, które zwróciły błąd inny niż NOERROR (np. REFUSED, SERVFAIL)

```kql
agent.type: "packetbeat" AND type: dns AND dns.response_code: "NXDOMAIN"
```
> Szuka zapytań DNS, które zwróciły NXDOMAIN (domena nie istnieje)

### Lab 2

```kql
agent.type : "packetbeat" and type:"dns"  
```
> Podstawowe filtrowanie wszystkich zapytań DNS z Packetbeat (bez dodatkowego warunku)

```kql
winlog.channel : "Microsoft-Windows-Sysmon/Operational" AND dns.question.registered_domain : "downloadmoviesonline.shop" AND event.code : "22"
```
> Sysmon event 22 (DNS query) zawierający zarejestrowaną domenę downloadmoviesonline.shop

```kql
winlog.channel : "Microsoft-Windows-Sysmon/Operational" AND dns.question.name: "downloadmoviesonline.shop" AND event.code : "22"
```
> Sysmon event 22 z dokładnym zapytaniem o downloadmoviesonline.shop

```kql
winlog.channel : "Microsoft-Windows-Sysmon/Operational" AND event.code : "3" and destination.ip: "3.210.135.57"
```
> Sysmon event 3 (Network connection) do konkretnego IP 3.210.135.57

```kql
winlog.channel : "Microsoft-Windows-Sysmon/Operational" AND event.code : "1" and process.name: powershell.exe
```
> Sysmon event 1 (Process creation) gdzie proces to powershell.exe

```kql
event.category: "network" AND event.module : "endpoint" AND destination.port : 8000 AND network.protocol : ("http" OR "https")
```
> Połączenia sieciowe na port 8000 po HTTP lub HTTPS z modułu endpoint

```kql
@timestamp>= "2022-11-13T12:45:40Z" AND @timestamp<= "2022-11-13T23:59:59Z" AND winlog.event_id: 7045 AND agent.name :"DC-01"
```
> Nowe usługi (event 7045) utworzone na hoście DC-01 w konkretnym przedziale czasowym

```kql
winlog.event_id: 4624 AND agent.name :"DC-01"
```
> Logowania (event 4624) na serwerze DC-01