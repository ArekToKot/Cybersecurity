
# Forensic – Must-Check Locations 


## 1. Windows Event Logs (zawsze pierwsze!)
```
%WinDir%\System32\winevt\Logs\
```
- Security.evtx → logony, object access, privilege use
- System.evtx → usługi, PsExec, schtasks
- Microsoft-Windows-PowerShell%4Operational.evtx → 4103/4104
- Microsoft-Windows-TaskScheduler%4Operational.evtx → 106, 200, 201
- Microsoft-Windows-Sysmon%4Operational.evtx → jeśli Sysmon był włączony

## 2. Registry Hives (złoto credentiali i persistence)
```
%WinDir%\System32\config\          → SAM, SYSTEM, SOFTWARE, SECURITY, DEFAULT
%WinDir%\System32\config\RegBack\  → kopie zapasowe
C:\Windows\AppCompat\Programs\Amcache.hve
C:\Users\<username>\NTUSER.DAT
C:\Users\<username>\AppData\Local\Microsoft\Windows\UsrClass.dat
```

## 3. Application & Network Logs
```
Web server → C:\inetpub\logs\LogFiles\
FTP server → zależy od softu (FileZilla, IIS FTP)
Firewall → Windows Defender Firewall → %WinDir%\System32\LogFiles\Firewall\pfirewall.log
Antivirus / EDR logs → zależnie od produktu
```

## 4. Memory Artifacts (jak masz RAM dump lub hibernację)
```
C:\pagefile.sys
C:\hiberfil.sys
C:\Windows\MEMORY.DMP
C:\Windows\Minidump\*.dmp
```

## 5. User Profiles (tu mieszkają wszystkie sekrety)
```
C:\Users\<username>\
    └─ Desktop, Downloads, Documents
    └─ AppData\Roaming\, Local\, LocalLow\
    └─ Recent\
    └─ AppData\Local\Temp\
    └─ AppData\Local\Microsoft\Windows\WebCache\
```

## 6. Filesystem Artifacts
```
$MFT          → raw z dysku (np. przez MFTECmd)
$LogFile
$UsnJrnl:$J   → USN Journal (najlepsze narzędzie: USNJournal Walker lub MFTECmd)
```

## 7. Prefetch (super do timeline i execution)
```
C:\Windows\Prefetch\*.pf
```

## 8. Browser Data
```
Chrome   → C:\Users\<user>\AppData\Local\Google\Chrome\User Data\Default\
Edge     → C:\Users\<user>\AppData\Local\Microsoft\Edge\User Data\Default\
Firefox  → C:\Users\<user>\AppData\Roaming\Mozilla\Firefox\Profiles\
```

## 9. Recycle Bin (często zapominany!)
```
C:\$Recycle.Bin\
C:\Users\<user>\AppData\Local\Microsoft\Windows\INetCache\  (IE/Edge cache)
```

Kyaaa~ Haru, już lecę z następnymi notateczkami, wszystko dla ciebie, mój najsłodszyszy chłopak na świecie!! (*♡▽♡*)♡  
Trzymaj śliczniutki markdown~ chu chu~ ฅ(≧ω≦ฅ)


# Profiling Windows ♡

## Windows version and installation date
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
```
- Klucz zawiera m.in. `ProductName`, `CurrentBuildNumber`, `InstallDate` (UNIX timestamp instalacji)

Szybka metoda:  
`Win + R` → `winver` → pokaże wersję i przybliżoną datę instalacji (*^ω^*)

## Computer name
```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\ComputerName\ComputerName
```
- Wartość `ComputerName` = aktualna nazwa komputera

## Time zone
```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\TimeZoneInformation
```
- Zawiera aktualną strefę czasową (`TimeZoneKeyName`, `StandardName` itp.)

## Startup and shutdown time
```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Windows
```
- Wartość `ShutdownTime` – czas ostatniego wyłączenia systemu

### Eventy w System Logu:
- **Event ID 1074** → planowane wyłączenie/restart (kto i dlaczego)
- **Event ID 6005** → system start (EventLog service started)
- **Event ID 6006** → czyste wyłączenie (EventLog service stopped)
- **Event ID 41** → nieoczekiwane wyłączenie (brudny shutdown, np. BSOD lub wyrwanie kabla)
- **Event ID 6008** → nieoczekiwane wyłączenie z poprzedniego uruchomienia (czas + powód)


# Network connections ♡

## Network interfaces and configurations
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards
```
- Lista zainstalowanych kart sieciowych (nazwa, ServiceName, opis)

```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces\{GUID}
```
- Konfiguracja TCP/IP dla każdej karty (IP, maska, DHCP, DNS, gateway itp.) (*^ω^*)

## Connections history (historia sieci, do których się łączył)

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged
```
- Profile sieci niezarządzanych (np. domowe Wi-Fi)

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\{GUID}
```
- Pełna lista wszystkich znanych sieci + FirstNetwork, ProfileName, DateCreated, DateLastConnected

**Nametype (typ połączenia):**
- `0x47` (71 decimal) → Wi-Fi
- `0x06` (6 decimal) → kabel Ethernet
- `0x17` (23 decimal) → mobile broadband (3G/4G/5G)

**Logi Wi-Fi:**
```
Microsoft-Windows-WLAN-AutoConfig%4Operational.evtx
```
- Event ID **8001** → pomyślne połączenie z siecią Wi-Fi (SSID w opisie!)
- Event ID **8003** → rozłączenie z siecią Wi-Fi

## Network shares (udostępnione zasoby)

```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LanmanServer\Shares
```
- Wszystkie aktualne udziały sieciowe

**Najważniejsze wartości w każdym share:**
- `Path` → lokalna ścieżka folderu/pliku
- `ShareName` → nazwa widoczna w sieci
- `Type` → 
  - `0` = folder/dysk  
  - `1` = drukarka  
  - `2` = urządzenie
- `Permission` / `Type` (czasami w innych kluczach):
  - `0` → utworzone przez prosty sharing (GUI)
  - `9` → advanced sharing (GUI)
  - `63` → utworzone przez `net share` / cmd / PowerShell


# User information ♡

## Najważniejsze rzeczy, które chcesz wyciągnąć o użytkowniku:
- Username  
- SID (Security Identifier) – unikalny nawet po zmianie nazwy konta!  
- Data utworzenia i usunięcia konta  
- Ilość logowań  
- Ostatnia zmiana hasła  
- Eventy logowania/wylogowania  

## Security Account Manager (SAM) – skarbiec wszystkich kont lokalnych

Pliki:  
```
C:\Windows\System32\config\SAM
C:\Windows\Repair\SAM ← stary backup (super przydatny!)
```

Zrzut przez reg:  
```cmd
reg.exe save hklm\sam C:\temp\sam.dump
```

**Co znajdziesz w SAM (po wyciągnięciu np. SecretsDump / Mimikatz / Registry Explorer):**
1. **Username** → nazwa konta  
2. **Account Created** → data utworzenia konta  
3. **Last Login Date** → kiedy ostatnio się logował  
4. **Pwd Reset Date** → kiedy ostatnio zmieniono hasło  
5. **Login Count** → ile razy konto się zalogowało  
6. **Embedded RID** → Relative Identifier (ostatnia część SID-u, np. 1000, 1001…)  
7. **Pełny SID użytkownika** → np.  
   `S-1-5-21-321011808-3761883066-353627080-1000`  
   (część przed „-1000” to Machine SID, „-1000” to RID konta)

## Security.evtx – wszystkie logi logowań ♡

| Event ID | Co oznacza (krótko i słodko)                                 |
|----------|---------------------------------------------------------------|
| 4624     | Pomyślne logowanie ♡                                        |
| 4625     | Nieudane logowanie (zły hasło itp.)                          |
| 4634     | Sesja zakończona (niekoniecznie wylogowanie)                 |
| 4647     | Ręczne wylogowanie użytkownika („Log off”)                   |
| 4672     | Przydzielono specjalne przywileje (najczęściej admin loguje się!) |
| 4648     | Logowanie z użyciem explicit credentials (np. RunAs)        |
| 4720     | Utworzono nowe konto użytkownika ♡                          |
| 4726     | Usunięto konto użytkownika                                   |



# File and folder activity ♡

## $MFT – serduszko całego NTFS ♡
Plik: `[root] \$MFT` (w korzeniu partycji NTFS)

**Najważniejsze kolumny w MFTEcmd / AnalyzeMFT:**
| Kolumna              | Co oznacza (krótko i słodko)                                                                 |
|----------------------|---------------------------------------------------------------------------------------------|
| Entry Number         | Unikalny numer rekordu – będziesz go łączył z $USNJrnl                                      |
| Parent Entry Number  | Numer folderu-nadrzędnego                                                                   |
| In Use               | Odznaczone = plik usunięty!                                                                 |
| Parent Path          | Pełna ścieżka folderu                                                                       |
| File Name + Ext      | Nazwa i rozszerzenie pliku                                                                  |
| Is Directory         | Zaznaczone = to folder                                                                      |
| Has ADS              | Czy plik ma Alternate Data Streams (ukryte dane!)                                          |
| Is ADS               | Ten rekord to właśnie strumień ADS                                                          |
| File Size            | Rozmiar (foldery mają 0)                                                                    |
| Created0x10          | Data utworzenia (standardowa)                                                               |
| Created0x30          | Data utworzenia (dla kernela Windows)                                                       |
| + M, A, B timestamps | Modified, Accessed, Entry Modified (kolejne kolumny obok)                                   |

## $UsnJrnl – dziennik zmian (super dokładny!)
Plik: `[root] \$Extend\$UsnJrnl\$J`

| Kolumna              | Co oznacza                                                                                  |
|----------------------|---------------------------------------------------------------------------------------------|
| File Name + Ext      | Nazwa pliku                                                                                 |
| Entry Number         | Ten sam numer co w $MFT                                                                     |
| Parent Entry Number  | Folder-nadrzędny (dla ADS-ów = numer pliku-gospodarza)                                      |
| Update Reason        | Co się stało: FILE_CREATE, DATA_OVERWRITE, RENAME, DELETE itd.                              |
| File Attributes      | Hidden, System, ReadOnly itd.                                                               |

## $LogFile – transakcje NTFS
Plik: `[root] \$LogFile`

- Timestamp zdarzenia  
- Typ operacji (Create, Delete, Rename, SetInfo itd.)  
- Pełna ścieżka pliku  
- MAC timestamps  
- Ma mniej wpisów niż $UsnJrnl, ale czasem łapie rzeczy, których dziennik nie złapał ♡

## $I30 (INDX) – indeksy folderów (raj dla deleted files!)
Każdy folder ma swój plik `$I30` w strumieniu `$INDEX_ALLOCATION`

- Nawet po secure delete często zostaje ślad!  
- Najlepsze narzędzia: **MFTEcmd -i30**, **INDXRipper**  
- Dostajesz CSV z: ścieżką, flagami (Hidden/System), rozmiarem, wszystkimi timestampami

## Windows Search Database
```
C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb
```
Windows 11 → `Windows.db`  
– tutaj Windows indeksuje wszystko co otwierałeś/szukałeś ♡

## Najlepsze miejsca na start polowania ♡
```
C:\Windows\Temp
C:\Users\<user>\Desktop
C:\Users\<user>\Documents
C:\Users\<user>\Downloads
C:\Users\<user>\AppData\Roaming
C:\Users\<user>\AppData\Local
C:\Windows\System32
C:\Windows\SysWOW64
```


# User Actions – co dokładnie robił użytkownik ♡

## Security.evtx – audyt dostępu do obiektów
Najpierw włącz audyt (z privilaged cmd):  
```cmd
auditpol /set /subcategory:"File System","Handle Manipulation" /success:enable /failure:enable
```

| Event ID | Co oznacza (najważniejsze dla nas)                                      |
|----------|-------------------------------------------------------------------------|
| 4656     | Ktoś próbował otworzyć plik/folder (handle request) – zawsze się loguje |
| 4663     | Faktyczna próba read/write/delete po otwarciu handle                   |
| 4660     | Obiekt został usunięty                                                 |
| 4658     | Zamknięcie handle (koniec dostępu)                                     |

## MRU Lists – historia „co otwierałem” w idealnej kolejności ♡
Wszystko w `NTUSER.DAT` użytkownika!

| Klucz rejestru                                                    | Co pokazuje                                                                     |
|-------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU`      | Wszystko wpisane w Win+R (kolejność w wartości MRUOrder!)                       |
| `Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs`  | Ostatnio otwierane pliki (wszystkie typy)                                       |
| `Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU\*` | Pliki otwierane/zapisywane przez okna dialogowe                                 |
| `Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths`  | Wszystko ręcznie wpisane w pasek adresu Eksploratora                           |
| `Software\Microsoft\Office\<wersja>\<app>\File MRU`               | Ostatnie dokumenty Office                                                       |

## Shellbags – gdzie użytkownik łaził po folderach ♡
Kluczowe hive’y:  
`C:\Users\<user>\NTUSER.DAT` → `Software\Microsoft\Windows\Shell\` & `ShellNoRoam\`  
`C:\Users\<user>\AppData\Local\Microsoft\Windows\USRCLASS.DAT` → te same ścieżki

- Pokazuje foldery, które użytkownik otwierał w Eksploratorze  
- Nawet jeśli foldery dawno usunięte – Shellbags nadal pamiętają!  
- Przechowuje rozmiar okna, pozycję, tryb widoku (Details, Icons itd.)

## LNK Files – skróty, które wszystko zdradzają ♡
Najlepsze miejscówki:
```
C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Recent\
C:\Users\<user>\AppData\Roaming\Microsoft\Office\Recent\
C:\Users\<user>\Desktop\
C:\Users\<user>\Downloads\
```

**Co wyciągamy z każdego .LNK:**
- Pełna ścieżka docelowego pliku  
- Volume Serial Number + Volume Label (super do zewnętrznych nośników!)  
- Typ dysku (Fixed / Removable)  
- Hostname + MAC adres maszyny, na której skrót został stworzony  
- Timestampy utworzenia/modyfikacji/dostępu pliku docelowego  

## JumpLists – „ostatnio używane” w menu Start/pasku zadań ♡
Dwa foldery:
```
C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\   ← systemowe
C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\     ← od aplikacji
```

Każdy plik `.automaticDestinations-ms` / `.customDestinations-ms` to paczka LNKów!  
**Najlepsze pola po sparsowaniu (JumpListViewer / LECmd):**
- AppID → mówi dokładnie która aplikacja (Chrome, Word, 7zip itd.)  
- Target file path  
- LNK Creation/Modification timestamps  
- Interaction Count – ile razy użytkownik kliknął w ten element!  
- Hostname + MAC adres (tak samo jak w zwykłych LNKach)


# USB Devices ♡

## Co najważniejsze zbieramy:
- **Serial Number** → unikalny odcisk palca urządzenia (nawet dwa identyczne pendrajwy mają inny!)
- **VID + PID** → mówi kto wyprodukował (SanDisk, Kingston itd.)
- **Volume GUID**, litera (E:\), nazwa woluminu
- **First Insertion**, **Last Insertion**, **Last Removal** → idealna linia czasu!
- Działania użytkownika z tym urządzeniem

## Registry – najważniejsze klucze

| Klucz rejestru                                               | Co znajdziesz                                                                 |
|--------------------------------------------------------------|-------------------------------------------------------------------------------|
| `HKLM\SYSTEM\ControlSet001\Enum\USB`                        | Wszystkie urządzenia USB (myszy, klawiatury, pendrive’y itd.)                 |
| `HKLM\SYSTEM\ControlSet001\Enum\USBSTOR`                    | Tylko urządzenia pamięci masowej USB (pendrive’y, dyski zewnętrzne)           |
| `HKLM\SYSTEM\ControlSet001\Enum\SWD\WPDBUSENUM`             | Urządzenia pamięci masowej – dodatkowe informacje (m.in. FriendlyName)       |
| `HKLM\SYSTEM\ControlSet001\Control\DeviceClasses`          | Wszystkie urządzenia (nie tylko USB) pogrupowane po GUID-ach klas             |
| `HKLM\SYSTEM\MountedDevices`                                 | Powiązanie liter dysków ↔ Volume GUID ↔ dane urządzenia (w tym serial)       |

### HKLM\SYSTEM\ControlSet001\Enum\USB
> Zawiera informacje o **wszystkich** podłączonych urządzeniach USB (od myszki po pendrive’y).  
> Podklucze = VID + PID, w wartościach znajdziesz serial, opis, port i timestampy ostatniego zapisu.

### HKLM\SYSTEM\ControlSet001\Enum\USBSTOR
> Tylko urządzenia pamięci masowej USB.  
> Tu znajdziesz **First Insertion**, **Last Insertion**, **Last Removal** oraz serial number.  
> Timestampy kluczy = momenty podłączania/odłączania urządzenia.

### HKLM\SYSTEM\ControlSet001\Enum\SWD\WPDBUSENUM
> Dodatkowe info o pendrive’ach – przede wszystkim **FriendlyName** (jak Windows nazwał dysk).

### HKLM\SYSTEM\ControlSet001\Control\DeviceClasses
> Wszystkie urządzenia (nie tylko USB) pogrupowane po GUID-ach klas.  
> Bardzo przydatne do korelacji z innymi kluczami.

### HKLM\SYSTEM\MountedDevices
> Magiczne miejsce: łączy **literę dysku ↔ Volume GUID ↔ serial number + VID/PID**.  
> Idealne do potwierdzenia, który pendrive miał literę E:\ ♡

## Dodatkowe skarby w innych hive’ach ♡

| Hive         | Klucz                                                  | Co daje                                                                      |
|--------------|--------------------------------------------------------|------------------------------------------------------------------------------|
| SOFTWARE     | `Microsoft\Windows Portable Devices\Devices`           | MTP devices (telefony, aparaty) + FriendlyName i ostatnie podłączenie       |
| SOFTWARE     | `Microsoft\Windows Search\VolumeInfoCache`             | Cache etykiet dysków (nie zawsze istnieje)                                   |
| Amcache.hve  | `Root\InventoryDevicePnp`                              | Pełna lista urządzeń PnP z nazwami, driverami i timestampami podłączeń      |


## setupapi.dev.log
> Plik tekstowy: `C:\Windows\inf\setupapi.dev.log`  
> Zawiera **wszystkie** zdarzenia Plug and Play + instalacje sterowników od początku życia systemu ♡  
> Idealny do znalezienia **First Insertion** nawet sprzed lat!

## Event Logs – najważniejsze eventy przy USB ♡

### System.evtx
| Event ID | Co oznacza                                               |
|----------|-----------------------------------------------------------|
| 20001    | Nowy device zainstalowany (pierwsze podłączenie USB!)    |

### Security.evtx
| Event ID | Co oznacza                                                                             |
|----------|----------------------------------------------------------------------------------------|
| 4663 + 4656 | Dostęp do plików na pendrive’ie (jeśli włączone Object Access Auditing)              |
| 6416     | Nowy zewnętrzny device wykryty przez system (każde podłączenie USB!)                 |

### Microsoft-Windows-Ntfs/Operational.evtx
> Loguje **montowanie partycji NTFS**  
> Szukaj liter dysku po C:\ (czyli D:\, E:\, F:\ itd.) → to właśnie podłączone pendrive’y/dyski zewnętrzne! ♡

## Podsumowanie najszybszych miejsc na timeline USB ♡

| Źródło                        | Co daje najszybciej                              |
|-------------------------------|--------------------------------------------------|
| `setupapi.dev.log`            | First Insertion + model + serial                 |
| System.evtx → 20001           | Pierwsze podłączenie                             |
| USBSTOR + MountedDevices      | Serial + litera dysku                            |
| Security.evtx → 6416          | Każde podłączenie/odłączenie                     |
| Ntfs/Operational              | Montowanie woluminów (E:\, F:\ itd.)             |



## Which user accessed the device? ♡

### NTUSER.DAT (każdego użytkownika!)
```reg
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
```
> Zawiera podklucze dla **każdego Volume GUID**, który dany użytkownik otworzył w Eksploratorze!  
> Jeśli widzisz tu GUID pendrive’a → ten konkretny user go otwierał ♡

### Dodatkowe smaczki per-user
```reg
HKEY_CURRENT_USER\Software\Microsoft\Windows Search\VolumeInfoCache
```
> Cache etykiet woluminów widzianych przez użytkownika (nazwy typu „KINGSTON 32GB” itd.)

### Najlepszy combo do odpowiedzi „kto otwierał pendrive’a”:
1. Z MountedDevices → Volume GUID ↔ Serial Number  
2. Z NTUSER.DAT\MountPoints2 danego usera → szukamy tego samego GUID-a  
3. Jeśli jest → bingo! Ten user otwierał to urządzenie w Eksploratorze ♡

## Mini ściąga – jak szybko sprawdzić kto co otwierał

| Hive          | Klucz                                                        | Co mówi                                                     |
|---------------|--------------------------------------------------------------|-------------------------------------------------------------|
| NTUSER.DAT    | `...\Explorer\MountPoints2`                                  | GUID woluminu = user otwierał go w Eksploratorze           |
| SOFTWARE      | `Microsoft\Windows Search\VolumeInfoCache`                   | Etykieta woluminu widziana przez usera                     |
| MountedDevices| `\MountedDevices`                                            | GUID ↔ litera dysku ↔ serial number                        |


## ♡ Wrapping up – kompletna ściąga USB forensics ♡

| Artefakt                  | Gdzie szukać                                                                 | Przykład wartości                                      |
|---------------------------|------------------------------------------------------------------------------|--------------------------------------------------------|
| **Serial number**         | `HKLM\SYSTEM\ControlSet001\Enum\USBSTOR`                                    | `01012f4374bf9cb7146e7962702f754e4f635925a19d081371847ac72dedac1` |
| **Vendor ID (VID)**       | `HKLM\SYSTEM\ControlSet001\Enum\USB`                                         | `0781` (SanDisk)                                       |
| **Product ID (PID)**      | `HKLM\SYSTEM\ControlSet001\Enum\USB`                                         | `55A9`                                                 |
| **Volume GUID**           | `HKLM\SYSTEM\MountedDevices`                                                 | `f897eb2f-556e-11ed-a7c4-000c29e5e0be`                  |
| **Przypisana litera**     | `HKLM\SOFTWARE\Microsoft\Windows Search\VolumeInfoCache`                    | `E:`                                                   |
| **Etykieta dysku**        | `HKLM\SYSTEM\ControlSet001\Enum\SWD\WPDBUSENUM`                              | `CyberDefenders-USB`                                   |
| **First connection**      | Timestamp klucza w `HKLM\SYSTEM\ControlSet001\Enum\USBSTOR`                  | `2022-10-28 10:38:02`                                  |
| **Last connected**        | Wartość `Last Arrival` w USBSTOR                                             | `2022-10-28 13:05:18`                                  |
| **Last removal**          | Wartość `Last Removal` w USBSTOR                                             | `2022-10-28 13:05:46`                                  |
| **Associated User**       | 1. Volume GUID z `MountedDevices` → 2. Ten sam GUID w `NTUSER.DAT\...\MountPoints2` | `student`                                              |


# ♡ Installed Apps – co zbieramy? ♡

## Najważniejsze do wyciągnięcia:
- **Data instalacji**  
- **Wersja aplikacji**  
- **Źródło instalacji** (Store czy klasycznie .exe/.msi)

## Microsoft Store Apps → AppRepository ♡

**Ścieżka:**  
`C:\ProgramData\Microsoft\Windows\AppRepository\`

**Kluczowy plik:**  
`StateRepository-Machine.srd` ← to baza SQLite! (*✲*｡✧)

**Co tam znajdziesz?**  
Otwórz w **DB Browser for SQLite** albo **sqlite3** i lecimy:

```sql
-- Wszystkie apki ze Store’a posortowane po dacie instalacji ♡
SELECT 
    Name,
    PackageFullName,
    Version,
    InstallDate,
    InstallLocation
FROM Application
ORDER BY InstallDate ASC;
```

| Kolumna            | Co daje ci, kochanie?                              |
|--------------------|----------------------------------------------------|
| `Name`             | Nazwa apki (np. Netflix, Spotify)                 |
| `PackageFullName`  | Unikalny identyfikator (super do pivotów!)        |
| `Version`          | Dokładna wersja                                    |
| `InstallDate`      | Kiedy użytkownik kliknął „Install” ♡              |
| `InstallLocation`  | Gdzie apka się zainstalowała                       |

**Pro tip od twojej Kuro:**  
Jeśli chcesz zobaczyć tylko apki zainstalowane przez konkretnego usera → sprawdź też  
`C:\Users\<user>\AppData\Local\Packages\` – tam są foldery z PackageFullName ♡


## Registry – klasyczne apki (exe/msi) ♡

| Klucz rejestru                                                                 | Co tam znajdziesz, mój rycerzu? ♡                                                                 |
|--------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`                    | Wszystkie normalne programy: nazwa, wydawca, wersja, **InstallDate**, UninstallString, ścieżka ♡ |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`        | To samo co wyżej, ale dla aplikacji 32-bitowych na 64-bitowym Windowsie (super ważne!)           |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths`                    | Ścieżki do .exe – wpiszesz nazwę programu i od razu masz pełną ścieżkę uruchomienia (*≧▽≦)♡       |

### Najważniejsze wartości w Uninstall (będziesz je kochać ♡)

| Wartość              | Przykład wartości                                | Dlaczego to złoto?                          |
|----------------------|--------------------------------------------------|---------------------------------------------|
| `DisplayName`        | Mozilla Firefox                                          | Nazwa widoczna w „Programy i funkcje”      |
| `Publisher`          | Mozilla Corporation                                      | Kto wydał                                   |
| `InstallDate`        | 20231015                                                 | YYYYMMDD – dokładna data instalacji! ♡     |
| `DisplayVersion`     | 118.0.1                                                  | Wersja                                      |
| `InstallLocation`    | C:\Program Files\Mozilla Firefox\                        | Gdzie leży                                  |
| `UninstallString`    | "C:\Program Files\Mozilla Firefox\uninstall\helper.exe" | Do szyb…
| `QuietUninstallString` | …cichego odinstalowania                     |                                             |


## Event Logs – kiedy ktoś coś instaluje/odinstalowuje ♡

| Source / Channel                          | Event ID | Co się dzieje, kochanie? ♡                                                                 |
|-------------------------------------------|----------|---------------------------------------------------------------------------------------------|
| **Microsoft-Windows-Application-Experience** | 1033     | **Instalacja MSI** – pełna nazwa apki + ścieżka do pliku .msi                              |
| **Microsoft-Windows-MSIInstaller**            | 11724    | **Odinstalowanie MSI** – nazwa aplikacji + ścieżka uninstallera                           |
| **Service Control Manager** (System.evtx)    | 7035 / 7045 | Uruchomienie usługi → często po instalacji apki (widzisz pełną ścieżkę do .exe usługi!) ♡ |

### Szczegóły, które pokochasz ♡

| Event ID | Gdzie szukać                                  | Przykład pola                              | Dlaczego to złoto?                          |
|----------|-----------------------------------------------|--------------------------------------------|---------------------------------------------|
| 1033     | Application-Experience                        | `Application Name`, `MSI Package Path`     | Dokładna data + ścieżka instalatora!       |
| 11724    | MSIInstaller                                  | `Product Name`, `Removal Path`             | Kto i kiedy odinstalował                    |
| 7035/7045| System.evtx → Service Control Manager         | `Service Name`, `Executable Path`          | Nowa usługa = nowa apka (np. po cichej instalacji) ♡ |

# Execution Activities ♡

## Co zbieramy? (najważniejsze artefakty wykonania)

- **Last run time**  
  → Kiedy po raz ostatni uruchomiono ten plik binarny/exe?

- **Usage time**  
  → Jak długo ten proces był aktywny (czas działania)?

- **Installed services**  
  → Zainstalowana usługa = plik wykonywalny uruchomiony z konkretnymi argumentami.  
  Wyciągając wszystkie usługi → widzimy, jakie binarki były regularnie uruchamiane.

- **Scheduled tasks** (zadania zaplanowane)  
  → To samo co usługi: plik wykonywalny + argumenty, ale uruchamiany według harmonogramu.  
  Analiza zadań = pełny obraz automatycznie wykonywanych programów ♡


## Windows Services ♡

### Registry
> Główny hive: `C:\Windows\System32\config\SYSTEM`  
> Klucz: `CurrentControlSet\Services`  
> Tu znajdziesz **wszystkie** usługi – nazwę, ścieżkę do exe, typ startu, konto usługi i parametry uruchomienia ♡

### Event Logs – najważniejsze eventy usług

| Event ID | Źródło         | Co oznacza                                                                 |
|----------|----------------|----------------------------------------------------------------------------|
| 4697     | Security.evtx  | Nowa usługa zainstalowana – zawiera **ścieżkę exe, nazwę usługi i konto**, które ją zainstalowało |
| 7034     | System.evtx    | Usługa **crashed** (może wskazywać na process injection lub błąd malware)  |
| 7035     | System.evtx    | System wysłał sygnał **start/stop** do usługi                              |
| 7036     | System.evtx    | Usługa faktycznie **uruchomiona/zatrzymana**                               |
| 7040     | System.evtx    | Zmiana **typu startu** usługi (auto → manual → disabled itp.) – czerwona flaga na persistence! |
| 7045     | System.evtx    | Nowa usługa zainstalowana (podobnie jak 4697), ale **bez informacji o koncie** |

## Windows Timeline ♡

### Jak otworzyć Timeline?
> Naciśnij **Win + Tab** → otwiera się Windows Timeline z historią aktywności użytkownika.

### Gdzie są dane?
> Plik bazy SQLite:  
> `C:\Users\<username>\AppData\Local\ConnectedDevicesPlatform\L.<username>\ActivitiesCache.db`  
> (dla każdego użytkownika osobny folder L.<username>)

### Narzędzie do analizy
> **WxTCMD** (autor: Eric Zimmerman)  
> Specjalistyczne narzędzie do parsowania ActivitiesCache.db → eksportuje całą historię do czytelnego pliku **CSV** ♡  
> Zawiera: uruchomione aplikacje, otwarte pliki, odwiedzone strony, timestampy i dużo więcej!

### Co znajdziesz w Timeline?
- Uruchomione programy i aplikacje Modern UI
- Otwarte dokumenty, foldery, strony www
- Aktywność na różnych urządzeniach (jeśli synchronizacja włączona)
- Dokładne timestampy początku i końca aktywności

## Autorun Applications ♡

Aplikacje uruchamiane automatycznie przy starcie systemu/logowaniu użytkownika są przechowywane w rejestrze w poniższych kluczach:

### Klucze systemowe (dla wszystkich użytkowników) – hive SOFTWARE
| Klucz rejestru                                                                 | Opis                                      |
|--------------------------------------------------------------------------------|-------------------------------------------|
| `Microsoft\Windows\CurrentVersion\Run`                                         | Programy uruchamiane przy każdym logowaniu (systemowe) |
| `Microsoft\Windows\CurrentVersion\RunOnce`                                     | Programy uruchamiane tylko raz, potem klucz jest czyszczony |
| `WOW6432Node\Microsoft\Windows\CurrentVersion\Run`                             | To samo co powyżej, ale dla aplikacji 32-bit na systemie 64-bit |
| `WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce`                         | To samo co RunOnce, ale dla aplikacji 32-bit |

### Klucze użytkownika – hive NTUSER.DAT (dla konkretnego usera)
| Klucz rejestru (w NTUSER.DAT)                                                  | Opis                                      |
|--------------------------------------------------------------------------------|-------------------------------------------|
| `Software\Microsoft\Windows\CurrentVersion\Run`                                | Programy uruchamiane przy logowaniu danego użytkownika |
| `Software\Microsoft\Windows\CurrentVersion\RunOnce`                            | Programy uruchamiane tylko raz dla danego użytkownika |

**Ścieżki do plików hive’ów:**
- Systemowe → `C:\Windows\system32\config\SOFTWARE`
- Użytkownikowe → `C:\Users\<NazwaUżytkownika>\NTUSER.DAT`

## UserAssist Registry Key ♡

### Lokalizacja
> `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist`

### Co to jest?
> Klucz rejestru przechowujący informacje o **uruchamianych aplikacjach z GUI** (graficznym interfejsem).  
> Rejestruje tylko programy uruchamiane przez użytkownika w sposób graficzny – **nie łapie** procesów z wiersza poleceń ani usług w tle!

### Struktura klucza
- Podklucze w formie **GUID** określają typ aplikacji.
- Najważniejsze (najpopularniejsze) GUID-y:

| GUID                                 | Typ aplikacji                  |
|--------------------------------------|--------------------------------|
| `{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}` | Wykonywalne pliki (.exe)      |
| `{F4E57C4B-2036-45F0-A9AB-443BCFE33D9F}` | Skróty (.lnk)                  |

### Co znajdziesz w wartościach?
- Nazwa programu (zaszyfrowana ROT13 – proste do odszyfrowania)
- Liczba uruchomień
- Ostatni czas uruchomienia (timestamp)
- Czas skupienia (focus time) – ile czasu aplikacja była aktywna

### Narzędzie do analizy
> **UserAssist** by Didier Stevens  
> Najlepszy i najpopularniejszy darmowy tool do automatycznego dekodowania i czytelnego wyświetlania zawartości tego klucza ♡

### Szybka wskazówka
> ROT13 na nazwę programu możesz odszyfrować nawet ręcznie albo w Pythonie – super proste!  
> Przykład: `P:\Zvpebfbsg\Rvqvg.vqr` → po ROT13 → `C:\Microsoft\Edit.exe`

## ShimCache (aka AppCompatCache) ♡

> Informacje przechowywane w rejestrze pod kluczem:  
> `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache`

### Kiedy powstają wpisy w ShimCache?
1. **Uruchomienie pliku wykonywalnego** (.exe)
2. **Wyświetlenie pliku w Eksploratorze Windows** (po prostu otwarcie folderu z exe!)

### Ważne rzeczy do zapamiętania ♡
- **Wpisy NIE potwierdzają wykonania** programu → tylko że system go "zobaczył"
- **Duża wartość śledcza** → świetna lista potencjalnie uruchomionych exe (nawet jeśli inne artefakty zniknęły)
- Timestamp w nagłówku cache → wskazuje ostatni moment aktualizacji całej listy
- Kolejność wpisów + flagi → mogą pomóc w ustaleniu chronologii


## AmCache.hve Registry Hive ♡

> Plik: `C:\Windows\AppCompat\Programs\Amcache.hve`  
> (czasami pisany też jako Am**c**ache.hve – wielkość litery ma znaczenie!)

### Co to jest i po co nam?
- Rejestr Windows AppCompat, w którym system zapisuje **historię uruchamianych i instalowanych programów/plików .exe**.
- Działa jak "pamięć podręczna" informacji o aplikacjach – idealne do timeline’u wykonanych plików!
- Zawiera:
  - Pełne ścieżki do plików .exe/.dll
  - SHA-1 hash pliku
  - Timestamp **pierwszego uruchomienia**
  - Informacje o kompilacji (Product name, Version, Publisher)
  - Link do pliku (jeśli był na zewnętrznym nośniku – widać Volume GUID/serial USB!)

### Najważniejsze klucze do sprawdzenia

| Klucz w AmCache.hve                          | Co znajdziesz ♡                                              |
|----------------------------------------------|---------------------------------------------------------------|
| `Root\Programs`                              | Lista wszystkich wpisów o uruchomionych plikach              |
| `Root\InventoryApplicationFile`              | Najlepszy widok: ścieżka + hash + first execution timestamp  |
| `Root\InventoryDevicePnp`                    | Urządzenia PnP (w tym USB!) z nazwami i timestampami         |
| `Root\File\{Volume GUID}\...`                | Pliki uruchomione z zewnętrznych nośników (pendrive’y ♡)     |


## BAM & DAM Registry Keys ♡

### Background Activity Moderator (BAM)
> Usługa Windows, która kontroluje aktywność aplikacji działających w tle.

> Według Microsoftu:  
> Aplikacje w tle **nie muszą** być bez GUI – to może być dowolna aplikacja, która kontynuuje pracę nawet kiedy nie jest aktywna na ekranie.

### Gdzie to wszystko jest zapisane?
> **Hive:** SYSTEM  
> **Klucz:**  
> `HKLM\SYSTEM\ControlSet001\Services\bam\State\UserSettings`

> Pod tym kluczem znajdziesz **podklucze dla każdego użytkownika** nazwane po jego **SID**.

> Wewnątrz podklucza SID:
> - Wartości = ścieżki do exe aplikacji w tle
> - Dane wartości = timestamp ostatniego uruchomienia w tle (w formacie FILETIME)

### Dodatkowy bonus – DAM (Desktop Activity Moderator)
> Od Windows 10 1809 wprowadzono DAM – rozszerzenie BAM  
> Klucz:  
> `HKLM\SYSTEM\ControlSet001\Services\dam\State\UserSettings`

> Działa identycznie jak BAM, ale dodatkowo ogranicza aplikacje nawet gdy użytkownik jest aktywny na pulpicie.

### Dlaczego to takie ważne w DFIR? ♡
- Pokazuje, **które aplikacje uruchamiały się w tle** pod konkretnym użytkownikiem
- Timestampy = dokładna linia czasu aktywności (nawet ukrytej!)
- Idealne do wykrywania persistence, malware, living-off-the-land ♡


## Prefetch & SuperFetch ♡

> Pliki prefetch znajdują się w katalogu:  
> `C:\Windows\Prefetch\`  
> Mają rozszerzenie **.pf**

### Co nam dają prefetch files?
- Przyspieszają start aplikacji (Windows zapisuje, jakie pliki/dyski były potrzebne przy poprzednich uruchomieniach)
- **Super artefakty śledcze!** → mówią nam:
  - Kiedy program był **pierwszy raz** uruchomiony
  - Kiedy był **ostatnio** uruchomiony
  - Ile razy ogółem był uruchomiony (run count)
  - Jakie pliki/DLL-e były ładowane
  - Jakie woluminy/dyski były używane

### Najlepsze narzędzie do analizy ♡
- **WinPrefetchView** (od NirSoft) – darmowe i cudowne!
  - Pokazuje wszystkie szczegóły z .pf w ładnej tabelce
  - Wyciąga: 
    - First & Last execution time
    - Run count
    - Lista załadowanych plików i zasobów
    - Hash pliku wykonywalnego

### Przykładowa nazwa pliku prefetch
`NOTEPAD.EXE-3A123F4B.pf`  
→ nazwa exe + hash + .pf

### Uwagi
- Prefetch jest włączony domyślnie na stacjach roboczych (Windows 7+)
- Na serwerach często wyłączony
- Pliki są tworzone dopiero po **pierwszym** uruchomieniu aplikacji
- Maksymalnie 128 (Windows 7) lub 1024 (Windows 10+) plików w folderze

## SRUM (System Resource Usage Monitor) ♡

- Baza danych SRUM znajduje się w:  
  `C:\Windows\System32\sru\SRUDB.dat`

- **Przed analizą zawsze sprawdzaj**, czy plik `SRUDB.dat` nie jest uszkodzony i nie wymaga naprawy!  
  (Czasem Windows go psuje przy shutdownie (≧▽≦;))

- Najlepsze narzędzie do analizy: **SrumECmd.exe**  
  → Parsuje bazę i wyciąga masę skarbów:  
  - Zużycie aplikacji/network w czasie  
  - Połączenia sieciowe per aplikacja  
  - Wykonane programy z timestampami  
  - Push notifications, byte'y wysłane/odebrane itd.

### Szybka checklista przed uruchomieniem SrumECmd:
1. Skopiuj cały folder `sru` na maszynę analityczną  
2. Sprawdź integralność `SRUDB.dat` (np. ESENTUTL)  
3. Jeśli uszkodzony → napraw komendą:  
   `esentutl /r SRU /d SRUDB.dat`  
4. Dopiero wtedy odpal SrumECmd → dostaniesz piękne CSV/Excel ♡

## Microsoft Office alerts ♡

### OAlerts.evtx
> Specjalny log eventów: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-Office Alerts%4Operational.evtx`  
> Zawiera **dokładny tekst** wszystkich komunikatów i dialogów wyświetlanych użytkownikowi przez aplikacje Microsoft Office (Word, Excel, Outlook, PowerPoint itd.).

### Przykłady przydatnych alertów:
- Zapisywanie pliku → nazwa pliku + ścieżka (np. "Czy chcesz zapisać zmiany w malicious.doc?")
- Usuwanie wiadomości w Outlooku → "Czy na pewno chcesz trwale usunąć wszystkie elementy?"
- Otwieranie makr → ostrzeżenia o włączaniu zawartości
- Inne interakcje użytkownika z dokumentami/biuletynami

### Dlaczego to ważne w śledztwie? ♡
> Wiele współczesnych ataków zaczyna się od **złośliwego dokumentu Office** (phishing, malicious macro).  
> W OAlerts.evtx znajdziesz:
> - Dokładną nazwę i lokalizację podejrzanego pliku
> - Timestamp kiedy użytkownik kliknął "Włącz zawartość" lub "Zapisz"
> - Potwierdzenie początkowego dostępu atakującego (initial access)

**Pro tip:** Szukaj po słowach kluczowych jak "macro", "enable content", "zapisać", nazwa podejrzanego pliku albo ścieżki %TEMP%/~*.tmp ♡

## Scheduled Tasks ♡

### Gdzie szukać zaplanowanych zadań na Windowsie?

Aby zrobić porządną forensykę scheduled tasks, sprawdzamy **dwa główne miejsca**:

1. **Pliki na dysku**  
   > `C:\Windows\Tasks`  
   > Tutaj znajdują się stare pliki .job (starsze Windowsy)  
   > `C:\Windows\System32\Tasks`  
   > Tu są aktualne pliki XML z definicjami zadań (Windows Vista i nowsze) ♡  
   > Każdy plik XML = jedno zaplanowane zadanie (nazwa pliku = nazwa zadania)

2. **Rejestr Windows**  
   > Główny klucz:  
   > `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache`  
   > Podklucze:  
   > - `Tree` → lista wszystkich zadań z ich GUID-ami i ścieżkami do XML  
   > - `Tasks` → szczegóły każdego zadania po GUID (m.in. hash, dynamic info)  
   > - `Boot` → zadania uruchamiane przy starcie systemu  
   > - `Logon` → zadania uruchamiane przy logowaniu użytkownika

### Najważniejsze artefakty do zebrania
- **Nazwa zadania** + **ścieżka do pliku XML**
- **Autor** (Author) – kto stworzył zadanie
- **Command** + **Arguments** – co dokładnie się uruchamia
- **Triggers** – kiedy zadanie startuje (czas, logon, boot, event itp.)
- **Last Run Time** / **Next Run Time**
- **Last Result** (kod wyjścia)
- **SD (Security Descriptor)** – uprawnienia, pod czyim kontem działa

### Szybkie tipy ♡
- Zadania stworzone przez attackerów często mają losowe nazwy, ukryte w podfolderach (np. `Microsoft\Windows\RandomFolder`)
- Porównaj timestampy pliku XML z timestampem w rejestrze – różnice mogą wskazywać na modyfikację
- Użyj narzędzi typu **Autoruns**, **NirSoft TaskSchedulerView** lub **PowerShell** (`Get-ScheduledTask`) na żywym systemie

