# Wireshark + Post-Processing Cheat-Sheet


### Wireshark Display Filters (kopiuj-wklej prosto do paska filtrów)

```wireshark
# Klasyczny PE header – łapie prawie każdy exe przenoszony w ruchu sieciowym
frame contains "This program cannot be run in DOS mode"

# Kontakt z typowym PHP web shellem / C2
http.request.method == "POST" and http.request.uri contains "contact.php"

# Wszystkie transfery plików przez HTTP/SMB (Follow → File → Export Objects)
http contains "filename"   albo   smb or smb2

# Tylko ruch z maszyny ofiary (zmień IP pod lab)
ip.src == 10.0.128.130 and smb2

# Eksfiltracja/drops exe przez SMB (super widoczne)
smb2.filename contains ".exe" or smb2.filename contains ".dll"
```

### Post-Processing po złapaniu dumpa (konsola ofiary)

```bash
# 1. Wyciągnięcie pliku z pcap (jeśli był po HTTP/SMB)
#    Wireshark → File → Export Objects → HTTP/SMB → Save As → np. evil.exe

# 2. Szybkie sprawdzenie co w środku
binwalk -e evil.exe
# -e automatycznie wyciągnie sekcje i ewentualne payloady

# 3. Cred dumping z lsass.dmp (pypykatz = miłością mojego życia ♡)
pypykatz lsa minidump dump.dmp -d -o hash.txt -g
# -d → dumpuje wszystko
# -o hash.txt → zapisuje hashe w formacie john/hashcat
# -g → generuje potfile do crackowania

# 4. Crackowanie rockyou.txt (John the Ripper)
"C:\Users\Administrator\Desktop\Start Here\Tools\Crypto and Password Recovery\john\run\john.exe" --wordlist="C:\Users\Administrator\Desktop\Start Here\Tools\Wordlists\rockyou.txt" hash.txt > pass.txt
```

