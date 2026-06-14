# User Activity — Accounts, Files, and Removable Media

Reference for tracing what happened on a Windows host from the user's perspective: account activity and logons, file/folder creation and access history, user-driven actions (MRU, Shellbags, LNK/JumpLists), and removable media usage. See [Disk-Forensic.md](Disk-Forensic.md) for tooling, must-check locations, and system profiling, and [Execution-Evidence.md](Execution-Evidence.md) for installed software and program-execution evidence.

## User Information

### What to Extract

For every local account: username, SID, RID, group memberships, account creation date, last logon, last password change, and account status (enabled/disabled/locked/never-expires).

### SAM Hive

`HKLM\SAM\SAM\Domains\Account\Users\<RID (hex)>` contains, per account, an `F` value (logon counts, lockout/last-login FILETIME timestamps) and a `V` value (username, full name, comment).

- **RID (Relative Identifier)**: the final component of a SID, unique on the local machine. `500` = built-in Administrator, `501` = built-in Guest, `1000+` = regular accounts created after install, in creation order.
- **SID format**: `S-1-5-21-<machine/domain identifier>-<RID>` — e.g. a SID ending in `-1000` is the first user account created on this machine.

### Logon Activity (Security.evtx)

| Event ID | Meaning |
|---|---|
| 4624 | An account was successfully logged on |
| 4625 | An account failed to log on |
| 4634 | An account was logged off |
| 4647 | User-initiated logoff |
| 4648 | A logon was attempted using explicit credentials (e.g. `runas`, saved RDP credentials) |
| 4672 | Special privileges (admin-equivalent token) assigned to a new logon |
| 4720 | A user account was created |
| 4726 | A user account was deleted |

**Tip:** The Logon Type field on 4624/4625 (2 = interactive, 3 = network, 10 = RemoteInteractive/RDP, etc.) tells you *how* the account was used. See [../Threat-Hunting/KQL-Threat-Hunting.md](../Threat-Hunting/KQL-Threat-Hunting.md) for the full Logon Type table and lateral-movement hunting queries built on these events.

---

## File and Folder Activity

### $MFT (Master File Table)

Every file and directory on an NTFS volume has an `$MFT` record carrying multiple timestamps and metadata attributes. Parse with:

```powershell copy
MFTECmd.exe -f C:\cases\$MFT --csv C:\cases\out
```

| Attribute / Column | Meaning |
|---|---|
| `$STANDARD_INFORMATION` (SI) | Created / Modified / MFT-Modified / Accessed timestamps — easily altered by timestomping tools |
| `$FILE_NAME` (FN) | A second, independent set of the same four timestamps — normally only updated on rename/move, harder to forge consistently |
| `FileName` | File or directory name |
| `Extension` | File extension |
| `FileSize` | Size in bytes |
| `IsDirectory` | Whether the record represents a directory |
| `ParentPath` | Resolved path of the parent directory |

**Note:** SI timestamps that are newer than the corresponding FN timestamps (or an SI created-time that postdates the SI modified-time) is a classic timestomping indicator.

### $UsnJrnl (USN Change Journal)

A rolling log of every create/delete/rename/write/security-change operation on the volume. Parse the `$J` data stream with:

```powershell copy
MFTECmd.exe -f C:\cases\$J --csv C:\cases\out
```

| Column | Meaning |
|---|---|
| `UpdateTimestamp` | When the change occurred |
| `FileName` | Name of the affected file or folder |
| `UpdateReasons` | Flags describing the change (`FileCreate`, `DataExtend`, `FileDelete`, `RenameOldName`/`RenameNewName`, …) |
| `FileAttributes` | File attributes at the time of the change |
| `EntryNumber` / `ParentEntryNumber` | MFT entry numbers for the file and its parent — links the change back to `$MFT` |

**Note:** `$UsnJrnl` keeps a history of files that no longer exist (deleted, or renamed and later deleted) — often the only surviving record after an attacker cleans up.

### $LogFile

NTFS's own transaction log — records low-level metadata operations (creation, renames, attribute changes) just before they are committed to `$MFT`. Useful for recovering very recent activity that hasn't aged out yet, and for confirming the exact order of operations around an incident timestamp.

### $I30 / INDX Attributes

Every directory stores an index of its entries in the `$I30` attribute, used for fast name lookups. When a file is deleted, its entry can remain in unallocated "slack" space inside `$I30`.

- `MFTECmd.exe -i30` — extracts `$I30` records from a raw image.
- [INDXRipper](https://github.com/sk3pp3r/INDXRipper) — recovers deleted file-name entries from `$I30` slack space.

### Windows Search Database

`Windows.edb` (older systems) or `Windows.db` (Windows 10/11), under `C:\ProgramData\Microsoft\Search\Data\Applications\Windows\`, indexes file names, paths, and content for Windows Search. It can reveal files — including their original full path — that have since been deleted.

### Best Hunting Locations

```
C:\Users\<user>\Desktop
C:\Users\<user>\Downloads
C:\Users\<user>\Documents
C:\Users\<user>\AppData\Local\Temp
C:\Windows\Temp
C:\ProgramData
C:\Users\Public
```

---

## User Actions

### Object Access Auditing (Security.evtx)

Object-access auditing must be enabled before file/folder access is logged:

```powershell copy
auditpol /set /subcategory:"File System" /success:enable /failure:enable
```

| Event ID | Meaning |
|---|---|
| 4656 | A handle to an object was requested |
| 4663 | An attempt was made to access an object (the actual read/write/delete) |
| 4660 | An object was deleted |
| 4658 | A handle to an object was closed |

### MRU Lists

| Location | What it tracks |
|---|---|
| `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU` | Commands typed into the Win+R Run dialog |
| `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs` | Recently opened files/folders, overall and per extension |
| `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU` | Files browsed via Open/Save common dialogs, grouped by extension |
| `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths` | Paths typed into Explorer's address bar |
| `NTUSER.DAT\Software\Microsoft\Office\<version>\<app>\File MRU` | Recently opened Office documents, per application |

### Shellbags

`UsrClass.dat\Local Settings\Software\Microsoft\Windows\Shell\BagMRU` (and `NTUSER.DAT` on older systems) records every folder a user has browsed in Explorer, including folders that have since been deleted or that lived on removable media that is no longer attached. Each "bag" stores window/view settings plus a reference to the folder, which can be recovered even after the folder itself is gone.

### LNK Files

Shortcut (`.lnk`) files are created automatically whenever a user opens a file from Explorer, and are stored in `%APPDATA%\Microsoft\Windows\Recent\`. Each `.lnk` embeds:

- The target file's path, size, and timestamps
- The **Volume Serial Number** and **Volume Label** of the drive the target was on at the time
- The originating host's **NetBIOS name** and **MAC address** — useful for tracking a file across multiple machines (e.g. on a USB stick)

Parse with [LECmd](https://github.com/EricZimmerman/LECmd).

### JumpLists

Stored under `%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\` (auto-generated, one `.automaticDestinations-ms` file per application, named by AppID) and `...\CustomDestinations\` (items the user pinned).

Each entry records:

- The target file path, often as an embedded LNK stream
- **AppID** — identifies which application generated the entry (public lookup tables map AppIDs to application names)
- **Interaction Count** — how many times the item was opened from that JumpList

Parse with [JLECmd](https://github.com/EricZimmerman/JLECmd).

---

## USB Devices

### Key Collection Targets

- Device serial number
- Vendor ID (VID) + Product ID (PID)
- Volume GUID
- First/last insertion and removal timestamps
- Drive letter assigned
- Friendly/device name
- Which user account accessed it

### Registry Keys

| Key | What it provides |
|---|---|
| `HKLM\SYSTEM\CurrentControlSet\Enum\USB` | One subkey per VID/PID combination ever connected, with a child subkey per device serial number; `FriendlyName` and FILETIME timestamps for first-install/last-connected |
| `HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR` | USB mass-storage devices specifically — vendor/product/revision and serial number, plus `FriendlyName` |
| `HKLM\SYSTEM\CurrentControlSet\Enum\SWD\WPDBUSENUM` | Windows Portable Devices (phones, cameras, MTP devices) — serial/friendly-name data for non-mass-storage USB devices |
| `HKLM\SYSTEM\CurrentControlSet\Control\DeviceClasses\{GUID}` | GUID-based device-interface registrations for storage volumes — links a device instance to a Volume GUID |
| `HKLM\SYSTEM\MountedDevices` | Maps drive letters and Volume GUIDs to the device path/serial number that was mounted there — the key link between "drive letter" and "physical device" |

#### Enum\USB

Every USB device class (not only storage) leaves an entry here, keyed first by VID and PID (e.g. `VID_0781&PID_5567`) and then by the device's serial number. The `Properties\{83da6326-97a6-4088-9453-a1923f573b29}\...` subkeys under each device hold FILETIME values for first install and last connect/disconnect.

#### Enum\USBSTOR

Specifically for USB mass storage (thumb drives, external HDDs). Subkey names follow `Disk&Ven_<vendor>&Prod_<product>&Rev_<revision>`, with a child keyed by the device's serial number and a `FriendlyName` value.

#### Enum\SWD\WPDBUSENUM

Covers devices enumerated via the Windows Portable Device stack — smartphones, cameras, MP3 players — that don't register under USBSTOR.

#### DeviceClasses

Each storage volume gets a GUID-based device-interface registration here; this is the bridge between the physical USB device and the **Volume GUID** Windows assigns to the partition on it.

#### MountedDevices

Values like `\DosDevices\E:` map a drive letter to either `\??\Volume{<Volume GUID>}` or directly to a device serial-number string, telling you which drive letter a specific device last used.

### Additional Hives

| Hive / Path | Contents |
|---|---|
| `HKLM\SOFTWARE\Microsoft\Windows Portable Devices\Devices` | Friendly names mapped to Volume GUIDs, per portable device |
| `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\CPC\Volume\{Volume GUID}` | Per-user record that a given Volume GUID was mounted — ties a device to a specific *user* |
| `Amcache.hve\Root\InventoryDevicePnp` | Plug-and-play device inventory, including USB devices, with first-seen timestamps |

### setupapi.dev.log

`C:\Windows\inf\setupapi.dev.log` logs every PnP device installation, including the exact timestamp a USB device's driver was installed — often the most precise "first connected" timestamp available, down to the second.

### Event Logs

| Log | Event ID | Meaning |
|---|---|---|
| System.evtx | 20001 | Plug and Play driver install attempted for a device (includes the device ID with VID/PID/serial) |
| Security.evtx | 4656 / 4663 | Object access to the device/volume, if object auditing is enabled |
| Security.evtx | 6416 | A new external device was recognized by the system |
| Microsoft-Windows-Ntfs/Operational | — | Volume-level mount/dismount events for the USB device's filesystem |

### Summary Timeline

| Question | Best source |
|---|---|
| When was the device first ever connected? | `setupapi.dev.log`, `Enum\USBSTOR` first-install timestamp, `Amcache\InventoryDevicePnp` |
| When was it last connected/removed? | `Enum\USB\...\Properties` last-arrival/removal FILETIME values |
| What drive letter did it get? | `MountedDevices`, `MountPoints2` |
| What files were accessed on it? | Shellbags, LNK files, JumpLists, and `$MFT`/`$UsnJrnl` if the volume itself was imaged |

### Which User Accessed the Device

- `NTUSER.DAT\...\Explorer\MountPoints2\CPC\Volume\{Volume GUID}` exists in the hive of every user who mounted that specific volume.
- `HKLM\SOFTWARE\Microsoft\Windows Portable Devices\Devices\...\VolumeInfoCache` — per-volume friendly-name cache, cross-referenced against each user's `MountPoints2` entries to attribute usage to a specific account.
- **Combo method**: match the Volume GUID from `MountedDevices` (system-wide) against the Volume GUIDs present in each user's `MountPoints2` to determine which user(s) had the device mounted.

### Mini Cheat Sheet

| Artifact | Tells you |
|---|---|
| `Enum\USBSTOR` | Device identity (vendor/product/serial) |
| `MountedDevices` | Drive letter ↔ Volume GUID/device serial |
| `MountPoints2` (per user) | Which user mounted it |
| `setupapi.dev.log` | First-connect timestamp |
| Event 20001 (System.evtx) | Driver-install events with device ID |
| Shellbags / LNK / JumpLists | Files accessed on the device |

### Wrapping Up — Worked Example

Putting the pieces together for a single device, e.g. a SanDisk USB drive:

| Field | Example value | Source |
|---|---|---|
| Vendor ID (VID) | `0781` (SanDisk) | `Enum\USBSTOR` subkey name |
| Product ID (PID) | `5567` | `Enum\USBSTOR` subkey name |
| Serial Number | device-specific string | `Enum\USBSTOR` child subkey name |
| Volume GUID | `f897eb2f-556e-11ed-a7c4-000c29e5e0be` | `DeviceClasses` / `MountPoints2` |
| Drive letter | e.g. `E:` | `MountedDevices` entry referencing the Volume GUID above |
| First connected | timestamp from install log | `setupapi.dev.log` |
| User who accessed it | account whose hive contains the matching MountPoints2 entry | `NTUSER.DAT\...\MountPoints2\CPC\Volume\{f897eb2f-556e-11ed-a7c4-000c29e5e0be}` |
